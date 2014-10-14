package org.daisy.pipeline.braille.tex;

import org.daisy.pipeline.braille.common.Translator;

public interface TexHyphenator extends Translator {
	
	/**
	 * @param text The text to be hyphenated.
	 */
	public String hyphenate(String text);
	
}
