package org.daisy.pipeline.braille.dotify.impl;

import org.daisy.dotify.api.translator.MarkerProcessor;
import org.daisy.dotify.api.translator.MarkerProcessorConfigurationException;
import org.daisy.dotify.api.translator.MarkerProcessorFactory;
import org.daisy.dotify.api.translator.MarkerProcessorFactoryService;
import org.daisy.dotify.api.translator.TextAttribute;

import static org.daisy.pipeline.braille.common.util.Strings.join;

import org.osgi.service.component.annotations.Component;

@Component(
	name = "org.daisy.pipeline.braille.dotify.impl.MarkerProcessorFactoryServiceImpl",
	service = { MarkerProcessorFactoryService.class }
)
public class MarkerProcessorFactoryServiceImpl implements MarkerProcessorFactoryService {
	
	public boolean supportsSpecification(String locale, String mode) {
		return BrailleTranslatorFactoryServiceImpl.MODE.matcher(mode).matches();
	}
	
	public MarkerProcessorFactory newFactory() {
		return new MarkerProcessorFactoryImpl();
	}
	
	@SuppressWarnings("serial")
	private class MarkerProcessorFactoryImpl implements MarkerProcessorFactory {
		public MarkerProcessor newMarkerProcessor(String locale, String mode) throws MarkerProcessorConfigurationException {
			if (BrailleTranslatorFactoryServiceImpl.MODE.matcher(mode).matches())
				return new MarkerProcessorImpl();
			throw new MarkerProcessorConfigurationException("Factory does not support " + locale + "/" + mode) {};
		}
	}
	
	private static class MarkerProcessorImpl implements MarkerProcessor {
		public String processAttributes(TextAttribute atts, String... text){
			return join(processAttributesRetain(atts, text), "");
		}
		public String[] processAttributesRetain(TextAttribute atts, String[] text) {
			return text;
		}
	}
}
