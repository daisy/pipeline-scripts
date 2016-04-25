package org.daisy.pipeline.braille.common;

import org.daisy.braille.css.SimpleInlineStyle;

public class CSSStyledText implements Cloneable {
		
	private final String text;
	private final SimpleInlineStyle style;
		
	public CSSStyledText(String text, SimpleInlineStyle style) {
		this.text = text;
		this.style = style;
	}
	
	public CSSStyledText(String text, String style) {
		this.text = text;
		if (style == null)
			this.style = null;
		else
			this.style = new SimpleInlineStyle(style);
	}
		
	public CSSStyledText(String text) {
		this.text = text;
		this.style = null;
	}
		
	public String getText() {
		return text;
	}
		
	public SimpleInlineStyle getStyle() {
		return style;
	}
	
	@Override
	public Object clone() {
		return new CSSStyledText(text, (SimpleInlineStyle)style.clone());
	}
	
	@Override
	public String toString() {
		if (style == null || style.isEmpty())
			return text;
		else
			return text + "{" + style + "}";
	}
}
