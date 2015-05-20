package org.daisy.pipeline.braille.tex;

import java.net.URI;

import org.daisy.pipeline.braille.common.Hyphenator;

public interface TexHyphenator extends Hyphenator {
	
	public URI asTexHyphenatorTable();
	
	public interface Provider extends Hyphenator.Provider<TexHyphenator> {}
	
}
