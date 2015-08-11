package org.daisy.pipeline.braille.common;

/**
 * Can translate text to braille.
 *
 * The output of the methods {@link #transform(String)} and {@link
 * #transform(String[])} must consist solely of unicode braille patterns, <a
 * href="http://snaekobbi.github.io/braille-css-spec/#dfn-white-space-characters">white
 * space characters</a> and format characters (soft hyphens, zero width spaces
 * and no-break spaces).
 *
 * A BrailleTranslator must respect a number of white space processing rules:
 * - <a
 *   href="http://snaekobbi.github.io/braille-css-spec/master/index.html#dfn-collapsible">Collapsible</a>
 *   white space characters may be interchanged with each other, sequences of
 *   collapsible white space characters may be collapsed or expanded.
 * - In some cases, collapsible white space between words may be dropped, and
 *   soft hyphens and zero width spaces may be dropped (e.g. within
 *   contractions).
 * - <a
 *   href="http://snaekobbi.github.io/braille-css-spec/master/index.html#dfn-preserved">Preserved</a>
 *   spaces and line feeds and no-break spaces (U+00A0) must be preserved.
 * - In no other cases may white space characters or format characters be
 *   added or deleted.
 */
public interface BrailleTranslator extends TextTransform {
	
	public interface Provider<T extends BrailleTranslator> extends TextTransform.Provider<T> {}
	
}
