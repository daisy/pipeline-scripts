package org.daisy.pipeline.braille.common;

import com.google.common.collect.Iterables;

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
			@SuppressWarnings("unchecked")
			public Iterable<org.daisy.pipeline.braille.common.Provider<String,T>> dispatch() {
				return Iterables.<org.daisy.pipeline.braille.common.Provider<String,T>>concat(dispatch);
			}
		}
	}
}
