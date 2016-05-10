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

import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;

import org.daisy.braille.api.embosser.EmbosserWriter;
import org.daisy.braille.api.embosser.FileFormat;
import org.daisy.braille.api.table.Table;
import org.daisy.braille.pef.PEFHandler;
import org.daisy.braille.pef.PEFHandler.Alignment;
import org.daisy.braille.pef.UnsupportedWidthException;

import org.daisy.common.xproc.calabash.XProcStepProvider;

import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.query;
import org.daisy.pipeline.braille.pef.FileFormatProvider;
import org.daisy.pipeline.braille.pef.TableProvider;

import org.xml.sax.SAXException;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PEF2TextStep extends DefaultStep {
	
	private static final QName _href = new QName("href");
	private static final QName _file_format = new QName("file-format");
	private static final QName _table = new QName("table");
	private static final QName _line_breaks = new QName("line-breaks");
	private static final QName _page_breaks = new QName("page-breaks");
	private static final QName _pad = new QName("pad");
	
	private static final Query EN_US = mutableQuery().add("id", "org.daisy.braille.impl.table.DefaultTableProvider.TableType.EN_US");
	
	private final org.daisy.pipeline.braille.common.Provider<Query,FileFormat> fileFormatProvider;
	private final org.daisy.pipeline.braille.common.Provider<Query,Table> tableProvider;
	
	private ReadablePipe source = null;
	
	private PEF2TextStep(XProcRuntime runtime,
	                     XAtomicStep step,
	                     org.daisy.pipeline.braille.common.Provider<Query,FileFormat> fileFormatProvider,
	                     org.daisy.pipeline.braille.common.Provider<Query,Table> tableProvider) {
		super(runtime, step);
		this.fileFormatProvider = fileFormatProvider;
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
		MutableQuery q = mutableQuery(query(getOption(_file_format, "")));
		addOption(_line_breaks, q);
		addOption(_page_breaks, q);
		addOption(_pad, q);
		RuntimeValue tableQuery = getOption(_table);
		if (tableQuery != null) {
			Table table;
			try {
				table = tableProvider.get(query(tableQuery.getString())).iterator().next(); }
			catch (NoSuchElementException e) {
				
				// this fallback is done because in dtbook-to-pef we use the
				// query (locale:...) which does not always match something
				// FIXME: https://github.com/daisy/pipeline-mod-braille/issues/75
				logger.warn("Table " + tableQuery.toString() + " not found, falling back to en-US table.");
				table = tableProvider.get(EN_US).iterator().next(); }
			q.add("table", table.getIdentifier()); }
		
		Iterable<FileFormat> fileFormats = fileFormatProvider.get(q);
		if (!fileFormats.iterator().hasNext()) {
			logger.error("pef:pef2text failed: no file format found for query: " + q);
			throw new XProcException(step.getNode(), "pef:pef2text failed: no file format found for query: " + q); }
		for (FileFormat fileFormat : fileFormats) {
			try {
				logger.debug("Storing PEF to file format: " + fileFormat);
				
				// Create EmbosserWriter
				File textFile = new File(new URI(getOption(_href).getString()));
				textFile.getParentFile().mkdirs();
				OutputStream textStream = new FileOutputStream(textFile);
				EmbosserWriter writer = fileFormat.newEmbosserWriter(textStream);
				
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
				textStream.close();
				return; }
			catch (Exception e) {
				logger.error("Storing PEF to file format '" + fileFormat + "' failed", e); }}
		logger.error("pef:pef2text failed");
		throw new XProcException(step.getNode(), "pef:pef2text failed");
	}
	
	private void addOption(QName option, MutableQuery query) {
		RuntimeValue v = getOption(option);
		if (v != null)
			query.add(option.getLocalName(), v.getString());
	}
	
	@Component(
		name = "pef:pef2text",
		service = { XProcStepProvider.class },
		property = { "type:String={http://www.daisy.org/ns/2008/pef}pef2text" }
	)
	public static class Provider implements XProcStepProvider {
		
		@Override
		public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
			return new PEF2TextStep(runtime, step, fileFormatProvider, tableProvider);
		}
		
		@Reference(
			name = "FileFormatProvider",
			unbind = "unbindFileFormatProvider",
			service = FileFormatProvider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void bindFileFormatProvider(FileFormatProvider provider) {
			fileFormatProviders.add(provider);
		}
		
		protected void unbindFileFormatProvider(FileFormatProvider provider) {
			fileFormatProviders.remove(provider);
			this.fileFormatProvider.invalidateCache();
		}
		
		private List<FileFormatProvider> fileFormatProviders = new ArrayList<FileFormatProvider>();
		private org.daisy.pipeline.braille.common.Provider.util.MemoizingProvider<Query,FileFormat> fileFormatProvider
		= memoize(dispatch(fileFormatProviders));
		
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
		private org.daisy.pipeline.braille.common.Provider.util.MemoizingProvider<Query,Table> tableProvider
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
