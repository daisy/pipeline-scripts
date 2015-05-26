package org.daisy.pipeline.braille.pef.calabash;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.URI;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.braille.pef.TextHandler;
import org.daisy.braille.table.TableCatalog;

import org.daisy.common.xproc.calabash.XProcStepProvider;

import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Text2PEFStep extends DefaultStep {
	
	private ReadablePipe source = null;
	private WritablePipe result = null;
	
	private static final QName _temp_dir = new QName("temp-dir");
	private static final QName _table = new QName("table");
	private static final QName _title = new QName("title");
	private static final QName _creator = new QName("creator");
	private static final QName _duplex = new QName("duplex");
	
	private final TableCatalog tableCatalog;
	
	private Text2PEFStep(XProcRuntime runtime, XAtomicStep step, TableCatalog tableCatalog) {
		super(runtime, step);
		this.tableCatalog = tableCatalog;
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
			TextHandler.Builder b = new TextHandler.Builder(textFile, pefFile, tableCatalog);
			b.title(getOption(_title, ""));
			b.author(getOption(_creator, ""));
			b.duplex(getOption(_duplex, false));
			b.converterId(getOption(_table).getString());
			TextHandler handler = b.build();
			handler.parse();
			textFile.delete();
			
			// Read PEF document
			XdmNode pef = runtime.getProcessor().newDocumentBuilder().build(pefFile);
			pefFile.delete();
			result.write(pef); }
		
		catch (Exception e) {
			logger.error("pef:text2pef failed", e);
			throw new XProcException(step.getNode(), e); }
	}
	
	@Component(
		name = "pef:text2pef",
		service = { XProcStepProvider.class },
		property = { "type:String={http://www.daisy.org/ns/2008/pef}text2pef" }
	)
	public static class Provider implements XProcStepProvider {
		
		@Override
		public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
			// depend on spifly for now
			setTableCatalog(TableCatalog.newInstance());
			return new Text2PEFStep(runtime, step, tableCatalog);
		}
		
		private TableCatalog tableCatalog;
		
		/*@Reference(
			name = "TableCatalog",
			unbind = "-",
			service = TableCatalog.class,
			cardinality = ReferenceCardinality.MANDATORY,
			policy = ReferencePolicy.STATIC
		)*/
		public void setTableCatalog(TableCatalog catalog) {
			tableCatalog = catalog;
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(Text2PEFStep.class);
	
}
