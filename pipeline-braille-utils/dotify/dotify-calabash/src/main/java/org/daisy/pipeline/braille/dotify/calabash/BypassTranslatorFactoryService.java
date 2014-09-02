package org.daisy.pipeline.braille.dotify.calabash;

import java.util.Collection;
import java.util.regex.Pattern;

import com.google.common.collect.ImmutableList;

import org.daisy.dotify.api.translator.BrailleTranslator;
import org.daisy.dotify.api.translator.BrailleTranslatorFactory;
import org.daisy.dotify.api.translator.BrailleTranslatorFactoryService;
import org.daisy.dotify.api.translator.BrailleTranslatorResult;
import org.daisy.dotify.api.translator.TextAttribute;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;
import org.daisy.dotify.api.translator.TranslatorSpecification;
import org.daisy.dotify.text.BreakPointHandler;

/**
 * BrailleTranslator that handles pre-translated and pre-hyphenated text.
 */
public class BypassTranslatorFactoryService implements BrailleTranslatorFactoryService {
	
	public boolean supportsSpecification(String locale, String mode) {
		return BrailleTranslatorFactory.MODE_BYPASS.equals(mode);
	}
	
	public Collection<TranslatorSpecification> listSpecifications() {
		return ImmutableList.<TranslatorSpecification>of();
	}
	
	public BrailleTranslatorFactory newFactory() {
		return new BypassTranslatorFactory();
	}
	
	public <T> void setReference(Class<T> c, T reference) throws TranslatorConfigurationException {}
	
	private static class BypassTranslatorFactory implements BrailleTranslatorFactory {
		public BrailleTranslator newTranslator(String locale, String mode) throws TranslatorConfigurationException {
			if (BrailleTranslatorFactory.MODE_BYPASS.equals(mode))
				return new BypassTranslator();
			throw new TranslatorConfigurationException("Factory does not support " + locale + "/" + mode);
		}
	}
	
	private static class BypassTranslator implements BrailleTranslator {
		
		private boolean hyphenating;
		
		public void setHyphenating(boolean value){
			hyphenating = value;
		}
		
		public boolean isHyphenating() {
			return hyphenating;
		}
		
		private final static Pattern softHyphens = Pattern.compile("[\u00ad\u200b]+");
		
		private static String filterOutSoftHyphens(String text) {
			return softHyphens.matcher(text).replaceAll("");
		}
		
		public BrailleTranslatorResult translate(String text) {
			
			final BreakPointHandler bph = new BreakPointHandler(isHyphenating() ? text : filterOutSoftHyphens(text));
			
			return new BrailleTranslatorResult() {
				public String nextTranslatedRow(int limit, boolean force) {
					return bph.nextRow(limit, force).getHead();
				}
				public String getTranslatedRemainder() {
					return bph.getRemaining();
				}
				public int countRemaining() {
					return getTranslatedRemainder().length();
				}
				public boolean hasNext() {
					return bph.hasNext();
				}
			};
		}
		
		public BrailleTranslatorResult translate(String text, String locale) {
			return translate(text);
		}
		
		public BrailleTranslatorResult translate(String text, TextAttribute atts) {
			return translate(text);
		}
		
		public BrailleTranslatorResult translate(String text, String locale, TextAttribute attributes) throws TranslationException {
			return translate(text);
		}
		
		public String getTranslatorMode() {
			return BrailleTranslatorFactory.MODE_BYPASS;
		}
	}
}
