package org.daisy.pipeline.braille.common;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;

import com.google.common.base.Function;
import com.google.common.base.Optional;
import com.google.common.collect.AbstractIterator;
import static com.google.common.collect.Iterables.transform;

import org.daisy.pipeline.braille.common.util.Locales;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.css.Query.parseQuery;
import static org.daisy.pipeline.braille.css.Query.serializeQuery;

import org.slf4j.Logger;

/**
 * Tag interface for anything that can transform a node.
 *
 * Classes that implement this interface must have some kind of "transform"
 * method.
 */
public interface Transform {
	
	public String getIdentifier();
	
	public interface Provider<T extends Transform> extends org.daisy.pipeline.braille.common.Provider<String,T>,
	                                                       Contextual<Logger,Transform.Provider<T>> {
		
		public static abstract class MemoizingProvider<T extends Transform>
				extends org.daisy.pipeline.braille.common.Provider.MemoizingProvider<String,T>
				implements Transform.Provider<T> {
			
			private Map<Logger,Transform.Provider<T>> providerCache = new HashMap<Logger,Transform.Provider<T>>();
			
			public MemoizingProvider() {
				providerCache.put(null, this);
			}
			
			protected abstract Transform.Provider<T> _withContext(Logger context);
			
			public final Transform.Provider<T> withContext(Logger context) {
				if (providerCache.containsKey(context))
					return providerCache.get(context);
				Transform.Provider<T> provider = new DerivativeProvider(_withContext(context));
				providerCache.put(context, provider);
				return provider;
			}
			
			private class DerivativeProvider
					extends org.daisy.pipeline.braille.common.Provider.MemoizingProvider<String,T>
					implements Transform.Provider<T> {
				private final Transform.Provider<T> provider;
				private DerivativeProvider(Transform.Provider<T> provider) {
					this.provider = provider;
				}
				public Iterable<T> _get(String query) {
					return provider.get(query);
				}
				public Transform.Provider<T> withContext(Logger context) {
					return Transform.Provider.MemoizingProvider.this.withContext(context);
				}
			}
		}
		
		public static abstract class DispatchingProvider<T extends Transform>
				extends org.daisy.pipeline.braille.common.Provider.DispatchingProvider<String,T>
				implements Transform.Provider<T> {
			
			private final Logger context;
			
			public DispatchingProvider(Logger context) {
				this.context = context;
			}
			
			protected abstract Iterable<Transform.Provider<T>> _dispatch();
			
			public final Iterable<org.daisy.pipeline.braille.common.Provider<String,T>> dispatch() {
				return transform(
					_dispatch(),
					new Function<Transform.Provider<T>,org.daisy.pipeline.braille.common.Provider<String,T>>() {
						public org.daisy.pipeline.braille.common.Provider<String,T> apply(Transform.Provider<T> provider) {
							return provider.withContext(context); }});
			}
		}
		
		public static abstract class util {
			
			public static <T extends Transform> T logCreate(T t, Logger context) {
				context.debug("Created " + t);
				return t;
			}
			
			public static <T extends Transform> java.lang.Iterable<T> logSelect(final String query,
                                                                                final Transform.Provider<T> provider,
                                                                                final Logger context) {
				return new Iterable<T>() {
					public Iterator<T> iterator() {
						return new AbstractIterator<T>() {
							Iterator<T> i = provider.get(query).iterator();
							boolean first = true;
							public T computeNext() {
								if (!i.hasNext()) {
									if (first)
										context.debug("No match for query " + query);
									return endOfData(); }
								T t = i.next();
								context.info("Selected " + t + " for query " + query);
								first = false;
								return t;
							}
						};
					}
				};
			}
			
			public static <T extends Transform> Transform.Provider.MemoizingProvider<T> memoize(Transform.Provider<T> provider) {
				return new memoize<T>(provider);
			}
			
			protected static class memoize<T extends Transform> extends Transform.Provider.MemoizingProvider<T> {
				private final Transform.Provider<T> provider;
				private memoize(Transform.Provider<T> provider) {
					this.provider = provider;
				}
				protected Iterable<T> _get(String query) {
					return provider.get(query);
				}
				protected Transform.Provider<T> _withContext(Logger context) {
					return provider.withContext(context);
				}
				@Override
				public String toString() {
					return "memoize( " + provider + " )";
				}
			}
			
			@SuppressWarnings(
				"unchecked" // safe cast to Iterable<Provider<Q,X>>
			)
			public static <T extends Transform> Transform.Provider<T> dispatch(Iterable<? extends Transform.Provider<T>> dispatch) {
				return new dispatch<T>((Iterable<Transform.Provider<T>>)dispatch, null);
			}
			
			private static class dispatch<T extends Transform> extends Transform.Provider.DispatchingProvider<T> {
				private final Iterable<Transform.Provider<T>> dispatch;
				private dispatch(Iterable<Transform.Provider<T>> dispatch, Logger context) {
					super(context);
					this.dispatch = dispatch;
				}
				protected Iterable<Transform.Provider<T>> _dispatch() {
					return dispatch;
				}
				public Transform.Provider<T> withContext(Logger context) {
					return new dispatch<T>(dispatch, context);
				}
				@Override
				public String toString() {
					return "dispatch( " + join(_dispatch(), ", ") + " )";
				}
			}
			
			public static <T extends Transform> Transform.Provider<T> varyLocale(Transform.Provider<T> delegate) {
				return new varyLocale<T>(delegate, null);
			}
			
			private static class varyLocale<T extends Transform> extends LocaleBasedProvider<String,T>
			                                                     implements Transform.Provider<T> {
				private final Transform.Provider<T> delegate;
				private final Logger context;
				private varyLocale(Transform.Provider<T> delegate, Logger context) {
					this.delegate = delegate;
					this.context = context;
				}
				public Iterable<T> _get(String query) {
					return delegate.withContext(context).get(query);
				}
				public Locale getLocale(String query) {
					Map<String,Optional<String>> q = parseQuery(query);
					Optional<String> o;
					if ((o = q.get("locale")) != null)
						return parseLocale(o.get());
					else
						return null;
				}
				public String assocLocale(String query, Locale locale) {
					Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
					q.put("locale", Optional.of(Locales.toString(locale, '_')));
					return serializeQuery(q);
				}
				public Transform.Provider<T> withContext(Logger context) {
					return new varyLocale<T>(delegate, context);
				}
				@Override
				public String toString() {
					return "varyLocale( " + delegate + " )";
				}
			}
		}
	}
}
