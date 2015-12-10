package org.daisy.pipeline.braille.dotify.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import com.google.common.base.Optional;
import com.google.common.base.Splitter;
import com.google.common.collect.ImmutableMap;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import static org.daisy.pipeline.braille.css.Query.serializeQuery;

import org.daisy.dotify.api.translator.BrailleFilter;
import org.daisy.dotify.api.translator.BrailleFilterFactoryService;
import org.daisy.dotify.api.translator.BrailleTranslatorFactory;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;

import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Function;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables.concat;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logCreate;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logSelect;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.TextTransform;
import org.daisy.pipeline.braille.common.TransformProvider;
import static org.daisy.pipeline.braille.common.TransformProvider.util.dispatch;
import static org.daisy.pipeline.braille.common.TransformProvider.util.memoize;
import static org.daisy.pipeline.braille.common.TransformProvider.util.varyLocale;
import org.daisy.pipeline.braille.common.util.Locales;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import org.daisy.pipeline.braille.dotify.DotifyTranslator;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DotifyTranslatorImpl extends AbstractTransform implements DotifyTranslator {
	
	private final BrailleFilter filter;
	private final boolean hyphenating;
	private final Hyphenator externalHyphenator;
	
	private final static Splitter.MapSplitter CSS_PARSER
		= Splitter.on(';').omitEmptyStrings().withKeyValueSeparator(Splitter.on(':').limit(2).trimResults());
	
	protected DotifyTranslatorImpl(BrailleFilter filter, boolean hyphenating) {
		this.filter = filter;
		this.hyphenating = hyphenating;
		this.externalHyphenator = null;
	}
	
	protected DotifyTranslatorImpl(BrailleFilter filter, Hyphenator externalHyphenator) {
		this.filter = filter;
		this.hyphenating = true;
		this.externalHyphenator = externalHyphenator;
	}
	
	public BrailleFilter asBrailleFilter() {
		return filter;
	}
	
	public boolean isHyphenating() {
		return hyphenating;
	}
	
	private String transform(String text, boolean hyphenate) {
		if (hyphenate && !hyphenating)
			throw new RuntimeException("'hyphens:auto' is not supported");
		try {
			if (hyphenate && externalHyphenator != null)
				return filter.filter(Translatable.text(externalHyphenator.transform(text)).hyphenate(false).build());
			else
				return filter.filter(Translatable.text(text).hyphenate(hyphenate).build()); }
		catch (TranslationException e) {
			throw new RuntimeException(e); }
	}
	
	public String transform(String text) {
		return transform(text, false);
	}
	
	public String[] transform(String[] text) {
		String[] result = new String[text.length];
		for (int i = 0; i < text.length; i++)
			result[i] = transform(text[i]);
		return result;
	}
	
	public String transform(String text, String cssStyle) {
		boolean hyphenate = false;
		Map<String,String> style = new HashMap<String,String>(CSS_PARSER.split(cssStyle));
		for (String prop : style.keySet()) {
			if ("hyphens".equals(prop)) {
				String val = style.get(prop);
				if ("auto".equals(val))
					hyphenate = true;
				else if (!"manual".equals(val))
					logger.warn("{}:{} not supported", prop, val); }
			else
				logger.warn("CSS property {} not supported", prop); }
		return transform(text, hyphenate);
	}
	
	public String[] transform(String[] text, String[] cssStyle) {
		String[] result = new String[text.length];
		for (int i = 0; i < text.length; i++)
			result[i] = transform(text[i], cssStyle[i]);
		return result;
	}
	
	@Component(
		name = "org.daisy.pipeline.braille.dotify.DotifyTranslatorImpl.Provider",
		service = {
			DotifyTranslator.Provider.class,
			BrailleTranslator.Provider.class,
			TextTransform.Provider.class
		}
	)
	public static class Provider extends AbstractTransformProvider<DotifyTranslator>
	                             implements DotifyTranslator.Provider {
		
		/**
		 * Recognized features:
		 *
		 * - translator: Will only match if the value is `dotify'.
		 * - locale: Required. Matches only Dotify translators for that locale. An automatic
		 *     fallback mechanism is used: if nothing is found for language-COUNTRY-variant, then
		 *     language-COUNTRY is searched, then language.
		 * - hyphenator: A value `none' will disable hyphenation. `auto' is the default and will
		 *     match any Dotify translator, whether it supports hyphenation out-of-the-box, with the
		 *     help of an external hyphenator, or not at all. A value not equal to `none' or `auto'
		 *     will match every Dotify translator that uses an external hyphenator that matches this
		 *     feature.
		 *
		 * No other features are allowed.
		 */
		public Iterable<DotifyTranslator> _get(String query) {
			Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.remove("translator")) != null)
				if (!o.get().equals("dotify"))
					return empty;
			return logSelect(serializeQuery(q), _provider);
		}
		
		private final static Iterable<DotifyTranslator> empty = Iterables.<DotifyTranslator>empty();
		
		private TransformProvider<DotifyTranslator> _provider
		= varyLocale(
			new AbstractTransformProvider<DotifyTranslator>() {
				public Iterable<DotifyTranslator> _get(String query) {
					Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
					Optional<String> o;
					if ((o = q.remove("locale")) != null) {
						final String locale = Locales.toString(parseLocale(o.get()), '-');
						final String mode = BrailleTranslatorFactory.MODE_UNCONTRACTED;
						final String hyphenator = ((o = q.remove("hyphenator")) != null) ? o.get() : "auto";
						if (q.size() > 0) {
							logger.warn("Unsupported feature '"+ q.keySet().iterator().next() + "'");
							return empty; }
						Iterable<BrailleFilter> filters = Iterables.transform(
							factoryServices,
							new Function<BrailleFilterFactoryService,BrailleFilter>() {
								public BrailleFilter _apply(BrailleFilterFactoryService service) {
									try {
										if (service.supportsSpecification(locale, mode))
											return service.newFactory().newFilter(locale, mode); }
									catch (TranslatorConfigurationException e) {
										logger.error("Could not create BrailleFilter for locale " + locale + " and mode " + mode, e); }
									throw new NoSuchElementException(); }});
						return concat(
							Iterables.transform(
								filters,
								new Function<BrailleFilter,Iterable<DotifyTranslator>>() {
									public Iterable<DotifyTranslator> _apply(final BrailleFilter filter) {
										Iterable<DotifyTranslator> translators = empty;
										if (!"none".equals(hyphenator)) {
											ImmutableMap.Builder<String,Optional<String>> hyphenatorQuery
												= new ImmutableMap.Builder<String,Optional<String>>();
											if (!"auto".equals(hyphenator))
												hyphenatorQuery.put("hyphenator", Optional.of(hyphenator));
											hyphenatorQuery.put("locale", Optional.of(locale));
											Iterable<Hyphenator> hyphenators = logSelect(
												serializeQuery(hyphenatorQuery.build()), hyphenatorProvider);
											translators = Iterables.transform(
												hyphenators,
												new Function<Hyphenator,DotifyTranslator>() {
													public DotifyTranslator _apply(Hyphenator hyphenator) {
														return __apply(
															logCreate(
																(DotifyTranslator)new DotifyTranslatorImpl(filter, hyphenator))); }}); }
										if ("auto".equals(hyphenator))
											translators = concat(
												translators,
												Iterables.of(
													logCreate((DotifyTranslator)new DotifyTranslatorImpl(filter, true))));
										if ("none".equals(hyphenator))
											translators = concat(
												translators,
												Iterables.of(
													logCreate((DotifyTranslator)new DotifyTranslatorImpl(filter, false))));
										return translators;
									}
								}
							)
						);
					}
					return empty;
				}
			}
		);
		
		private final List<BrailleFilterFactoryService> factoryServices = new ArrayList<BrailleFilterFactoryService>();
		
		@Reference(
			name = "BrailleFilterFactoryService",
			unbind = "unbindBrailleFilterFactoryService",
			service = BrailleFilterFactoryService.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void bindBrailleFilterFactoryService(BrailleFilterFactoryService service) {
			factoryServices.add(service);
			invalidateCache();
		}
		
		protected void unbindBrailleFilterFactoryService(BrailleFilterFactoryService service) {
			factoryServices.remove(service);
			invalidateCache();
		}
		
		@Reference(
			name = "HyphenatorProvider",
			unbind = "unbindHyphenatorProvider",
			service = Hyphenator.Provider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		@SuppressWarnings(
			"unchecked" // safe cast to TransformProvider<Hyphenator>
		)
		protected void bindHyphenatorProvider(Hyphenator.Provider<?> provider) {
			hyphenatorProviders.add((TransformProvider<Hyphenator>)provider);
			hyphenatorProvider.invalidateCache();
			logger.debug("Adding Hyphenator provider: " + provider);
		}
		
		protected void unbindHyphenatorProvider(Hyphenator.Provider<?> provider) {
			hyphenatorProviders.remove(provider);
			hyphenatorProvider.invalidateCache();
			logger.debug("Removing Hyphenator provider: " + provider);
		}
		
		private List<TransformProvider<Hyphenator>> hyphenatorProviders
		= new ArrayList<TransformProvider<Hyphenator>>();
		
		private TransformProvider.util.MemoizingProvider<Hyphenator> hyphenatorProvider
		= memoize(dispatch(hyphenatorProviders));
		
	}
	
	private static final Logger logger = LoggerFactory.getLogger(DotifyTranslatorImpl.class);
}
