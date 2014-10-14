package org.daisy.pipeline.braille.tex;

public interface TexHyphenator {
	
	/**
	 * @param text The text to be hyphenated.
	 */
	public String hyphenate(String text);
	
}
