package org.daisy.common.xproc.calabash.steps.liblouisxml;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XdmNode;

import org.liblouis.LiblouisTableRegistry;
import org.liblouis.Liblouisxml;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;

public class XML2BRL extends DefaultStep {

	private static final QName lblxml_output
		= new QName("lblxml", "http://xmlcalabash.com/ns/extensions/liblouisxml", "output");
	private static final QName lblxml_section
		= new QName("lblxml", "http://xmlcalabash.com/ns/extensions/liblouisxml", "section");
	//private static final QName lblxml_page
	//	= new QName("lblxml", "http://xmlcalabash.com/ns/extensions/liblouisxml", "page");

	private static final QName _temp_dir = new QName("temp-dir");

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

			File tempDir = new File(new URI(getOption(_temp_dir).getString()));

			// Write config files
			List<String> configFileNames = new ArrayList<String>();
			unpackIniFile(tempDir);
			configFileNames.add("canonical.cfg");
			if (configFiles != null) {
				while(configFiles.moreDocuments()) {
					File configFile = File.createTempFile("liblouisxml.", ".cfg", tempDir);
					writeLiblouisxmlFile(configFiles.read(), configFile);
					configFileNames.add(configFile.getName());
				}
			}

			// Write semantic action files
			List<String> semanticFileNames = new ArrayList<String>();
			if (semanticFiles != null) {
				while(semanticFiles.moreDocuments()) {
					File semanticFile = File.createTempFile("liblouisxml.", ".sem", tempDir);
					writeLiblouisxmlFile(semanticFiles.read(), semanticFile);
					semanticFileNames.add(semanticFile.getName());
				}
			}

			// Write XML document to file
			XdmNode xml = source.read();
			File xmlFile = File.createTempFile("liblouisxml.", ".xml", tempDir);
			Serializer serializer = new Serializer(xmlFile);
			serializer.serializeNode(xml);
			serializer.close();

			File bodyTempFile = new File(tempDir + File.separator + "lbx_body.temp");
			bodyTempFile.delete();

			// Convert using xml2brl
			File textFile = File.createTempFile("liblouisxml.", ".txt", tempDir);
			Liblouisxml.xml2brl(configFileNames, semanticFileNames, Arrays.asList(tables), null, xmlFile, textFile, null,
					LiblouisTableRegistry.getLouisTablePath(), tempDir);
			//xmlFile.delete();

			// Read the text document and wrap it in a new XML document
			long totalLength = textFile.length();
			long bodyLength = bodyTempFile.exists() ? bodyTempFile.length() : totalLength;
			long frontLength = totalLength - bodyLength;
			InputStream textStream = new FileInputStream(textFile);
			byte[] buffer;

			TreeWriter treeWriter = new TreeWriter(runtime);
			treeWriter.startDocument(step.getNode().getBaseURI());
			treeWriter.addStartElement(lblxml_output);
			treeWriter.startContent();
			if (frontLength > 0) {
				treeWriter.addStartElement(lblxml_section);
				treeWriter.startContent();
				buffer = new byte[(int)frontLength];
				textStream.read(buffer);
				treeWriter.addText(new String(buffer, "UTF-8"));
				treeWriter.addEndElement();
				treeWriter.addStartElement(lblxml_section);
				treeWriter.startContent();
				buffer = new byte[(int)bodyLength];
				textStream.read(buffer);
				treeWriter.addText(new String(buffer, "UTF-8"));
				treeWriter.addEndElement();
			} else {
				buffer = new byte[(int)totalLength];
				textStream.read(buffer);
				treeWriter.addText(new String(buffer, "UTF-8"));
			}
			treeWriter.addEndElement();
			treeWriter.endDocument();

			textStream.close();
			//textFile.delete();

			result.write(treeWriter.getResult());

		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private static void unpackIniFile(File toDir) throws Exception {
		File to = new File(toDir.getAbsolutePath() + File.separator + "liblouisutdml.ini");
		to.createNewFile();
		FileOutputStream writer = new FileOutputStream(to);
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

	private static void writeLiblouisxmlFile(XdmNode node, File toFile) throws Exception {
		OutputStream textStream = new FileOutputStream(toFile);
		OutputStreamWriter writer = new OutputStreamWriter(textStream, "UTF-8");
		writer.write(node.getStringValue());
		writer.close();
	}
}
