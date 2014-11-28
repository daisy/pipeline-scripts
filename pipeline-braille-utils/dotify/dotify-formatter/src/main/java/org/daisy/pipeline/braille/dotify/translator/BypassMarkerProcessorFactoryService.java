package org.daisy.pipeline.braille.dotify.translator;

import org.daisy.dotify.api.translator.MarkerProcessor;
import org.daisy.dotify.api.translator.MarkerProcessorConfigurationException;
import org.daisy.dotify.api.translator.MarkerProcessorFactory;
import org.daisy.dotify.api.translator.MarkerProcessorFactoryService;
import org.daisy.dotify.api.translator.TextAttribute;

import static org.daisy.pipeline.braille.common.util.Strings.join;

import org.osgi.service.component.annotations.Component;

@Component(
	name = "org.daisy.pipeline.braille.dotify.translator.BypassMarkerProcessorFactoryService",
	service = { MarkerProcessorFactoryService.class }
)
public class BypassMarkerProcessorFactoryService implements MarkerProcessorFactoryService {
	
	public boolean supportsSpecification(String locale, String mode) {
		return BypassTranslatorFactoryService.MODE.equals(mode);
	}
	
	public MarkerProcessorFactory newFactory() {
		return new BypassMarkerProcessorFactory();
	}
	
	private class BypassMarkerProcessorFactory implements MarkerProcessorFactory {
		public MarkerProcessor newMarkerProcessor(String locale, String mode) throws MarkerProcessorConfigurationException {
			if (BypassTranslatorFactoryService.MODE.equals(mode))
				return new BypassMarkerProcessor();
			throw new MarkerProcessorConfigurationException("Factory does not support " + locale + "/" + mode) {};
		}
	}
	
	private static class BypassMarkerProcessor implements MarkerProcessor {
		public String processAttributes(TextAttribute atts, String... text){
			return join(processAttributesRetain(atts, text), "");
		}
		public String[] processAttributesRetain(TextAttribute atts, String[] text) {
			return text;
		}
	}
}
