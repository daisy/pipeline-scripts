package org.daisy.common.xproc.calabash.steps.liblouisxml;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.net.URI;

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

	private static final QName lblxml_formatted_braille
		= new QName("lblxml", "http://xmlcalabash.com/ns/extensions/liblouisxml", "formatted-braille-file");
	private static final QName _temp_dir = new QName("temp-dir");

	private final File configPath;
	private final String[] tables = new String[]{"nabcc.dis", "braille-patterns.cti", "pagenum.cti"};
	private final String[] configFiles = new String[]{"styles.cfg"};
	private final String[] semanticFiles = new String[]{"html.sem"};
	private ReadablePipe source = null;
	private WritablePipe result = null;

	/**
	 * Creates a new instance of Identity
	 */
	public XML2BRL(XProcRuntime runtime, XAtomicStep step, File configPath) {
		super(runtime, step);
		this.configPath = configPath;
	}

	@Override
	public void setInput(String port, ReadablePipe pipe) {
		source = pipe;
	}

	@Override
	public void setOutput(String port, WritablePipe pipe) {
		result = pipe;
	}

	@Override
	public void reset() {
		source.resetReader();
		result.resetWriter();
	}

	@Override
	public void run() throws SaxonApiException {
		super.run();

		try {

			File tempDir = new File(new URI(getOption(_temp_dir).getString()));
			XdmNode xml = source.read();

			// Write XML document to file
			File xmlFile = File.createTempFile("liblouisxml.", ".xml", tempDir);
			Serializer serializer = new Serializer(xmlFile);
			serializer.serializeNode(xml);
			serializer.close();

			// Convert using xml2brl
			File textFile = File.createTempFile("liblouisxml.", ".txt", tempDir);
			Liblouisxml.xml2brl(configFiles, semanticFiles, tables, null, xmlFile, textFile, configPath,
					LiblouisTableRegistry.getLouisTablePath(), tempDir);
			//xmlFile.delete();

			// Read the text document...
			InputStream textStream = new FileInputStream(textFile);
			byte[] buffer = new byte[(int)textFile.length()];
			textStream.read(buffer);
			textStream.close();
			//textFile.delete();

			// and wrap it in a new XML document
			TreeWriter treeWriter = new TreeWriter(runtime);
			treeWriter.startDocument(step.getNode().getBaseURI());
			treeWriter.addStartElement(lblxml_formatted_braille);
			treeWriter.startContent();
			treeWriter.addText(new String(buffer, "UTF-8"));
			treeWriter.addEndElement();
			treeWriter.endDocument();

			result.write(treeWriter.getResult());

		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}
}
