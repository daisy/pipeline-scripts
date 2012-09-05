package org.daisy.pipeline.liblouis.calabash;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmSequenceIterator;

import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.daisy.pipeline.liblouis.Liblouisutdml;
import org.daisy.pipeline.liblouis.Utilities.OS;

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
	private static final QName louis_output = new QName(LOUIS_PREFIX, LOUIS_NS, "output");
	private static final QName louis_section = new QName(LOUIS_PREFIX, LOUIS_NS, "section");

	private static final QName _ini_file = new QName("ini-file");
	private static final QName _table = new QName("table");
	private static final QName _paged = new QName("paged");
	private static final QName _page_height = new QName("page-height");
	private static final QName _line_width = new QName("line-width");
	private static final QName _temp_dir = new QName("temp-dir");
	private static final QName c_directory = new QName("http://www.w3.org/ns/xproc-step", "directory");
	private static final QName c_file = new QName("http://www.w3.org/ns/xproc-step", "file");
	private static final QName _name = new QName("name");
	
	private Liblouisutdml liblouisutdml = null;
	
	public void bindLiblouisutdml(Liblouisutdml liblouisutdml) {
		this.liblouisutdml = liblouisutdml;
	}

	public void unbindLiblouisutdml(Liblouisutdml liblouisutdml) {
		this.liblouisutdml = null;
	}
	
	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new TranslateFile(runtime, step);
	}
	
	public class TranslateFile extends DefaultStep {
	
		private ReadablePipe source = null;
		private ReadablePipe configFiles = null;
		private ReadablePipe semanticFiles = null;
		private WritablePipe result = null;
	
		/**
		 * Creates a new instance of TranslateFile
		 */
		private TranslateFile(XProcRuntime runtime, XAtomicStep step) {
			super(runtime, step);
		}
	
		@Override
		public void setInput(String port, ReadablePipe pipe) {
			if (port.equals("source")) {
				source = pipe;
			} else if (port.equals("config-files")) {
				configFiles = pipe;
			} else if (port.equals("semantic-files")) {
				semanticFiles = pipe;
			}
		}
	
		@Override
		public void setOutput(String port, WritablePipe pipe) {
			result = pipe;
		}
	
		@Override
		public void reset() {
			source.resetReader();
			configFiles.resetReader();
			semanticFiles.resetReader();
			result.resetWriter();
		}
	
		@Override
		public void run() throws SaxonApiException {
	
			super.run();
			
			try {

				Map<String,String> settings = new HashMap<String,String>();
				settings.put("lineEnd", "\\n");
				
				// Get options
				RuntimeValue paged = getOption(_paged);
				RuntimeValue pageHeight = getOption(_page_height);
				RuntimeValue lineWidth = getOption(_line_width);
				if (paged != null && paged.getString().equals("false")) {
					settings.put("braillePages", "no");
				}
				if (pageHeight!=null) {
					settings.put("linesPerPage", pageHeight.getString());
				}
				if (lineWidth != null) {
					settings.put("cellsPerLine", lineWidth.getString());
				}
	
				File tempDir = new File(new URI(getOption(_temp_dir).getString()));
	
				// Get configuration files
				List<String> configFileNames = new ArrayList<String>();
				if (configFiles != null) {
					XdmNode dir = (XdmNode)configFiles.read().axisIterator(Axis.CHILD, c_directory).next();
					File configDir = new File(dir.getBaseURI());
					if (!configDir.equals(tempDir)) {
						throw new XProcException(step.getNode(),
								"All config-files must be placed in temp-dir");
					}
					XdmSequenceIterator files = dir.axisIterator(Axis.CHILD, c_file);
					while (files != null && files.hasNext()) {
						configFileNames.add(((XdmNode)files.next()).getAttributeValue(_name));
					}
				}
	
				// Get semantic action files
				List<String> semanticFileNames = new ArrayList<String>();
				if (semanticFiles != null) {
					XdmNode dir = (XdmNode)semanticFiles.read().axisIterator(Axis.CHILD, c_directory).next();
					File semanticDir = new File(dir.getBaseURI());
					if (!semanticDir.equals(tempDir)) {
						throw new XProcException(step.getNode(),
								"All semantic-files must be placed in temp-dir");
					}
					XdmSequenceIterator files = dir.axisIterator(Axis.CHILD, c_file);
					while (files != null && files.hasNext()) {
						semanticFileNames.add(((XdmNode)files.next()).getAttributeValue(_name));
					}
				}
	
				// Create liblouistutdml.ini
				unpackIniFile(new URI(getOption(_ini_file).getString()).toURL(), tempDir);
	
				// Write XML document to file
				XdmNode xml = source.read();
				File xmlFile = File.createTempFile("liblouisutdml.", ".xml", tempDir);
				Serializer serializer = new Serializer(xmlFile);
				serializer.serializeNode(xml);
				serializer.close();
	
				File bodyTempFile = new File(tempDir + File.separator + "lbx_body.temp");
				bodyTempFile.delete();
	
				// Convert using file2brl
				File brailleFile = File.createTempFile("liblouisutdml.", ".txt", tempDir);
				liblouisutdml.translateFile(configFileNames, semanticFileNames, getOption(_table).getString(), settings, xmlFile, brailleFile, tempDir, tempDir);
				//xmlFile.delete();
				
				// Read the braille document and wrap it in a new XML document
				ByteBuffer buffer = ByteBuffer.allocate((int)brailleFile.length());
				byte[] bytes;
				int available;
				
				InputStream totalStream = new FileInputStream(brailleFile);
				while((available = totalStream.available()) > 0) {
					bytes = new byte[available];
					totalStream.read(bytes);
					buffer.put(bytes);
				}
				totalStream.close();
				int bodyLength = 0;
				try {
					// On Windows, a "\r" is always added although the configuration says "lineEnd \n"
					InputStream bodyStream = new NormalizeEndOfLineInputStream(new FileInputStream(bodyTempFile));
					while((available = bodyStream.available()) > 0)
						bodyLength += bodyStream.skip(available);
					bodyStream.close();
				} catch (FileNotFoundException e) {
				}
				assert buffer.position() >= bodyLength;
				buffer.flip();

				TreeWriter treeWriter = new TreeWriter(runtime);
				treeWriter.startDocument(step.getNode().getBaseURI());
				treeWriter.addStartElement(louis_output);
				treeWriter.startContent();
				if (bodyLength > 0) {
					treeWriter.addStartElement(louis_section);
					treeWriter.startContent();
					bytes = new byte[buffer.remaining() - bodyLength];
					buffer.get(bytes);
					treeWriter.addText(new String(bytes, "UTF-8"));
					treeWriter.addEndElement();
					treeWriter.addStartElement(louis_section);
					treeWriter.startContent();
					bytes = new byte[buffer.remaining()];
					buffer.get(bytes);
					treeWriter.addText(new String(bytes, "UTF-8"));
					treeWriter.addEndElement();
				} else {
					bytes = new byte[buffer.remaining()];
					buffer.get(bytes);
					treeWriter.addText(new String(bytes, "UTF-8"));
				}
				treeWriter.addEndElement();
				treeWriter.endDocument();
	
				//brailleFile.delete();
	
				result.write(treeWriter.getResult());
	
			} catch (Exception e) {
				throw new XProcException(step.getNode(), e);
			}
		}
	}
	
	private static void unpackIniFile(URL iniFile, File toDir) throws Exception {
		File toFile = new File(toDir.getAbsolutePath() + File.separator + "liblouisutdml.ini");
		toFile.createNewFile();
		FileOutputStream writer = new FileOutputStream(toFile);
		iniFile.openConnection();
		InputStream reader = iniFile.openStream();
		byte[] buffer = new byte[153600];
		int bytesRead = 0;
		while ((bytesRead = reader.read(buffer)) > 0) {
			writer.write(buffer, 0, bytesRead);
			buffer = new byte[153600];
		}
		writer.close();
		reader.close();
	}
}
