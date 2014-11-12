package org.daisy.pipeline.braille.common;

/**
 * A {@link org.daisy.pipeline.braille.common.StyledTextTransform} that
 * assumes styles are represented by inline-level braille CSS.
 */
public interface CSSStyledTextTransform extends StyledTextTransform {
	
	public String transform(String text, String cssStyle);
	
	public String[] transform(String[] text, String[] cssStyle);
	
	/**
	 * Whether the translator supports "hyphens: auto" or not
	 */
	public boolean isHyphenating();
	
}
