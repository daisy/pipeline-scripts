package org.daisy.pipeline.braille.liblouis;

import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.CSSStyledTextTransform;
import org.daisy.pipeline.braille.common.TextTransform;

public abstract class LiblouisTranslator implements CSSStyledTextTransform, BrailleTranslator {
	
	public static abstract class Typeform {
		public static final byte PLAIN = 0;
		public static final byte ITALIC = 1;
		public static final byte BOLD = 2;
		public static final byte UNDERLINE = 4;
		public static final byte COMPUTER = 8;
	}
	
	/**
	 * @param text The text to be translated.
	 * @param typeform The typeform.
	 */
	public abstract String transform(String text, byte typeform);
	
	public String transform(String text, Object style) {
		throw new IllegalArgumentException("style argument must be a 'typeform' byte or a 'inline CSS' String");
	}
	
	/**
	 * @param text The text segments to be translated.
	 * @param typeform The typeform. Array must have the same length as <code>text</code>.
	 */
	public abstract String[] transform(String[] text, byte[] typeform);
	
	public String[] transform(String[] text, Object[] style) {
		throw new IllegalArgumentException("style argument must be a 'typeform' byte[] or a 'inline CSS' String[]");
	}
	
	public abstract LiblouisTable asLiblouisTable();
	
	public interface Provider extends TextTransform.Provider<LiblouisTranslator> {}
	
}
