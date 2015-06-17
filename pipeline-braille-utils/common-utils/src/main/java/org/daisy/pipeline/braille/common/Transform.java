package org.daisy.pipeline.braille.common;

import java.util.Iterator;
import java.util.NoSuchElementException;

import com.google.common.base.Function;
import com.google.common.collect.Iterables;

import org.daisy.pipeline.braille.common.WithSideEffect;

import org.slf4j.Logger;

/**
 * Tag interface for anything that can transform a node.
 *
 * Classes that implement this interface must have some kind of "transform"
 * method.
 */
public interface Transform {
	
	public interface Provider<T extends Transform> extends org.daisy.pipeline.braille.common.Provider<String,T>,
	                                                       Contextual<Logger,Transform.Provider<T>> {
		
		public static class DispatchingProvider<T extends Transform>
				extends org.daisy.pipeline.braille.common.Provider.DispatchingProvider<String,T>
				implements Provider<T> {
			private final Iterable<Transform.Provider<T>> dispatch;
			private final Logger context;
			public DispatchingProvider(Iterable<Transform.Provider<T>> dispatch) {
				this(dispatch, null);
			}
			private DispatchingProvider(Iterable<Transform.Provider<T>> dispatch, Logger context) {
				this.dispatch = dispatch;
				this.context = context;
			}
			public Iterable<org.daisy.pipeline.braille.common.Provider<String,T>> dispatch() {
				return Iterables.<Transform.Provider<T>,org.daisy.pipeline.braille.common.Provider<String,T>>transform(
					dispatch,
					new Function<Transform.Provider<T>,org.daisy.pipeline.braille.common.Provider<String,T>>() {
						public org.daisy.pipeline.braille.common.Provider<String,T> apply(Transform.Provider<T> provider) {
							return provider.withContext(context); }});
			}
			public Provider<T> withContext(Logger context) {
				return new Provider.DispatchingProvider<T>(dispatch, context);
			}
		}
		
		public static abstract class util {
			
			public static <T extends Transform> WithSideEffect<T,Logger> logCreate(final T t) {
				return new WithSideEffect<T,Logger>() {
					public T _apply() {
						applyWithSideEffect(debug("Created " + t));
						return t; }};
			}
			
			public static <T extends Transform> Iterable<WithSideEffect<T,Logger>> logSelect(final String query,
			                                                                                 final Iterable<T> iterable) {
				return new Iterable<WithSideEffect<T,Logger>>() {
					public Iterator<WithSideEffect<T,Logger>> iterator() {
						return new Iterator<WithSideEffect<T,Logger>>() {
							Iterator<T> i = null;
							public boolean hasNext() {
								if (i == null)
									return true;
								return i.hasNext();
							}
							public WithSideEffect<T,Logger> next() {
								final T t;
								if (i == null) {
									i = iterable.iterator();
									try { t = i.next(); }
									catch (final NoSuchElementException e) {
										return new WithSideEffect<T,Logger>() {
											public T _apply() {
												applyWithSideEffect(debug("No match for query " + query));
												throw e;
											}
										};
									}
								} else
									t = i.next();
								return new WithSideEffect<T,Logger>() {
									public T _apply() {
										applyWithSideEffect(info("Selected " + t + " for query " + query));
										return t;
									}
								};
							}
							public void remove() {
								throw new UnsupportedOperationException();
							}
						};
					}
				};
			}
			
			private static Function<Logger,Void> debug(final String message) {
				return new Function<Logger,Void>() {
					public Void apply(Logger logger) {
						if (logger != null)
							logger.debug(message);
						return null;
					}
				};
			}
			
			private static Function<Logger,Void> info(final String message) {
				return new Function<Logger,Void>() {
					public Void apply(Logger logger) {
						if (logger != null)
							logger.info(message);
						return null;
					}
				};
			}
		}
	}
}
