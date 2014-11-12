package org.daisy.pipeline.braille.common;

/**
 * A {@link org.daisy.pipeline.braille.common.CSSStyledTextTransform} that
 * takes into account styles for media print.
 */
public interface PrintCSSStyledTextTransform extends CSSStyledTextTransform {
	
	public String transform(String text, String cssStyle, String printCssStyle);
	
	public String[] transform(String[] text, String[] cssStyle, String[] printCssStyle);
	
}
