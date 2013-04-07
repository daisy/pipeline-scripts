package org.daisy.pipeline.braille.liblouis;

public interface Liblouis {
	
	/**
	 * @param table Can be a file name or path relative to a registered table path,
	 *     an absolute file, or a fully qualified table URL.
	 * @param text The text to be translated.
	 * @param typeform The typeform array. Must have the same length as <code>text</code>.
	 * @param hyphenate Whether or not to perform hyphenation before translation.
	 */
	public String translate(String table, String text, byte[] typeform, boolean hyphenate);

	/**
	 * @param table Can be a file name or path relative to a registered table path,
	 *     an absolute file, or a fully qualified table URL.
	 * @param text The text to be hyphenated.
	 */
	public String hyphenate(String table, String text);
	
}
