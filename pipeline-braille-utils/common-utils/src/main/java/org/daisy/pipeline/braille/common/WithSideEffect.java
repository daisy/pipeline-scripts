package org.daisy.pipeline.braille.common;

import java.util.List;

import com.google.common.base.Function;
import com.google.common.collect.ImmutableList;

public abstract class WithSideEffect<T,W> implements Function<W,T> {
	
	private T value = null;
	private boolean computed = false;
	
	public final T apply(W world) {
		if (!computed) {
			sideEffectsBuilder = new ImmutableList.Builder<Function<? super W,?>>();
			firstWorld = world;
			value = _apply();
			sideEffects = sideEffectsBuilder.build();
			sideEffectsBuilder = null;
			computed = true; }
		else
			for (Function<? super W,?> sideEffect : sideEffects)
				try { sideEffect.apply(world); } catch(Throwable t) {}
		return value;
	}
	
	protected abstract T _apply();
	
	private List<Function<? super W,?>> sideEffects;
	private ImmutableList.Builder<Function<? super W,?>> sideEffectsBuilder;
	private W firstWorld;
	
	protected final <V> V applyWithSideEffect(final Function<? super W,? extends V> withSideEffect) {
		sideEffectsBuilder.add(withSideEffect);
		return withSideEffect.apply(firstWorld);
	}
}
