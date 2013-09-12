package org.daisy.pipeline.braille.liblouis.calabash;

import java.io.File;
import java.net.URL;
import java.net.URI;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmSequenceIterator;

import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.daisy.pipeline.braille.liblouis.Liblouisutdml;
import static org.daisy.pipeline.braille.Utilities.Files;

import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;

public class TranslateFileProvider implements XProcStepProvider {
	
	private static final String LOUIS_NS = "http://liblouis.org/liblouis";
	private static final String LOUIS_PREFIX = "louis";
	private static final QName louis_result = new QName(LOUIS_PREFIX, LOUIS_NS, "result");
	
	private static final QName _table = new QName("table");
	private static final QName _paged = new QName("paged");
	private static final QName _temp_dir = new QName("temp-dir");
	private static final QName _href = new QName("href");
	private static final QName _pages = new QName("pages");
	
	private static final QName d_fileset = new QName("http://www.daisy.org/ns/pipeline/data", "fileset");
	private static final QName d_file = new QName("http://www.daisy.org/ns/pipeline/data", "file");
	
	private static final QName louis_page_height = new QName(LOUIS_PREFIX, LOUIS_NS, "page-height");
	private static final QName louis_page_width = new QName(LOUIS_PREFIX, LOUIS_NS, "page-width");
	private static final QName louis_print_page_position = new QName(LOUIS_PREFIX, LOUIS_NS, "print-page-position");
	private static final QName louis_braille_page_position = new QName(LOUIS_PREFIX, LOUIS_NS, "braille-page-position");
	private static final QName louis_page_break_separator = new QName(LOUIS_PREFIX, LOUIS_NS, "page-break-separator");
	private static final QName louis_braille_page_begin = new QName(LOUIS_PREFIX, LOUIS_NS, "braille-page-begin");
	
	private Liblouisutdml liblouisutdml = null;
	
	protected void bindLiblouisutdml(Liblouisutdml liblouisutdml) {
		this.liblouisutdml = liblouisutdml;
	}
	
	protected void unbindLiblouisutdml(Liblouisutdml liblouisutdml) {
		this.liblouisutdml = null;
	}
	
	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new TranslateFile(runtime, step);
	}
	
	public class TranslateFile extends DefaultStep {
		
		private ReadablePipe source = null;
		private ReadablePipe styles = null;
		private ReadablePipe semantics = null;
		private WritablePipe result = null;
		private Hashtable<QName,RuntimeValue> pageLayout = new Hashtable<QName,RuntimeValue> ();
		
		/**
		 * Creates a new instance of TranslateFile
		 */
		private TranslateFile(XProcRuntime runtime, XAtomicStep step) {
			super(runtime, step);
		}
		
		@Override
		public void setInput(String port, ReadablePipe pipe) {
			if (port.equals("source"))
				source = pipe;
			else if (port.equals("styles"))
				styles = pipe;
			else if (port.equals("semantics"))
				semantics = pipe;
		}
		
		@Override
		public void setOutput(String port, WritablePipe pipe) {
			result = pipe;
		}
		
		@Override
		public void setParameter(QName name, RuntimeValue value) {
			setParameter("page-layout", name, value);
		}
		
		@Override
		public void setParameter(String port, QName name, RuntimeValue value) {
			if (port.equals("page-layout"))
				pageLayout.put(name, value);
			else
				super.setParameter(port, name, value);
		}
		
		@Override
		public void reset() {
			source.resetReader();
			styles.resetReader();
			semantics.resetReader();
			result.resetWriter();
		}
		
		@Override
		public void run() throws SaxonApiException {
			
			super.run();
			
			try {
				
				Map<String,String> settings = new HashMap<String,String>();
				settings.put("lineEnd", "\\n");
				settings.put("pageEnd", "\\f");
				
				// Get options
				if (getOption(_paged) != null)
					settings.put("braillePages",  getOption(_paged).getBoolean() ? "yes" : "no");
				if (pageLayout.containsKey(louis_page_width))
					settings.put("cellsPerLine", pageLayout.get(louis_page_width).getString());
				if (pageLayout.containsKey(louis_page_height))
					settings.put("linesPerPage", pageLayout.get(louis_page_height).getString());
				if (pageLayout.containsKey(louis_braille_page_position)) {
					String position = pageLayout.get(louis_braille_page_position).getString();
					if (position.equals("top-right") || position.equals("bottom-right")) {
						settings.put("braillePageNumberAt", position.replace("-right", ""));
						settings.put("numberBraillePages", "yes"); }
					else if (position.equals("none"))
						settings.put("numberBraillePages", "no"); }
				if (pageLayout.containsKey(louis_print_page_position)) {
					String position = pageLayout.get(louis_print_page_position).getString();
					if (position.equals("top-right") || position.equals("bottom-right")) {
						settings.put("printPageNumberAt", position.replace("-right", ""));
						settings.put("printPages", "yes"); }
					else if (position.equals("none"))
						settings.put("printPages", "no"); }
				if (pageLayout.containsKey(louis_page_break_separator)) {
					boolean separator = pageLayout.get(louis_page_break_separator).getBoolean();
					settings.put("pageSeparator", separator ? "yes" : "no");
					settings.put("pageSeparatorNumber", separator ? "yes" : "no"); }
				if (pageLayout.containsKey(louis_braille_page_begin))
					settings.put("beginningPageNumber",
					             pageLayout.get(louis_braille_page_begin).getString());
				
				File tempDir = new File(new URI(getOption(_temp_dir).getString()));
				String configPath = null;
				
				// Get configuration files
				List<String> configFileNames = new ArrayList<String>();
				if (styles != null) {
					while(styles.moreDocuments()) {
						XdmNode fileset = (XdmNode)styles.read().axisIterator(Axis.CHILD, d_fileset).next();
						URI baseURI = fileset.getBaseURI();
						XdmSequenceIterator files = fileset.axisIterator(Axis.CHILD, d_file);
						while (files != null && files.hasNext()) {
							URL url = baseURI.resolve(((XdmNode)files.next()).getAttributeValue(_href)).toURL();
							String path = Files.resolve(url, ".").toString();
							if (configPath == null)
								configPath = path;
							else if (!configPath.equals(path))
								throw new XProcException(step.getNode(),
										"All configuration files and semantic action files must be placed in " + configPath);
							configFileNames.add(Files.relativize(path, url)); }}}
				
				// Get semantic action files
				List<String> semanticFileNames = new ArrayList<String>();
				if (semantics != null) {
					while(semantics.moreDocuments()) {
						XdmNode fileset = (XdmNode)semantics.read().axisIterator(Axis.CHILD, d_fileset).next();
						URI baseURI = fileset.getBaseURI();
						XdmSequenceIterator files = fileset.axisIterator(Axis.CHILD, d_file);
						while (files != null && files.hasNext()) {
							URL url = baseURI.resolve(((XdmNode)files.next()).getAttributeValue(_href)).toURL();
							String path = Files.resolve(url, ".").toString();
							if (configPath == null)
								configPath = path;
							else if (!configPath.equals(path))
								throw new XProcException(step.getNode(),
										"All configuration files and semantic action files must be placed in " + configPath);
							semanticFileNames.add(Files.relativize(path, url)); }}}
				
				String table = null;
				if (getOption(_table) != null)
					table = getOption(_table).getString();
				
				// Write XML document to file
				XdmNode xml = source.read();
				File xmlFile = File.createTempFile("liblouisutdml.", ".xml", tempDir);
				Serializer serializer = new Serializer(xmlFile);
				serializer.serializeNode(xml);
				serializer.close();
				
				File bodyTempFile = new File(tempDir, "lbx_body.temp");
				bodyTempFile.delete();
				
				// Convert using file2brl
				File brailleFile = File.createTempFile("liblouisutdml.", ".txt", tempDir);
				liblouisutdml.translateFile(configFileNames, semanticFileNames, table,
						settings, xmlFile, brailleFile, configPath, tempDir);
				
				// Read the braille document and wrap it in a new XML document
				LiblouisResultReader reader = new LiblouisResultReader(brailleFile, bodyTempFile);
				while (true) {
					StringBuilder section = new StringBuilder();
					String page;
					int pageCount = 0;
					while ((page = reader.readPage()) != null) {
						section.append(page).append('\f');
						pageCount++; }
					writeDocument(xml.getBaseURI(), section.toString(), pageCount);
					if (!reader.nextSection())
						break; }}
			
			catch (Exception e) {
				throw new XProcException(step.getNode(), e); }
		}
		
		private void writeDocument(URI baseURI, String textContent, int pageCount) {
			TreeWriter treeWriter = new TreeWriter(runtime);
			treeWriter.startDocument(baseURI);
			treeWriter.addStartElement(louis_result);
			treeWriter.addAttribute(_pages, String.valueOf(pageCount));
			treeWriter.startContent();
			treeWriter.addText(textContent);
			treeWriter.addEndElement();
			treeWriter.endDocument();
			result.write(treeWriter.getResult());
		}
	}
}
