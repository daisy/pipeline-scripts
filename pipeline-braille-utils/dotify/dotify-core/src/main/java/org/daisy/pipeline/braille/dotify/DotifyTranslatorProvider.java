package org.daisy.pipeline.braille.dotify;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import com.google.common.base.Optional;

import static org.daisy.braille.css.Query.parseQuery;
import org.daisy.dotify.api.translator.BrailleTranslator;
import org.daisy.dotify.api.translator.BrailleTranslatorFactory;
import org.daisy.dotify.api.translator.BrailleTranslatorFactoryService;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;
import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.TextTransform;
import org.daisy.pipeline.braille.common.util.Locales;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.dotify.DotifyTranslatorProvider",
	service = { DotifyTranslatorProvider.class, TextTransform.Provider.class }
)
public class DotifyTranslatorProvider implements TextTransform.Provider<DotifyTranslator> {
	
	/**
	 * Try to find a translator based on the given locale.
	 * An automatic fallback mechanism is used: if nothing is found for
	 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
	 */
	public Iterable<DotifyTranslator> get(Locale query) {
		return translators.get(query);
	}
	
	public Iterable<DotifyTranslator> get(String query) {
		Map<String,Optional<String>> q = parseQuery(query);
		if (q.containsKey("translator"))
			if (!"dotify".equals(q.get("translator").get()))
				return Optional.<DotifyTranslator>absent().asSet();
		if (q.containsKey("locale"))
			return get(parseLocale(q.get("locale").get()));
		return Optional.<DotifyTranslator>absent().asSet();
	}
	
	private final List<BrailleTranslatorFactoryService> factoryServices = new ArrayList<BrailleTranslatorFactoryService>();
	
	@Reference(
		name = "BrailleTranslatorFactoryService",
		unbind = "unbindBrailleTranslatorFactoryService",
		service = BrailleTranslatorFactoryService.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	protected void bindBrailleTranslatorFactoryService(BrailleTranslatorFactoryService service) {
		factoryServices.add(service);
		translators.invalidateCache();
	}
	
	protected void unbindBrailleTranslatorFactoryService(BrailleTranslatorFactoryService service) {
		factoryServices.remove(service);
		translators.invalidateCache();
	}
	
	private BrailleTranslator newTranslator(String locale, String grade) throws TranslatorConfigurationException {
		for (BrailleTranslatorFactoryService s : factoryServices)
			if (s.supportsSpecification(locale, grade))
				return s.newFactory().newTranslator(locale, grade);
		throw new RuntimeException("Cannot locate a factory for "
		                           + locale.toLowerCase() + "(" + grade.toUpperCase() + ")");
	}
	
	private final CachedProvider<Locale,DotifyTranslator> translators
		= CachedProvider.<Locale,DotifyTranslator>newInstance(
			new LocaleBasedProvider<Locale,DotifyTranslator>() {
				public Iterable<DotifyTranslator> delegate(Locale locale) {
					try {
						BrailleTranslator translator = newTranslator(
							Locales.toString(locale, '-'), BrailleTranslatorFactory.MODE_UNCONTRACTED);
						translator.setHyphenating(false);
						return Optional.<DotifyTranslator>of(new DotifyTranslator(translator)).asSet(); }
					catch (TranslatorConfigurationException e) {
						logger.warn("Could not create translator for locale " + locale, e); }
					return Optional.<DotifyTranslator>absent().asSet(); }});
	
	private static final Logger logger = LoggerFactory.getLogger(DotifyTranslatorProvider.class);
	
}
