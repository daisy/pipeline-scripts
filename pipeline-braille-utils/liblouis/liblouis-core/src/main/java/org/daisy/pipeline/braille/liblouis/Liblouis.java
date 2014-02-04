package org.daisy.pipeline.braille.liblouis;

/**
 * A liblouis table is a string that can be either a file name, a file path relative
 * to a registered tablepath, an absolute file URI, or a fully qualified table
 * identifier (URI). The sting can also be a comma sepapated list of tables. In this
 * case, the tablepath that contains the first `sub-table' in the list will be used
 * as a `base' for resolving the subsequent sub-tables.
 */
public interface Liblouis {
	
	/**
	 * @param table The liblouis table to be used for translation.
	 * @param text The text to be translated.
	 * @param hyphenated Whether or not <code>text</code> is prehyphenated.
	 * @param typeform The typeform array. Must have the same length as <code>text</code>.
	 */
	public String translate(String table, String text, boolean hyphenated, byte[] typeform);
	
	/**
	 * @param table The liblouis table to be used for hyphenation.
	 * @param text The text to be hyphenated.
	 */
	public String hyphenate(String table, String text);
	
}
