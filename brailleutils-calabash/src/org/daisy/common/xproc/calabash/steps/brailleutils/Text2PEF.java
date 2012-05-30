package org.daisy.common.xproc.calabash.steps.brailleutils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.URI;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.braille.pef.TextHandler;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;

public class Text2PEF extends DefaultStep {

	private static final QName _temp_dir = new QName("temp-dir");

	private ReadablePipe source = null;
	private WritablePipe result = null;

	public Text2PEF(XProcRuntime runtime, XAtomicStep step) {
		super(runtime, step);
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
			XdmNode text = source.read();

			// Write text document to file
			File textFile = File.createTempFile("text2pef.", ".txt", tempDir);
			OutputStream textStream = new FileOutputStream(textFile);
			OutputStreamWriter writer = new OutputStreamWriter(textStream, "UTF-8");
			writer.write(text.getStringValue());
			writer.close();

			// Parse text to PEF
			File pefFile = File.createTempFile("text2pef.", ".pef", tempDir);
			TextHandler.Builder b = new TextHandler.Builder(textFile, pefFile);
			b.converterId("org_daisy.EmbosserTableProvider.TableType.NABCC");
			TextHandler handler = b.build();
			handler.parse();
			textFile.delete();

			// Read PEF document
	        XdmNode pef = runtime.getProcessor().newDocumentBuilder().build(pefFile);
	        pefFile.delete();
			result.write(pef);

		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}
}
