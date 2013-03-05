package org.daisy.pipeline.braille;

import java.net.URL;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public abstract class TableRegistry<T extends BundledTablePath> extends ResourceRegistry<T> implements ResourceLookup<Locale> {
	
	@Override
	protected void register(T path) {
		super.register(path);
		lookupCache.clear();
	}
	
	@Override
	protected void unregister(T path) {
		super.unregister(path);
		lookupCache.clear();
	}
	
	/*
	 * ResourceLookup<Locale>
	 */
	
	/**
	 * Try to find a table based on the given locale.
	 * An automatic fallback mechanism is used: if nothing is found for
	 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
	 */
	public URL lookup(Locale locale) {
		if ("".equals(locale.toString()))
			return null;
		if (lookupCache.containsKey(locale))
			return lookupCache.get(locale);
		if (!"".equals(locale.getVariant())) {
			for (T path : paths.values()) {
				URL table = path.lookup(locale);
				if (table != null) {
					lookupCache.put(locale, table);
					return table; }}}
		if (!"".equals(locale.getCountry())) {
			for (T path : paths.values()) {
				URL table = path.lookup(new Locale(locale.getLanguage(), locale.getCountry()));
				if (table != null) {
					lookupCache.put(locale, table);
					return table; }}}
		if (!"".equals(locale.getLanguage())) {
			for (T path : paths.values()) {
				URL table = path.lookup(new Locale(locale.getLanguage()));
				if (table != null) {
					lookupCache.put(locale, table);
					return table; }}}
		return null;
	}
	
	private final Map<Locale,URL> lookupCache = new HashMap<Locale,URL>();
	
}
