package org.daisy.pipeline.braille.libhyphen;

import java.net.URI;
import java.util.Locale;
import java.util.Map;
import java.util.NoSuchElementException;

import org.osgi.service.component.ComponentContext;

import org.daisy.pipeline.braille.BundledResourcePath;
import org.daisy.pipeline.braille.ResourceLookup;

import com.google.common.base.Functions;
import com.google.common.base.Predicates;

import static com.google.common.base.Functions.toStringFunction;

import com.google.common.collect.Iterables;

import static org.daisy.pipeline.braille.Utilities.Predicates.matchesGlobPattern;
import static org.daisy.pipeline.braille.Utilities.URLs.decode;
import static org.daisy.pipeline.braille.Utilities.URIs.asURI;

public class LibhyphenTablePath extends BundledResourcePath implements LibhyphenTableLookup {
	
	@Override
	protected void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		if (properties.get(UNPACK) != null)
			throw new IllegalArgumentException(UNPACK + " property not supported");
		super.activate(context, properties);
		lazyUnpack(context);
	}
	
	/**
	 * Lookup a table based on a locale, using the fact that table names are
	 * always in the form `hyph_language[_COUNTRY[_variant]].dic`
	 */
	public URI lookup(Locale locale) {
		return lookup.lookup(locale);
	}
	
	private ResourceLookup<Locale,URI> lookup = new CachedLookup<Locale,URI>() {
		public URI delegate(Locale locale) {
			String language = locale.getLanguage().toLowerCase();
			String country = locale.getCountry().toUpperCase();
			String variant = locale.getVariant().toLowerCase();
			URI resource = null;
			if (!"".equals(variant))
				resource = asURI(String.format("hyph_%s_%s_%s.dic", language, country, variant));
			else if (!"".equals(country))
				resource = asURI(String.format("hyph_%s_%s.dic", language, country));
			else {
				resource = asURI(String.format("hyph_%s.dic", language));
				if (!resources.contains(resource))
					try {
						return Iterables.<URI>find(
							resources,
							Predicates.compose(
								matchesGlobPattern(String.format("hyph_%s_*.dic", language)),
								Functions.compose(decode, toStringFunction()))); }
					catch (NoSuchElementException e) {}}
			if (resources.contains(resource))
				return canonicalize(resource);
			return null;
		}
	};
}
