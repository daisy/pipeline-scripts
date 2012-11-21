package org.daisy.pipeline.braille.liblouis;

import java.net.URL;

public interface Liblouis {
	
	/**
	 * @param tables The fully qualified table URL.
	 * @param text The text to be translated.
	 * @param typeform The typeform array. Must have the same length as <code>text</code>.
	 * @param hyphenate Whether or not to perform hyphenation before translation.
	 */
	public String translate(URL table, String text, byte[] typeform, boolean hyphenate);

	/**
	 * @param tables The fully qualified table URL.
	 * @param text The text to be hyphenated.
	 */
	public String hyphenate(URL table, String text);
	
}
