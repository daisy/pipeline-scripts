package org.daisy.pipeline.braille.common;

/**
 * Can translate text to braille.
 *
 * The {@link #transform(String)} and {@link #transform(String[])} methods
 * return unicode braille.
 */
public interface BrailleTranslator extends TextTransform {
	
	public interface Provider<T extends BrailleTranslator> extends TextTransform.Provider<T> {}
	
}
