package org.daisy.pipeline.braille.pef;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;

import org.daisy.braille.embosser.Embosser;
import org.daisy.braille.embosser.EmbosserCatalog;
import org.daisy.braille.embosser.EmbosserFeatures;
import org.daisy.braille.facade.PEFConverterFacade;
import org.daisy.braille.pef.PEFHandler;
import org.daisy.braille.pef.PEFHandler.Alignment;
import org.daisy.common.xproc.calabash.XProcStepProvider;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;

public class PEF2TextProvider implements XProcStepProvider {
	
	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new Text2PEF(runtime, step);
	}
	
	public static class Text2PEF extends DefaultStep {
		
		private static final QName _href = new QName("href");
		private static final QName _table = new QName("table");
		private static final QName _breaks = new QName("breaks");
		private static final QName _pad = new QName("pad");
		
		private static final Embosser embosser = EmbosserCatalog.newInstance()
				.get("org_daisy.GenericEmbosserProvider.EmbosserType.NONE");
		
		private ReadablePipe source = null;
		
		private Text2PEF(XProcRuntime runtime, XAtomicStep step) {
			super(runtime, step);
		}
		
		@Override
		public void setInput(String port, ReadablePipe pipe) {
			source = pipe;
		}
		
		@Override
		public void reset() {
			source.resetReader();
		}
		
		@Override
		public void run() throws SaxonApiException {
			super.run();
			try {
				
				// Read PEF
				ByteArrayOutputStream s = new ByteArrayOutputStream();
				Serializer serializer = new Serializer(s);
				serializer.serializeNode(source.read());
				serializer.close();
				InputStream pefStream = new ByteArrayInputStream(s.toByteArray());
				s.close();
				
				// Configure embosser
				embosser.setFeature(EmbosserFeatures.TABLE, getOption(_table).getString());
				embosser.setFeature("breaks", getOption(_breaks, "DEFAULT"));
				embosser.setFeature("padNewline", getOption(_pad, "NONE"));
				
				// Parse PEF to text
				OutputStream textStream = new FileOutputStream(
						new File(new URI(getOption(_href).getString())));
				PEFHandler.Builder builder = new PEFHandler.Builder(embosser.newEmbosserWriter(textStream));
				builder.range(null).align(Alignment.LEFT).offset(0);
				PEFConverterFacade.parsePefFile(pefStream, builder.build());
				pefStream.close();
				textStream.close(); }
			
			catch (Exception e) {
				throw new RuntimeException(e); }
		}
	}
}
