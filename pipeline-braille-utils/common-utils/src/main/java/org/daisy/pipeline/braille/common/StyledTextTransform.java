package org.daisy.pipeline.braille.common;

/**
 * A {@link org.daisy.pipeline.braille.common.TextTransform} that can
 * translate styled text or sequences of styled text nodes.
 *
 * A style is represented by an object that somehow encodes the text
 * attributes of a text segment.
 */
public interface StyledTextTransform extends TextTransform {
	
	public String transform(String text, Object style);
	
	public String[] transform(String[] text, Object[] style);
	
}
