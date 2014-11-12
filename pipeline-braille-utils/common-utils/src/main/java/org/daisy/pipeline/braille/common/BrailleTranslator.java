package org.daisy.pipeline.braille.common;

/**
 * Can translate text to braille.
 *
 * The {@link #transform(String)} and {@link #transform(String[])} methods
 * return unicode braille.
 */
public interface BrailleTranslator extends TextTransform {}
