package org.daisy.pipeline.braille.common;

import java.util.Iterator;
import java.util.NoSuchElementException;

import com.google.common.collect.Iterables;

import org.slf4j.Logger;

/**
 * Tag interface for anything that can transform a node.
 *
 * Classes that implement this interface must have some kind of "transform"
 * method.
 */
public interface Transform {
	
	public interface Provider<T extends Transform> extends org.daisy.pipeline.braille.common.Provider<String,T> {
		
		public static class DispatchingProvider<T extends Transform>
				extends org.daisy.pipeline.braille.common.Provider.DispatchingProvider<String,T>
				implements Provider<T> {
			private final Iterable<Transform.Provider<T>> dispatch;
			public DispatchingProvider(Iterable<Transform.Provider<T>> dispatch) {
				this.dispatch = dispatch;
			}
			@SuppressWarnings(
				"unchecked" // safe cast to Provider<String,T>
			)
			public Iterable<org.daisy.pipeline.braille.common.Provider<String,T>> dispatch() {
				return Iterables.<org.daisy.pipeline.braille.common.Provider<String,T>>concat(dispatch);
			}
		}
		
		public static abstract class util {
			
			public static <T extends Transform> T logCreate(T t, Logger logger) {
				logger.debug("Created " + t);
				return t;
			}
			
			public static <T extends Transform> Iterable<T> logSelect(final String query, final Iterable<T> iterable, final Logger logger) {
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
		}
	}
}
