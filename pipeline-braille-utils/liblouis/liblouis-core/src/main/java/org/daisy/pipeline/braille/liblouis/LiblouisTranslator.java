package org.daisy.pipeline.braille.liblouis;

public interface LiblouisTranslator {
	
	/**
	 * @param text The text to be translated.
	 * @param hyphenated Whether or not <code>text</code> is prehyphenated.
	 * @param typeform The typeform array. Must have the same length as <code>text</code>.
	 */
	public String translate(String text, boolean hyphenated, byte[] typeform);
	
	/**
	 * @param text The text to be hyphenated.
	 */
	public String hyphenate(String text);
	
}
