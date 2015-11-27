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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import com.google.common.base.Optional;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;

import org.daisy.braille.api.embosser.EmbosserWriter;
import org.daisy.braille.api.embosser.LineBreaks;
import org.daisy.braille.api.embosser.StandardLineBreaks;
import org.daisy.braille.api.table.BrailleConverter;
import org.daisy.braille.api.table.Table;
import org.daisy.braille.pef.PEFHandler;
import org.daisy.braille.pef.PEFHandler.Alignment;
import org.daisy.braille.pef.UnsupportedWidthException;
import org.daisy.common.xproc.calabash.XProcStepProvider;

import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;

import org.daisy.pipeline.braille.pef.TableProvider;
import org.daisy.pipeline.braille.pef.calabash.impl.BRFWriter.Padding;
import org.daisy.pipeline.braille.pef.calabash.impl.BRFWriter.PageBreaks;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import static org.daisy.pipeline.braille.css.Query.serializeQuery;

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
	// TODO:
	// private static final QName _line_breaks = new QName("line-breaks");
	// private static final QName _page_breaks = new QName("page-breaks");
	private static final QName _pad = new QName("pad");
	
	private final org.daisy.pipeline.braille.common.Provider<String,Table> tableProvider;
	
	private ReadablePipe source = null;
	
	private PEF2TextStep(XProcRuntime runtime,
	                     XAtomicStep step,
	                     org.daisy.pipeline.braille.common.Provider<String,Table> tableProvider) {
		super(runtime, step);
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
			
			Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(
				parseQuery(getOption(_table).getString()));
			
			final LineBreaks lineBreaks; {
				String s = getOption(_breaks, "DEFAULT");
				Optional<String> o;
				if ((o = q.remove("line-breaks")) != null)
					s = o.get();
				lineBreaks = new StandardLineBreaks(StandardLineBreaks.Type.valueOf(s.toUpperCase())); }
			final PageBreaks pageBreaks; {
				String s = "\u000c";
				Optional<String> o;
				if ((o = q.remove("page-breaks")) != null)
					s = o.get();
				final String pb = s;
				pageBreaks = new PageBreaks() {
					public String getString() {
						return pb; }}; }
			final BrailleConverter brailleConverter; {
				String tableQuery = serializeQuery(q);
				Table table;
				try {
					table = tableProvider.get(tableQuery).iterator().next(); }
				catch (NoSuchElementException e) {
					logger.warn("pef:pef2text failed, table not found: " + tableQuery, e);
					table = tableProvider.get(
						"(id:'org.daisy.braille.impl.table.DefaultTableProvider.TableType.EN_US')").iterator().next(); }
				brailleConverter = table.newBrailleConverter(); }
			final Padding padding = Padding.valueOf(getOption(_pad, "NONE").toUpperCase());
			
			// Create EmbosserWriter
			final OutputStream textStream = new FileOutputStream(new File(new URI(getOption(_href).getString())));
			EmbosserWriter writer = new BRFWriter() {
				public LineBreaks getLinebreakStyle() {
					return lineBreaks;
				}
				public PageBreaks getPagebreakStyle() {
					return pageBreaks;
				}
				public Padding getPaddingStyle() {
					return padding;
				}
				public BrailleConverter getTable() {
					return brailleConverter;
				}
				protected void add(byte b) throws IOException {
					textStream.write(b);
				}
				protected void addAll(byte[] b) throws IOException {
					textStream.write(b);
				}
			};
			
			// Read PEF
			ByteArrayOutputStream s = new ByteArrayOutputStream();
			Serializer serializer = new Serializer(s);
			serializer.serializeNode(source.read());
			serializer.close();
			InputStream pefStream = new ByteArrayInputStream(s.toByteArray());
			s.close();
			
			// Parse PEF to text
			PEFHandler.Builder builder = new PEFHandler.Builder(writer);
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
			return new PEF2TextStep(runtime, step, tableProvider);
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
