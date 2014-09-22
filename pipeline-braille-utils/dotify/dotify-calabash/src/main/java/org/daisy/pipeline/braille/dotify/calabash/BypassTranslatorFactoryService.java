package org.daisy.pipeline.braille.dotify.calabash;

import java.util.Collection;
import java.util.regex.Matcher;
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
		return OBFLToPEFProvider.MODE_BYPASS.equals(mode);
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
			if (OBFLToPEFProvider.MODE_BYPASS.equals(mode))
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
		
		private final static Pattern integers = Pattern.compile("[0-9]+");
		
		// for translating page numbers
		private static String translateIntegers(String text) {
			Matcher m = integers.matcher(text);
			int idx = 0;
			StringBuilder sb = new StringBuilder();
			for (; m.find(); idx = m.end()) {
				sb.append(text.substring(idx, m.start()));
				try {
					sb.append(translateInteger(Integer.parseInt(m.group()))); }
				catch (Exception e) {
					throw new RuntimeException("Coding error", e); }}
			if (idx == 0)
				return text;
			sb.append(text.substring(idx));
			return sb.toString();
		}
		
		private final static String numsign = "\u283c";
		
		private final static String[] digitTable = new String[]{
			"\u281a","\u2801","\u2803","\u2809","\u2819","\u2811","\u280b","\u281b","\u2813","\u280a"};
		
		private static String translateInteger(int integer) {
			StringBuilder sb = new StringBuilder();
			sb.append(numsign);
			if (integer == 0)
				sb.append(digitTable[0]);
			while (integer > 0) {
				sb.insert(1, digitTable[integer % 10]);
				integer = integer / 10; }
			return sb.toString();
		}
		
		// for calculating margin character (see org.daisy.dotify.formatter.impl.FormatterContext)
		private static String translateSpace(String text) {
			return text.replaceAll(" ", "\u2800");
		}
		
		private final static Pattern softHyphens = Pattern.compile("[\u00ad\u200b]+");
		
		private static String filterOutSoftHyphens(String text) {
			return softHyphens.matcher(text).replaceAll("");
		}
		
		private String doTranslate(String text) {
			text = translateSpace(text);
			text = translateIntegers(text);
			if (!isHyphenating())
				text = filterOutSoftHyphens(text);
			return text;
		}
		
		public BrailleTranslatorResult translate(String text) {
			
			final BreakPointHandler bph = new BreakPointHandler(doTranslate(text));
			
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
			return OBFLToPEFProvider.MODE_BYPASS;
		}
	}
}
