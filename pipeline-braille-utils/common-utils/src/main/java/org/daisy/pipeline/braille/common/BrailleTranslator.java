package org.daisy.pipeline.braille.common;

import org.daisy.braille.css.SimpleInlineStyle;

import org.daisy.dotify.api.translator.BrailleTranslatorResult;

public interface BrailleTranslator extends Transform {
	
	public FromStyledTextToBraille fromStyledTextToBraille() throws UnsupportedOperationException;
	
	public LineBreakingFromStyledText lineBreakingFromStyledText() throws UnsupportedOperationException;
	
	/* ------------------------- */
	/* fromStyledTextToBraille() */
	/* ------------------------- */
	
	public interface FromStyledTextToBraille {
		
		public Iterable<String> transform(Iterable<CSSStyledText> styledText);
		
	}
	
	/* ---------------------------- */
	/* lineBreakingFromStyledText() */
	/* ---------------------------- */
	
	public interface LineBreakingFromStyledText {
		
		public LineIterator transform(Iterable<CSSStyledText> styledText);
		
	}
	
	/* ------------ */
	/* LineIterator */
	/* ------------ */
	
	public interface LineIterator extends BrailleTranslatorResult {}
	
	/* ------------- */
	/* CSSStyledText */
	/* ------------- */
	
	public static class CSSStyledText {
		
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
	}
}
