package org.daisy.pipeline.braille;

import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

import com.google.common.base.Function;
import com.google.common.collect.ImmutableMap;

import org.daisy.pipeline.braille.Utilities.Function2;

public interface ResourceLookup<Q,R> {
	
	/**
	 * Lookup resources based on a key.
	 * @param key
	 * @return The resources associated with the key, or null if no resource can be found.
	 */
	public R lookup(Q query);
	
	public static class NULL<Q,R> implements ResourceLookup<Q,R> {
		public R lookup(Q key) {
			return null;
		}
	}
	
	public static abstract class CachedLookup<Q,R> extends Cached<Q,R> implements ResourceLookup<Q,R> {
		public R lookup(Q query) {
			return get(query);
		}
		public static <Q,R> CachedLookup<Q,R> newInstance(final ResourceLookup<Q,R> delegate) {
			return new CachedLookup<Q,R>() {
				public R delegate(Q query) {
					return delegate.lookup(query);
				}
			};
		}
	}
	
	public static abstract class PropertiesLookup<Q,R> implements ResourceLookup<Q,R> {
		private Map<Q,String> map;
		public abstract Q parseKey(String key);
		public abstract R parseValue(String value);
		public PropertiesLookup(URL properties) {
			map = readProperties(properties);
		}
		public R lookup(Q query) {
			String value = map.get(query);
			if (value != null)
				return parseValue(value);
			return null;
		}
		private Map<Q,String> readProperties(URL url) {
			Map<Q,String> map = new HashMap<Q,String>();
			try {
				url.openConnection();
				InputStream reader = url.openStream();
				Properties properties = new Properties();
				properties.loadFromXML(reader);
				for (String key : properties.stringPropertyNames()) {
					Q query = parseKey(key);
					if (!map.containsKey(query))
						map.put(query, properties.getProperty(key)); }
				reader.close();
				return new ImmutableMap.Builder<Q,String>().putAll(map).build(); }
			catch (Exception e) {
				throw new RuntimeException("Could not read properties file " + url, e); }
		}
		public static <Q,R> PropertiesLookup<Q,R> newInstance(URL properties,
		                                                      final Function<String,Q> parseKey,
		                                                      final Function<String,R> parseValue) {
			return new PropertiesLookup<Q,R>(properties) {
				public Q parseKey(String key) {
					return parseKey.apply(key);
				}
				public R parseValue(String value) {
					return parseValue.apply(value);
				}
			};
		}
	}
	
	public static abstract class DispatchingLookup<Q,R> implements ResourceLookup<Q,R> {
		public abstract Iterable<? extends ResourceLookup<Q,R>> dispatch();
		public R lookup(Q query) {
			for (ResourceLookup<Q,R> lookup : dispatch()) {
				R resource = lookup.lookup(query);
				if (resource != null)
					return resource; }
			return null;
		}
		public static <Q,R> DispatchingLookup<Q,R> newInstance(final Iterable<? extends ResourceLookup<Q,R>> dispatch) {
			return new DispatchingLookup<Q,R>() {
				public Iterable<? extends ResourceLookup<Q,R>> dispatch() {
					return dispatch;
				}
			};
		}
	}
	
	public static abstract class LocaleBasedLookup<Q,R> implements ResourceLookup<Q,R> {
		public abstract R delegate(Q query);
		public abstract Locale getLocale(Q query);
		public abstract Q assocLocale(Q query, Locale locale);
		public R lookup(Q query) {
			Locale locale = getLocale(query);
			if ("".equals(locale.toString()))
				return null;
			if (!"".equals(locale.getVariant())) {
				R resource = delegate(query);
				if (resource != null)
					return resource; }
			if (!"".equals(locale.getCountry())) {
				R resource = delegate(assocLocale(query, new Locale(locale.getLanguage(), locale.getCountry())));
				if (resource != null)
					return resource; }
			if (!"".equals(locale.getLanguage())) {
				R resource = delegate(assocLocale(query, new Locale(locale.getLanguage())));
				if (resource != null)
					return resource; }
			return null;
		}
		public static <Q,R> LocaleBasedLookup<Q,R> newInstance(final ResourceLookup<Q,R> delegate,
		                                                       final Function<Q,Locale> getLocale,
		                                                       final Function2<Q,Locale,Q> assocLocale) {
			return new LocaleBasedLookup<Q,R>() {
				public R delegate(Q query) {
					return delegate.lookup(query);
				}
				public Locale getLocale(Q query) {
					return getLocale.apply(query);
				}
				public Q assocLocale(Q query, Locale locale) {
					return assocLocale.apply(query, locale);
				}
			};
		}
		public static <R> LocaleBasedLookup<Locale,R> newInstance(final ResourceLookup<Locale,R> delegate) {
			return new LocaleBasedLookup<Locale,R>() {
				public R delegate(Locale locale) {
					return delegate.lookup(locale);
				}
				public Locale getLocale(Locale query) {
					return query;
				}
				public Locale assocLocale(Locale query, Locale locale) {
					return locale;
				}
			};
		}
	}
	
}
