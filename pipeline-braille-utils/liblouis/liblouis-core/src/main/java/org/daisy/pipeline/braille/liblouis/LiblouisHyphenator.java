package org.daisy.pipeline.braille.liblouis;

import org.daisy.pipeline.braille.common.Hyphenator;

public interface LiblouisHyphenator extends Hyphenator {
	
	public LiblouisTable asLiblouisTable();
	
	public interface Provider extends Hyphenator.Provider<LiblouisHyphenator> {}
	
}
