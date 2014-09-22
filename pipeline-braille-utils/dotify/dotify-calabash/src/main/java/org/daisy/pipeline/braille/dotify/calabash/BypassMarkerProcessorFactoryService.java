package org.daisy.pipeline.braille.dotify.calabash;

import org.daisy.dotify.api.translator.MarkerProcessor;
import org.daisy.dotify.api.translator.MarkerProcessorConfigurationException;
import org.daisy.dotify.api.translator.MarkerProcessorFactory;
import org.daisy.dotify.api.translator.MarkerProcessorFactoryService;
import org.daisy.dotify.api.translator.TextAttribute;

import static org.daisy.pipeline.braille.Utilities.Strings.join;

public class BypassMarkerProcessorFactoryService implements MarkerProcessorFactoryService {
	
	public boolean supportsSpecification(String locale, String mode) {
		return OBFLToPEFProvider.MODE_BYPASS.equals(mode);
	}
	
	public MarkerProcessorFactory newFactory() {
		return new BypassMarkerProcessorFactory();
	}
	
	private class BypassMarkerProcessorFactory implements MarkerProcessorFactory {
		public MarkerProcessor newMarkerProcessor(String locale, String mode) throws MarkerProcessorConfigurationException {
			if (OBFLToPEFProvider.MODE_BYPASS.equals(mode))
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
