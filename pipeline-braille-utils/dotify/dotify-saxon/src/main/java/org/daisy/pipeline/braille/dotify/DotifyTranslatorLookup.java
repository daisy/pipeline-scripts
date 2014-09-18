package org.daisy.pipeline.braille.dotify;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import org.daisy.dotify.api.translator.BrailleTranslator;
import org.daisy.dotify.api.translator.BrailleTranslatorFactory;
import org.daisy.dotify.api.translator.BrailleTranslatorFactoryService;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;
import org.daisy.pipeline.braille.ResourceLookup;
import org.daisy.pipeline.braille.Utilities.Locales;

public class DotifyTranslatorLookup implements ResourceLookup<Locale,BrailleTranslator> {
	
	/**
	 * Try to find a translator based on the given locale.
	 * An automatic fallback mechanism is used: if nothing is found for
	 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
	 */
	public BrailleTranslator lookup(Locale query) {
		return cachedLookup.lookup(query);
	}
	
	private final List<BrailleTranslatorFactoryService> factoryServices = new ArrayList<BrailleTranslatorFactoryService>();
	
	protected void bindBrailleTranslatorFactoryService(BrailleTranslatorFactoryService service) {
		factoryServices.add(service);
		cachedLookup.invalidateCache();
	}
	
	protected void unbindBrailleTranslatorFactoryService(BrailleTranslatorFactoryService service) {
		factoryServices.remove(service);
		cachedLookup.invalidateCache();
	}
	
	private BrailleTranslator newTranslator(String locale, String grade) throws TranslatorConfigurationException {
		for (BrailleTranslatorFactoryService s : factoryServices)
			if (s.supportsSpecification(locale, grade))
				return s.newFactory().newTranslator(locale, grade);
		throw new RuntimeException("Cannot locate a factory for "
		                           + locale.toLowerCase() + "(" + grade.toUpperCase() + ")");
	}
	
	private final ResourceLookup<Locale,BrailleTranslator> lookup
		= LocaleBasedLookup.<BrailleTranslator>newInstance(
			new ResourceLookup<Locale,BrailleTranslator>() {
				public BrailleTranslator lookup(Locale locale) {
					try {
						BrailleTranslator translator = newTranslator(
							Locales.toString(locale, '-'), BrailleTranslatorFactory.MODE_UNCONTRACTED);
						translator.setHyphenating(false);
						return translator; }
					catch (TranslatorConfigurationException e) {
						throw new RuntimeException(e); }
				}
			}
	);
	
	private final CachedLookup<Locale,BrailleTranslator> cachedLookup
		= CachedLookup.<Locale,BrailleTranslator>newInstance(lookup);
	
}
