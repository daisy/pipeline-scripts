package org.daisy.pipeline.braille.dotify;

import org.daisy.dotify.api.hyphenator.HyphenatorInterface;

import org.daisy.pipeline.braille.common.Hyphenator;

public interface DotifyHyphenator extends Hyphenator {
	
	public HyphenatorInterface asHyphenatorInterface();
	
	public interface Provider extends Hyphenator.Provider<DotifyHyphenator> {}
	
}
