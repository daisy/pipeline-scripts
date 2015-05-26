package org.daisy.pipeline.braille.pef.calabash;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URI;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;

import org.daisy.braille.embosser.Embosser;
import org.daisy.braille.embosser.EmbosserCatalog;
import org.daisy.braille.embosser.EmbosserFeatures;
import org.daisy.braille.embosser.UnsupportedWidthException;
import org.daisy.braille.pef.PEFHandler;
import org.daisy.braille.pef.PEFHandler.Alignment;
import org.daisy.common.xproc.calabash.XProcStepProvider;

import org.xml.sax.SAXException;

import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PEF2TextStep extends DefaultStep {
	
	private static final QName _href = new QName("href");
	private static final QName _table = new QName("table");
	private static final QName _breaks = new QName("breaks");
	private static final QName _pad = new QName("pad");
	
	private final Embosser embosser;
	
	private ReadablePipe source = null;
	
	private PEF2TextStep(XProcRuntime runtime, XAtomicStep step, Embosser embosser) {
		super(runtime, step);
		this.embosser = embosser;
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
			parsePefFile(pefStream, builder.build());
			pefStream.close();
			textStream.close(); }
		
		catch (Exception e) {
			logger.error("pef:pef2text failed", e);
			throw new XProcException(step.getNode(), e); }
	}
	
	@Component(
		name = "pef:pef2text",
		service = { XProcStepProvider.class },
		property = { "type:String={http://www.daisy.org/ns/2008/pef}pef2text" }
	)
	public static class Provider implements XProcStepProvider {
		
		@Override
		public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
			return new PEF2TextStep(runtime, step, embosserCatalog.get("org_daisy.GenericEmbosserProvider.EmbosserType.NONE"));
		}
		
		// depend on spifly for now
		private EmbosserCatalog embosserCatalog = EmbosserCatalog.newInstance();
		
		/*@Reference(
			name = "EmbosserCatalog",
			unbind = "-",
			service = EmbosserCatalog.class,
			cardinality = ReferenceCardinality.MANDATORY,
			policy = ReferencePolicy.STATIC
		)*/
		public void setEmbosserCatalog(EmbosserCatalog catalog) {
			embosserCatalog = catalog;
		}
	}
	
	// copied from org.daisy.braille.facade.PEFConverterFacade because it is no longer static
	/**
	 * Parses the given input stream using the supplied PEFHandler.
	 * @param is the input stream
	 * @param ph the PEFHandler
	 * @throws ParserConfigurationException
	 * @throws SAXException
	 * @throws IOException
	 * @throws UnsupportedWidthException
	 */
	private static void parsePefFile(InputStream is, PEFHandler ph)
			throws ParserConfigurationException, SAXException, IOException, UnsupportedWidthException {
		
		SAXParserFactory spf = SAXParserFactory.newInstance();
		spf.setNamespaceAware(true);
		SAXParser sp = spf.newSAXParser();
		try {
			sp.parse(is, ph); }
		catch (SAXException e) {
			if (ph.hasWidthError())
				throw new UnsupportedWidthException(e);
			else
				throw e; }
	}
	
	private static final Logger logger = LoggerFactory.getLogger(PEF2TextStep.class);
	
}
