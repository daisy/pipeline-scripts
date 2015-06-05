package org.daisy.pipeline.braille.common;

/**
 * Can translate text to braille.
 *
 * The output of the methods {@link #transform(String)} and {@link
 * #transform(String[])} must consist solely of unicode braille patterns, <a
 * href="http://snaekobbi.github.io/braille-css-spec/#dfn-white-space-characters">white
 * space characters</a> and format characters (soft hyphens, zero width spaces
 * and no-break spaces).
 */
public interface BrailleTranslator extends TextTransform {
	
	public interface Provider<T extends BrailleTranslator> extends TextTransform.Provider<T> {}
	
}
