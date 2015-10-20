package org.daisy.pipeline.braille.dotify.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import com.google.common.base.Optional;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import static org.daisy.pipeline.braille.css.Query.serializeQuery;
import org.daisy.dotify.api.hyphenator.HyphenatorConfigurationException;
import org.daisy.dotify.api.hyphenator.HyphenatorInterface;
import org.daisy.dotify.api.hyphenator.HyphenatorFactoryService;

import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.Function;
import org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.logCreate;
import static org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.logSelect;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.TextTransform;
import org.daisy.pipeline.braille.common.Transform;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.varyLocale;
import org.daisy.pipeline.braille.common.util.Locales;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import org.daisy.pipeline.braille.dotify.DotifyHyphenator;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DotifyHyphenatorImpl extends AbstractTransform implements DotifyHyphenator {
	
	private HyphenatorInterface hyphenator;
	
	protected DotifyHyphenatorImpl(HyphenatorInterface hyphenator) {
		this.hyphenator = hyphenator;
	}
	
	public HyphenatorInterface asHyphenatorInterface() {
		return hyphenator;
	}
	
	public String transform(String text) {
		return hyphenator.hyphenate(text);
	}
	
	public String[] transform(String[] text) {
		throw new UnsupportedOperationException();
	}
	
	@Component(
		name = "org.daisy.pipeline.braille.dotify.DotifyHyphenatorImpl.Provider",
		service = {
			DotifyHyphenator.Provider.class,
			TextTransform.Provider.class,
			Hyphenator.Provider.class
		}
	)
	public static class Provider extends AbstractTransform.Provider<DotifyHyphenator>
	                             implements DotifyHyphenator.Provider {
		
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
		public Iterable<DotifyHyphenator> _get(String query) {
			Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.remove("hyphenator")) != null)
				if (!o.get().equals("dotify"))
					return empty;
			return logSelect(serializeQuery(q), _provider);
		}
		
		private final static Iterable<DotifyHyphenator> empty = Iterables.<DotifyHyphenator>empty();
		
		private Transform.Provider<DotifyHyphenator> _provider
		= varyLocale(
			new AbstractTransform.Provider<DotifyHyphenator>() {
				public Iterable<DotifyHyphenator> _get(String query) {
					Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
					Optional<String> o;
					if ((o = q.remove("locale")) != null) {
						final String locale = Locales.toString(parseLocale(o.get()), '-');
						if (q.size() > 0) {
							logger.warn("Unsupported feature '"+ q.keySet().iterator().next() + "'");
							return empty; }
						return Iterables.transform(
							factoryServices,
							new Function<HyphenatorFactoryService,DotifyHyphenator>() {
								public DotifyHyphenator _apply(HyphenatorFactoryService service) {
									try {
										if (service.supportsLocale(locale))
											return __apply(
												logCreate(
													(DotifyHyphenator)new DotifyHyphenatorImpl(service.newFactory().newHyphenator(locale)))); }
									catch (HyphenatorConfigurationException e) {
										logger.error("Could not create HyphenatorInterface for locale " + locale, e); }
									throw new NoSuchElementException();
								}
							}
						);
					}
					return empty;
				}
			}
		);
		
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
			invalidateCache();
		}
		
		protected void unbindHyphenatorFactoryService(HyphenatorFactoryService service) {
			factoryServices.remove(service);
			invalidateCache();
		}
		
		private static final Logger logger = LoggerFactory.getLogger(Provider.class);
		
	}
}
