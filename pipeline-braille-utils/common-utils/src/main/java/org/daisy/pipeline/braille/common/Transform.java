package org.daisy.pipeline.braille.common;

import java.util.Iterator;
import java.util.NoSuchElementException;

import com.google.common.base.Function;
import com.google.common.collect.Iterables;

import org.daisy.pipeline.braille.common.WithSideEffect;
import org.daisy.pipeline.braille.common.util.Function0;

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
					public T delegate(Logger logger) {
						if (logger != null)
							sideEffect(debug(logger, "Created " + t));
						return t;
					}
				};
			}
			
			public static <T extends Transform> WithSideEffect<Iterable<T>,Logger> logSelect(final String query, final Iterable<T> iterable) {
				return new WithSideEffect<Iterable<T>,Logger>() {
					public Iterable<T> delegate(final Logger logger) {
						if (logger == null)
							return iterable;
						return new Iterable<T>() {
							public Iterator<T> iterator() {
								return new Iterator<T>() {
									Iterator<T> i = null;
									public boolean hasNext() {
										if (i == null) i = iterable.iterator();
										return i.hasNext();
									}
									public T next() {
										T t;
										if (i == null) {
											i = iterable.iterator();
											try { t = i.next(); }
											catch (NoSuchElementException e) {
												logger.debug("No match for query " + query);
												throw e; }}
										else
											t = i.next();
										logger.info("Selected " + t + " for query " + query);
										return t;
									}
									public void remove() {
										if (i == null) i = iterable.iterator();
										i.remove();
									}
								};
							}
						};
					}
				};
			}
			
			private static Function0<Void> debug(final Logger logger, final String message) {
				return new Function0<Void>() {
					public Void apply() {
						logger.debug(message);
						return null;
					}
				};
			}
			
			private static Function0<Void> info(final Logger logger, final String message) {
				return new Function0<Void>() {
					public Void apply() {
						logger.info(message);
						return null;
					}
				};
			}
		}
	}
}
