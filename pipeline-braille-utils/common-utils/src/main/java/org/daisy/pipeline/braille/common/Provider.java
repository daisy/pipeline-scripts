package org.daisy.pipeline.braille.common;

import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

import com.google.common.base.Function;
import com.google.common.collect.ImmutableMap;

import org.daisy.pipeline.braille.common.util.Function2;

public interface Provider<Q,X> {
	
	/**
	 * Get an object based on a query.
	 * @param query
	 * @return The object that best matches the query, or null if no object can be provided.
	 */
	public X get(Q query);
	
	public static class NULL<Q,X> implements Provider<Q,X> {
		public X get(Q query) {
			return null;
		}
	}
	
	public static abstract class CachedProvider<Q,X> extends Cached<Q,X> implements Provider<Q,X> {
		public static <Q,X> CachedProvider<Q,X> newInstance(final Provider<Q,X> delegate) {
			return new CachedProvider<Q,X>() {
				public X delegate(Q query) {
					return delegate.get(query);
				}
			};
		}
	}
	
	public static abstract class SimpleMappingProvider<Q,X> implements Provider<Q,X> {
		private Map<Q,String> map;
		public abstract Q parseKey(String key);
		public abstract X parseValue(String value);
		public SimpleMappingProvider(URL properties) {
			map = readProperties(properties);
		}
		public X get(Q query) {
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
		public static <Q,X> SimpleMappingProvider<Q,X> newInstance(URL properties,
		                                                           final Function<String,Q> parseKey,
		                                                           final Function<String,X> parseValue) {
			return new SimpleMappingProvider<Q,X>(properties) {
				public Q parseKey(String key) {
					return parseKey.apply(key);
				}
				public X parseValue(String value) {
					return parseValue.apply(value);
				}
			};
		}
	}
	
	public static abstract class DispatchingProvider<Q,X> implements Provider<Q,X> {
		public abstract Iterable<? extends Provider<Q,X>> dispatch();
		public X get(Q query) {
			for (Provider<Q,X> provider : dispatch()) {
				X object = provider.get(query);
				if (object != null)
					return object; }
			return null;
		}
		public static <Q,X> DispatchingProvider<Q,X> newInstance(final Iterable<? extends Provider<Q,X>> dispatch) {
			return new DispatchingProvider<Q,X>() {
				public Iterable<? extends Provider<Q,X>> dispatch() {
					return dispatch;
				}
			};
		}
	}
	
	public static abstract class LocaleBasedProvider<Q,X> implements Provider<Q,X> {
		public abstract X delegate(Q query);
		public abstract Locale getLocale(Q query);
		public abstract Q assocLocale(Q query, Locale locale);
		public X get(Q query) {
			Locale locale = getLocale(query);
			if ("".equals(locale.toString()))
				return null;
			if (!"".equals(locale.getVariant())) {
				X object = delegate(query);
				if (object != null)
					return object; }
			if (!"".equals(locale.getCountry())) {
				X object = delegate(assocLocale(query, new Locale(locale.getLanguage(), locale.getCountry())));
				if (object != null)
					return object; }
			if (!"".equals(locale.getLanguage())) {
				X object = delegate(assocLocale(query, new Locale(locale.getLanguage())));
				if (object != null)
					return object; }
			return null;
		}
		public static <Q,X> LocaleBasedProvider<Q,X> newInstance(final Provider<Q,X> delegate,
		                                                       final Function<Q,Locale> getLocale,
		                                                       final Function2<Q,Locale,Q> assocLocale) {
			return new LocaleBasedProvider<Q,X>() {
				public X delegate(Q query) {
					return delegate.get(query);
				}
				public Locale getLocale(Q query) {
					return getLocale.apply(query);
				}
				public Q assocLocale(Q query, Locale locale) {
					return assocLocale.apply(query, locale);
				}
			};
		}
		public static <X> LocaleBasedProvider<Locale,X> newInstance(final Provider<Locale,X> delegate) {
			return new LocaleBasedProvider<Locale,X>() {
				public X delegate(Locale locale) {
					return delegate.get(locale);
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
