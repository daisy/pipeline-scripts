package org.daisy.pipeline.braille.common;

import java.util.Iterator;
import java.util.NoSuchElementException;

import org.daisy.pipeline.braille.common.util.Function0;

public abstract class LazyValue<V> implements Function0<V>, Iterable<V> {
	
	public abstract V get();
	
	public V apply() {
		return get();
	}
	
	public Iterator<V> iterator() {
		return new Iterator<V>() {
			boolean hasNext = true;
			public boolean hasNext() {
				return hasNext;
			}
			public V next() {
				if (!hasNext())
					throw new NoSuchElementException();
				hasNext = false;
				return get();
			}
			public void remove() {
				throw new UnsupportedOperationException();
			}
		};
	}
	
	public static <V> LazyValue<V> from(final Function0<V> get) {
		return new LazyValue<V>() {
			public V get() {
				return get.apply();
			}
		};
	}
	
	public static abstract class ImmutableLazyValue<V> extends LazyValue<V> {
		
		private V value = null;
		protected boolean computed = false;
		
		public V get() {
			if (!computed) {
				value = delegate();
				computed = true; }
			return value;
		}
		
		protected abstract V delegate();
		
		public static <V> LazyValue<V> from(final Function0<V> get) {
			return new ImmutableLazyValue<V>() {
				public V delegate() {
					return get.apply();
				}
			};
		}
	}
	
	public static abstract class CachedLazyValue<V> extends ImmutableLazyValue<V> {
		
		public void invalidateCache() {
			computed = false;
		}
		
		public static <V> CachedLazyValue<V> from(final Function0<V> get) {
			return new CachedLazyValue<V>() {
				public V delegate() {
					return get.apply();
				}
			};
		}
	}
}
