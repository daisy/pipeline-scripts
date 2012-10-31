package org.daisy.pipeline.braille.liblouis;

import java.net.URL;

public interface Liblouis {

	/**
	 * @param tables The fully qualified table URL.
	 * @param text The text to translate.
	 */
	public String translate(URL table, String text);
	
	/**
	 * @param tables The fully qualified table URL.
	 * @param text The text to translate.
	 * @param typeform The typeform array. Must have the same length as text.
	 */
	public String translate(URL table, String text, byte[] typeform);

}
