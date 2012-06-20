package org.daisy.common.xproc.calabash.steps.liblouisxml;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmSequenceIterator;

import org.daisy.pipeline.liblouis.LiblouisTableRegistry;
import org.daisy.pipeline.liblouis.Liblouisutdml;

import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;

public class XML2BRL extends DefaultStep {

	private static final String TABLE_SET_ID
		= "org.daisy.common.xproc.calabash.steps.liblouisxml.IdentityLiblouisTableSet";

	private static final QName lblxml_output
		= new QName("lblxml", "http://xmlcalabash.com/ns/extensions/liblouisxml", "output");
	private static final QName lblxml_section
		= new QName("lblxml", "http://xmlcalabash.com/ns/extensions/liblouisxml", "section");
	// private static final QName lblxml_page
	//	= new QName("lblxml", "http://xmlcalabash.com/ns/extensions/liblouisxml", "page");

	private static final QName _paged = new QName("paged");
	private static final QName _page_height = new QName("page-height");
	private static final QName _line_width = new QName("line-width");
	private static final QName _temp_dir = new QName("temp-dir");
	private static final QName c_directory = new QName("http://www.w3.org/ns/xproc-step", "directory");
	private static final QName c_file = new QName("http://www.w3.org/ns/xproc-step", "file");
	private static final QName _name = new QName("name");

	private static URL iniFile;
	private static final String[] tables = new String[]{"nabcc.dis", "braille-patterns.cti", "pagenum.cti"};

	public static void setIniFile(URL iniFile) {
		XML2BRL.iniFile = iniFile;
	}

	private ReadablePipe source = null;
	private ReadablePipe configFiles = null;
	private ReadablePipe semanticFiles = null;
	private WritablePipe result = null;

	/**
	 * Creates a new instance of XML2BRL
	 */
	public XML2BRL(XProcRuntime runtime, XAtomicStep step) {
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

			// Get options
			Map<String,String> settings = new HashMap<String,String>();
			RuntimeValue paged = getOption(_pages);
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
			unpackIniFile(tempDir);

			// Write XML document to file
			XdmNode xml = source.read();
			File xmlFile = File.createTempFile("liblouisutdml.", ".xml", tempDir);
			Serializer serializer = new Serializer(xmlFile);
			serializer.serializeNode(xml);
			serializer.close();

			File bodyTempFile = new File(tempDir + File.separator + "lbx_body.temp");
			bodyTempFile.delete();

			// Convert using xml2brl
			File brailleFile = File.createTempFile("liblouisutdml.", ".txt", tempDir);
			Liblouisutdml.file2brl(configFileNames, semanticFileNames, Arrays.asList(tables), settings, xmlFile, brailleFile, null,
			 		LiblouisTableRegistry.getLouisTablePath(TABLE_SET_ID), tempDir);
			//xmlFile.delete();

			// Read the braille document and wrap it in a new XML document
			long totalLength = brailleFile.length();
			long bodyLength = bodyTempFile.exists() ? bodyTempFile.length() : totalLength;
			long frontLength = totalLength - bodyLength;
			InputStream brailleStream = new FileInputStream(brailleFile);
			byte[] buffer;

			TreeWriter treeWriter = new TreeWriter(runtime);
			treeWriter.startDocument(step.getNode().getBaseURI());
			treeWriter.addStartElement(lblxml_output);
			treeWriter.startContent();
			if (frontLength > 0) {
				treeWriter.addStartElement(lblxml_section);
				treeWriter.startContent();
				buffer = new byte[(int)frontLength];
				brailleStream.read(buffer);
				treeWriter.addText(new String(buffer, "UTF-8"));
				treeWriter.addEndElement();
				treeWriter.addStartElement(lblxml_section);
				treeWriter.startContent();
				buffer = new byte[(int)bodyLength];
				brailleStream.read(buffer);
				treeWriter.addText(new String(buffer, "UTF-8"));
				treeWriter.addEndElement();
			} else {
				buffer = new byte[(int)totalLength];
				brailleStream.read(buffer);
				treeWriter.addText(new String(buffer, "UTF-8"));
			}
			treeWriter.addEndElement();
			treeWriter.endDocument();

			brailleStream.close();
			//brailleFile.delete();

			result.write(treeWriter.getResult());

		} catch (Exception e) {
			throw new XProcException(step.getNode(), e);
		}
	}

	private static void unpackIniFile(File toDir) throws Exception {
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
