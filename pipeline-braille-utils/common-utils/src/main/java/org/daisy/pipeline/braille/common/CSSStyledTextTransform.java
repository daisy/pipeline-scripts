package org.daisy.pipeline.braille.common;

/**
 * A {@link org.daisy.pipeline.braille.common.TextTransform} thatcan
 * translate styled text or sequences of styled text nodes. Style is
 * represented by inline-level braille CSS.
 */
public interface CSSStyledTextTransform extends TextTransform {
	
	public String transform(String text, String cssStyle);
	
	public String[] transform(String[] text, String[] cssStyle);
	
	/**
	 * Whether the translator supports "hyphens: auto" or not
	 */
	public boolean isHyphenating();
	
}
