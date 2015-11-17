package org.daisy.pipeline.braille.dotify.impl;

import org.daisy.dotify.api.translator.BrailleFilter;
import org.daisy.dotify.api.translator.MarkerProcessor;
import org.daisy.dotify.api.translator.MarkerProcessorConfigurationException;
import org.daisy.dotify.api.translator.MarkerProcessorFactory;
import org.daisy.dotify.api.translator.MarkerProcessorFactoryService;
import org.daisy.dotify.api.translator.TextAttribute;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;

import static org.daisy.pipeline.braille.common.util.Strings.join;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

@Component(
	name = "org.daisy.pipeline.braille.dotify.impl.MarkerProcessorFactoryServiceImpl",
	service = { MarkerProcessorFactoryService.class }
)
public class MarkerProcessorFactoryServiceImpl implements MarkerProcessorFactoryService {
	
	private BrailleFilterFactoryImpl filterFactory;
	
	@Reference(
		name = "BrailleFilterFactoryImpl",
		service = BrailleFilterFactoryImpl.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindBrailleFilterFactoryImpl(BrailleFilterFactoryImpl filterFactory) {
		this.filterFactory = filterFactory;
	}
	
	public boolean supportsSpecification(String locale, String mode) {
		try {
			filterFactory.newFilter(locale, mode);
			return true; }
		catch (TranslatorConfigurationException e) {
			return false; }
	}
	
	public MarkerProcessorFactory newFactory() {
		return new MarkerProcessorFactoryImpl();
	}
	
	@SuppressWarnings("serial")
	private class MarkerProcessorFactoryImpl implements MarkerProcessorFactory {
		public MarkerProcessor newMarkerProcessor(String locale, String mode) throws MarkerProcessorConfigurationException {
			try {
				return new MarkerProcessorImpl(filterFactory.newFilter(locale, mode)); }
			catch (TranslatorConfigurationException e) {
				throw new MarkerProcessorConfigurationException(e) {}; }
		}
	}
	
	private static class MarkerProcessorImpl implements MarkerProcessor {
		
		private final BrailleFilter filter;
		
		private MarkerProcessorImpl(BrailleFilter filter) {
			this.filter = filter;
		}
		
		public String processAttributes(TextAttribute atts, String... text) {
			return join(processAttributesRetain(atts, text));
		}
		
		// FIXME: don't ignore text attributes!
		public String[] processAttributesRetain(TextAttribute atts, String[] text) {
			return text;
		}
	}
}
