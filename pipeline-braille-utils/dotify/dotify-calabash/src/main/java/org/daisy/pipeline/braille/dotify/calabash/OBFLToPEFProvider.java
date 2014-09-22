package org.daisy.pipeline.braille.dotify.calabash;

import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;
import java.io.InputStream;

import java.util.ArrayList;
import java.util.List;

import javax.xml.transform.stream.StreamSource;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;

import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;

import org.daisy.common.xproc.calabash.XProcStepProvider;

import org.daisy.dotify.api.engine.FormatterEngine;
import org.daisy.dotify.api.engine.FormatterEngineFactoryService;
import org.daisy.dotify.api.writer.MediaTypes;
import org.daisy.dotify.api.writer.PagedMediaWriter;
import org.daisy.dotify.api.writer.PagedMediaWriterConfigurationException;
import org.daisy.dotify.api.writer.PagedMediaWriterFactoryService;

import org.daisy.pipeline.braille.Cached;

public class OBFLToPEFProvider implements XProcStepProvider {
	
	/* Use special bypass mode so that
	 * - BypassTranslatorFactoryService and BypassMarkerProcessorFactoryService
	 *   from this package are used instead of the default ones in
	 *   dotify.impl.translator
	 * - BrailleTextBorderFactoryService from dotify.impl.translator (which
	 *   for some reason doesn't support mode "bypass") can be used
	 */
	protected final static String MODE_BYPASS = "pipeline_bypass";
	
	private List<PagedMediaWriterFactoryService> pagedMediaWriterFactoryServices
		= new ArrayList<PagedMediaWriterFactoryService>();
	
	protected void bindPagedMediaWriterFactoryService(PagedMediaWriterFactoryService service) {
		pagedMediaWriterFactoryServices.add(service);
	}
	
	protected void unbindPagedMediaWriterFactoryService(PagedMediaWriterFactoryService service) {
		pagedMediaWriterFactoryServices.remove(service);
		pagedMediaWriterFactoryServiceForTarget.invalidateCache();
	}
	
	private Cached<String,PagedMediaWriterFactoryService> pagedMediaWriterFactoryServiceForTarget
		= new Cached<String,PagedMediaWriterFactoryService>() {
			public PagedMediaWriterFactoryService delegate(String target) {
				target = target.toLowerCase();
				for (PagedMediaWriterFactoryService s : pagedMediaWriterFactoryServices)
					if (s.supportsMediaType(target))
						return s;
				throw new RuntimeException("Cannot find a PagedMediaWriter factory for " + target);
			}
		};
	
	private PagedMediaWriter newPagedMediaWriter(String target) throws PagedMediaWriterConfigurationException {
		return pagedMediaWriterFactoryServiceForTarget.get(target).newFactory(target).newPagedMediaWriter();
	}
	
	private FormatterEngineFactoryService formatterEngineFactoryService = null;
	
	protected void bindFormatterEngineFactoryService(FormatterEngineFactoryService service) {
		formatterEngineFactoryService = service;
	}
	
	protected void unbindFormatterEngineFactoryService(FormatterEngineFactoryService service) {
		formatterEngineFactoryService = null;
	}
	
	private FormatterEngine newFormatterEngine(String locale, String mode, PagedMediaWriter writer) {
		return formatterEngineFactoryService.newFormatterEngine(locale, mode, writer);
	}
	
	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new OBFLToPEF(runtime, step);
	}
	
	public class OBFLToPEF extends DefaultStep {
	
		private ReadablePipe source = null;
		private WritablePipe result = null;
		
		private OBFLToPEF(XProcRuntime runtime, XAtomicStep step) {
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
				
				// Read OBFL
				ByteArrayOutputStream s = new ByteArrayOutputStream();
				Serializer serializer = new Serializer(s);
				serializer.serializeNode(source.read());
				serializer.close();
				InputStream obflStream = new ByteArrayInputStream(s.toByteArray());
				s.close();
				
				// Convert
				PagedMediaWriter writer = newPagedMediaWriter(MediaTypes.PEF_MEDIA_TYPE);
				FormatterEngine engine = newFormatterEngine("und", MODE_BYPASS, writer); // zxx
				s = new ByteArrayOutputStream();
				engine.convert(obflStream, s);
				obflStream.close();
				InputStream pefStream = new ByteArrayInputStream(s.toByteArray());
				s.close();
				
				// Write PEF
				result.write(runtime.getProcessor().newDocumentBuilder().build(new StreamSource(pefStream)));
				pefStream.close();
				
			} catch (Exception e) {
				
				e.printStackTrace();
				
				throw new RuntimeException(e); }
		}
	}
}
