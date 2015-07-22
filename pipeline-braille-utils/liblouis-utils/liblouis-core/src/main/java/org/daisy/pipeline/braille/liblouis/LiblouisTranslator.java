package org.daisy.pipeline.braille.liblouis;

import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.CSSStyledTextTransform;

public interface LiblouisTranslator extends CSSStyledTextTransform, BrailleTranslator {
	
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
	public String transform(String text, byte typeform);
	
	/**
	 * @param text The text segments to be translated.
	 * @param typeform The typeform. Array must have the same length as <code>text</code>.
	 */
	public String[] transform(String[] text, byte[] typeform);
	
	public LiblouisTable asLiblouisTable();
	
	public interface Provider extends CSSStyledTextTransform.Provider<LiblouisTranslator>,
	                                  BrailleTranslator.Provider<LiblouisTranslator> {}
	
}
