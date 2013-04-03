package org.daisy.pipeline.braille.libhyphen;

import java.net.URL;
import java.util.Locale;
import java.util.Map;
import java.util.NoSuchElementException;

import org.osgi.service.component.ComponentContext;

import org.daisy.pipeline.braille.BundledResourcePath;
import org.daisy.pipeline.braille.TablePath;

import com.google.common.collect.Iterables;

import static org.daisy.pipeline.braille.Utilities.Files.resolveURL;
import static org.daisy.pipeline.braille.Utilities.Predicates.matchesPattern;

public class LibhyphenTablePath extends BundledResourcePath implements TablePath {
	
	@Override
	protected void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		super.activate(context, properties);
		lazyUnpack(context);
	}
	
	/**
	 * Lookup a table based on a locale, using the fact that table names are
	 * always in the form `hyph_language[_COUNTRY[_variant]].dic`
	 */
	public URL lookup(Locale locale) {
		String language = locale.getLanguage().toLowerCase();
		String country = locale.getCountry().toUpperCase();
		String variant = locale.getVariant().toLowerCase();
		String fileName = null;
		if (!"".equals(variant))
			fileName = String.format("hyph_%s_%s_%s.dic", language, country, variant);
		else if (!"".equals(country))
			fileName = String.format("hyph_%s_%s.dic", language, country);
		else {
			fileName = String.format("hyph_%s.dic", language);
			if (!includes(fileName))
				try {
					fileName = Iterables.<String>find(
						resources,
						matchesPattern(String.format("^hyph_%s_.*\\.dic$", language))); }
				catch (NoSuchElementException e) {}}
		if (includes(fileName))
			return resolveURL(identifier, fileName);
		return null;
	}
}