package org.daisy.pipeline.braille.common;

import java.util.List;
import java.util.NoSuchElementException;

import com.google.common.collect.ImmutableList;

public abstract class WithSideEffect<T,W> implements com.google.common.base.Function<W,T> {
	
	private T value = null;
	private boolean computed = false;
	
	public final T apply(W world) throws Exception {
		if (!computed) {
			sideEffectsBuilder = new ImmutableList.Builder<com.google.common.base.Function<? super W,?>>();
			firstWorld = world;
			try {
				value = _apply();
				sideEffects = sideEffectsBuilder.build();
				computed = true; }
			catch (Throwable t) {
				throw new Exception(t); }
			finally {
				sideEffectsBuilder = null;
				firstWorld = null; }}
		else
			for (com.google.common.base.Function<? super W,?> sideEffect : sideEffects)
				try { sideEffect.apply(world); } catch(Throwable t) {}
		return value;
	}
	
	protected abstract T _apply() throws Throwable;
	
	private List<com.google.common.base.Function<? super W,?>> sideEffects;
	private ImmutableList.Builder<com.google.common.base.Function<? super W,?>> sideEffectsBuilder;
	private W firstWorld;
	
	protected final <V> V applyWithSideEffect(final com.google.common.base.Function<? super W,? extends V> withSideEffect) {
		sideEffectsBuilder.add(withSideEffect);
		return withSideEffect.apply(firstWorld);
	}
	
	@SuppressWarnings("serial")
	public static class Exception extends NoSuchElementException {
		private final Throwable cause;
		private Exception(Throwable cause) {
			this.cause = cause;
		}
		@Override
		public Throwable getCause() {
			return cause;
		}
	}
	
	public static abstract class Function<F,T,W> implements com.google.common.base.Function<WithSideEffect<F,W>,WithSideEffect<T,W>> {
		public abstract T _apply(F input);
		public final WithSideEffect<T,W> apply(final WithSideEffect<F,W> input) {
			return new WithSideEffect<T,W>() {
				public T _apply() {
					current = this;
					try {
						return Function.this._apply(applyWithSideEffect(input)); }
					finally {
						current = null; }
				}
			};
		}
		private WithSideEffect<T,W> current;
		protected final <V> V applyWithSideEffect(final com.google.common.base.Function<? super W,? extends V> withSideEffect) {
			return current.applyWithSideEffect(withSideEffect);
		}
	}
}
