package org.daisy.pipeline.braille.pef.calabash.impl;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URI;
import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;

import org.daisy.braille.api.embosser.Embosser;
import org.daisy.braille.api.embosser.EmbosserCatalogService;
import org.daisy.braille.api.embosser.EmbosserFeatures;
import org.daisy.braille.api.table.Table;
import org.daisy.braille.pef.PEFHandler;
import org.daisy.braille.pef.PEFHandler.Alignment;
import org.daisy.braille.pef.UnsupportedWidthException;
import org.daisy.common.xproc.calabash.XProcStepProvider;
import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import org.daisy.pipeline.braille.pef.TableProvider;

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
	private final org.daisy.pipeline.braille.common.Provider<String,Table> tableProvider;
	
	private ReadablePipe source = null;
	
	private PEF2TextStep(XProcRuntime runtime,
	                     XAtomicStep step,
	                     Embosser embosser,
	                     org.daisy.pipeline.braille.common.Provider<String,Table> tableProvider) {
		super(runtime, step);
		this.embosser = embosser;
		this.tableProvider = tableProvider;
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
			
			String tableQuery = getOption(_table).getString();
			Table table = null;
			try {
				table = tableProvider.get(tableQuery).iterator().next(); }
			catch (NoSuchElementException e) {
				logger.error("pef:pef2text failed, table not found: " + tableQuery, e);
				table = tableProvider.get("(id:'org.daisy.braille.impl.table.DefaultTableProvider.TableType.EN_US')").iterator().next(); }
			
			// Read PEF
			ByteArrayOutputStream s = new ByteArrayOutputStream();
			Serializer serializer = new Serializer(s);
			serializer.serializeNode(source.read());
			serializer.close();
			InputStream pefStream = new ByteArrayInputStream(s.toByteArray());
			s.close();
			
			// Configure embosser
			embosser.setFeature(EmbosserFeatures.TABLE, table.getIdentifier());
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
			return new PEF2TextStep(runtime, step, embosserCatalog.newEmbosser("org_daisy.GenericEmbosserProvider.EmbosserType.NONE"), tableProvider);
		}
		
		private EmbosserCatalogService embosserCatalog;
		
		@Reference(
			name = "EmbosserCatalog",
			unbind = "-",
			service = EmbosserCatalogService.class,
			cardinality = ReferenceCardinality.MANDATORY,
			policy = ReferencePolicy.STATIC
		)
		public void setEmbosserCatalog(EmbosserCatalogService catalog) {
			embosserCatalog = catalog;
		}
		
		@Reference(
			name = "TableProvider",
			unbind = "unbindTableProvider",
			service = TableProvider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void bindTableProvider(TableProvider provider) {
			tableProviders.add(provider);
		}
		
		protected void unbindTableProvider(TableProvider provider) {
			tableProviders.remove(provider);
			this.tableProvider.invalidateCache();
		}
		
		private List<TableProvider> tableProviders = new ArrayList<TableProvider>();
		private org.daisy.pipeline.braille.common.Provider.MemoizingProvider<String,Table> tableProvider
		= memoize(dispatch(tableProviders));
		
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
