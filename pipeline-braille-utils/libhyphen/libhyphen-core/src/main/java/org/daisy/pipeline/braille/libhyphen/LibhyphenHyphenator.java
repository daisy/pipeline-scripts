package org.daisy.pipeline.braille.libhyphen;

import java.net.URI;

import org.daisy.pipeline.braille.common.Hyphenator;

public interface LibhyphenHyphenator extends Hyphenator {
	
	public abstract URI asLibhyphenTable();
	
	public interface Provider extends Hyphenator.Provider<LibhyphenHyphenator> {}
	
}
