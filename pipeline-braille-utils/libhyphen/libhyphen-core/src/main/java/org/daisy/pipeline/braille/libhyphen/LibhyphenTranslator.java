package org.daisy.pipeline.braille.libhyphen;

public interface LibhyphenTranslator {
	
	/**
	 * @param text The text to be hyphenated.
	 */
	public String hyphenate(String text);
	
}
