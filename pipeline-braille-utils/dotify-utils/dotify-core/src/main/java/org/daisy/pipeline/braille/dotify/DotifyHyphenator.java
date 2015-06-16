package org.daisy.pipeline.braille.dotify;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import com.google.common.base.Optional;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import org.daisy.dotify.api.hyphenator.HyphenatorConfigurationException;
import org.daisy.dotify.api.hyphenator.HyphenatorInterface;
import org.daisy.dotify.api.hyphenator.HyphenatorFactoryService;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.TextTransform;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.util.Locales;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DotifyHyphenator implements Hyphenator {
	
	private HyphenatorInterface hyphenator;
	
	protected DotifyHyphenator(HyphenatorInterface hyphenator) {
		this.hyphenator = hyphenator;
	}
	
	public String transform(String text) {
		return hyphenator.hyphenate(text);
	}
	
	public String[] transform(String[] text) {
		throw new UnsupportedOperationException();
	}
	
	public HyphenatorInterface asHyphenatorInterface() {
		return hyphenator;
	}
	
	@Component(
		name = "org.daisy.pipeline.braille.dotify.DotifyHyphenator.Provider",
		service = {
			DotifyHyphenator.Provider.class,
			TextTransform.Provider.class,
			Hyphenator.Provider.class
		}
	)
	public static class Provider implements Hyphenator.Provider<DotifyHyphenator> {
		
		public Transform.Provider<DotifyHyphenator> withContext(Logger context) {
			return this;
		}
		
		/**
		 * Try to find a translator based on the given locale.
		 * An automatic fallback mechanism is used: if nothing is found for
		 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
		 */
		public Iterable<DotifyHyphenator> get(Locale query) {
			return hyphenators.get(query);
		}
		
		/**
		 * Recognized features:
		 *
		 * - hyphenator: Will only match if the value is `dotify'.
		 * - locale: Required. Matches only Dotify translators for that locale. An
		 *     automatic fallback mechanism is used: if nothing is found for
		 *     language-COUNTRY-variant, then language-COUNTRY is searched, then language.
		 *
		 * No other features are allowed.
		 */
		public Iterable<DotifyHyphenator> get(String query) {
			Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.remove("hyphenator")) != null)
				if (!o.get().equals("dotify"))
					return empty;
			if ((o = q.remove("locale")) != null)
				if (q.isEmpty())
					return get(parseLocale(o.get()));
			return empty;
		}
		
		private final static Iterable<DotifyHyphenator> empty = Optional.<DotifyHyphenator>absent().asSet();
		
		private final List<HyphenatorFactoryService> factoryServices = new ArrayList<HyphenatorFactoryService>();
		
		@Reference(
			name = "HyphenatorFactoryService",
			unbind = "unbindHyphenatorFactoryService",
			service = HyphenatorFactoryService.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void bindHyphenatorFactoryService(HyphenatorFactoryService service) {
			factoryServices.add(service);
			hyphenators.invalidateCache();
		}
		
		protected void unbindHyphenatorFactoryService(HyphenatorFactoryService service) {
			factoryServices.remove(service);
			hyphenators.invalidateCache();
		}
		
		private HyphenatorInterface newHyphenator(String locale) throws HyphenatorConfigurationException {
			for (HyphenatorFactoryService s : factoryServices)
				if (s.supportsLocale(locale))
					return s.newFactory().newHyphenator(locale);
			throw new RuntimeException("Cannot locate a factory for " + locale.toLowerCase());
		}
		
		private final CachedProvider<Locale,DotifyHyphenator> hyphenators
		= CachedProvider.<Locale,DotifyHyphenator>newInstance(
			new LocaleBasedProvider<Locale,DotifyHyphenator>() {
				public Iterable<DotifyHyphenator> delegate(Locale locale) {
					try {
						HyphenatorInterface hyphenator = newHyphenator(Locales.toString(locale, '-'));
						return Optional.<DotifyHyphenator>of(new DotifyHyphenator(hyphenator)).asSet(); }
					catch (Exception e) {
						logger.warn("Could not create hyphenator for locale " + locale, e); }
					return Optional.<DotifyHyphenator>absent().asSet(); }});
		
		private static final Logger logger = LoggerFactory.getLogger(Provider.class);
		
	}
}
