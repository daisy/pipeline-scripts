package org.daisy.pipeline.braille.common;

import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Properties;

import com.google.common.base.Function;
import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Iterables;

import org.daisy.pipeline.braille.common.util.Function2;

public interface Provider<Q,X> {
	
	/**
	 * Get a collection of objects based on a query.
	 * @param query
	 * @return The objects for the query, in order of best match.
	 */
	public Iterable<X> get(Q query);
	
	public static class NULL<Q,X> implements Provider<Q,X> {
		public Iterable<X> get(Q query) {
			return Optional.<X>absent().asSet();
		}
	}
	
	public static abstract class CachedProvider<Q,X> extends Cached<Q,Iterable<X>> implements Provider<Q,X> {
		public static <Q,X> CachedProvider<Q,X> newInstance(final Provider<Q,X> delegate) {
			return new CachedProvider<Q,X>() {
				public Iterable<X> delegate(Q query) {
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
		public Iterable<X> get(Q query) {
			String value = map.get(query);
			if (value != null)
				return Optional.<X>fromNullable(parseValue(value)).asSet();
			return Optional.<X>absent().asSet();
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
		public abstract Iterable<? extends Provider<Q,? extends X>> dispatch();
		@SuppressWarnings("unchecked")
		public Iterable<X> get(final Q query) {
			return Iterables.<X>concat(Iterables.<Provider<Q,? extends X>,Iterable<X>>transform(
				Iterables.<Provider<Q,? extends X>>concat(dispatch()),
				new Function<Provider<Q,? extends X>,Iterable<X>>() {
					public Iterable<X> apply(Provider<Q,? extends X> provider) {
						return Iterables.<X>concat(provider.get(query));
					}
				}
			));
		}
		public static <Q,X> DispatchingProvider<Q,X> newInstance(final Iterable<? extends Provider<Q,? extends X>> dispatch) {
			return new DispatchingProvider<Q,X>() {
				public Iterable<? extends Provider<Q,? extends X>> dispatch() {
					return dispatch;
				}
			};
		}
	}
	
	public static abstract class LocaleBasedProvider<Q,X> implements Provider<Q,X> {
		public abstract Iterable<? extends X> delegate(Q query);
		public abstract Locale getLocale(Q query);
		public abstract Q assocLocale(Q query, Locale locale);
		public Locale getLocale(Locale query) {
			return query;
		}
		public Locale assocLocale(Locale query, Locale locale) {
			return locale;
		}
		public Iterable<X> get(final Q query) {
			return new Iterable<X>() {
				public Iterator<X> iterator() {
					return new Iterator<X>() {
						Iterator<? extends X> next = null;
						int tryNext = 1;
						Locale locale = getLocale(query);
						public boolean hasNext() {
							while (next == null || !next.hasNext()) {
								switch (tryNext) {
								case 1:
									tryNext++;
									if (!"".equals(locale.toString()))
										next = delegate(query).iterator();
									else
										tryNext = 4;
									break;
								case 2:
									tryNext++;
									if (!"".equals(locale.getVariant()))
										next = delegate(assocLocale(query, new Locale(locale.getLanguage(), locale.getCountry()))).iterator();
									break;
								case 3:
									tryNext++;
									if (!"".equals(locale.getCountry()))
										next = delegate(assocLocale(query, new Locale(locale.getLanguage()))).iterator();
									break;
								case 4:
									tryNext++;
									next = fallback(query).iterator();
									break;
								default:
									return false; }}
							return true;
						}
						public X next() {
							if (!hasNext()) throw new NoSuchElementException();
							return next.next();
						}
						public void remove() {
							throw new UnsupportedOperationException();
						}
					};
				}
			};
		}
		public Iterable<X> fallback(Q query) {
			return Optional.<X>absent().asSet();
		}
		public static <Q,X> LocaleBasedProvider<Q,X> newInstance(final Provider<Q,X> delegate,
		                                                         final Function<Q,Locale> getLocale,
		                                                         final Function2<Q,Locale,Q> assocLocale) {
			return new LocaleBasedProvider<Q,X>() {
				public Iterable<? extends X> delegate(Q query) {
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
				public Iterable<? extends X> delegate(Locale locale) {
					return delegate.get(locale);
				}
			};
		}
	}
}
