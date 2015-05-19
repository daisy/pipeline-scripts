package org.daisy.pipeline.braille.common;

import java.util.List;

import org.daisy.pipeline.braille.common.util.Function0;

import com.google.common.base.Function;
import com.google.common.collect.ImmutableList;

public abstract class WithSideEffect<T,W> implements Function<W,T> {
	
	private T value = null;
	private boolean computed = false;
	
	public T apply(W world) {
		if (!computed) {
			sideEffectsBuilder = new ImmutableList.Builder<Function0<Void>>();
			value = delegate(world);
			sideEffects = sideEffectsBuilder.build();
			computed = true; }
		else
			for (Function0<Void> sideEffect : sideEffects)
				sideEffect.apply();
		return value;
	}
	
	protected abstract T delegate(W world);
	
	private List<Function0<Void>> sideEffects;
	private ImmutableList.Builder<Function0<Void>> sideEffectsBuilder;
	
	protected void sideEffect(Function0<Void> sideEffect) {
		sideEffect.apply();
		sideEffectsBuilder.add(sideEffect);
	}
}
