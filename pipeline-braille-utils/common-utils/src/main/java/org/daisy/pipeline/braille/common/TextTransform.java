package org.daisy.pipeline.braille.common;

/**
 * A {@link org.daisy.pipeline.braille.common.Transform} that can translate
 * text or sequences of text nodes.
 */
public interface TextTransform extends Transform {
	
	/**
	 * Transform text into text.
	 */
	public String transform(String text);
	
	/**
	 * Transform a sequence of text nodes into a sequence of text nodes. The
	 * lengths of input and output arrays must be the same. The whole sequence
	 * may be used as context for translating each of the segments
	 * individually. The segments are assumed to follow each other
	 * directly. E.g. two text nodes in different CSS blocks can't be
	 * successive items in the array.
	 */
	public String[] transform(String[] text);
	
	public static abstract class ContextUnawareTextTransform implements TextTransform {
		public String[] transform(String[] text) {
			String[] ret = new String[text.length];
			for (int i = 0; i < text.length; i++)
				ret[i] = transform(text[i]);
			return ret;
		}
	}
	
	public interface Provider<T extends TextTransform>
		extends org.daisy.pipeline.braille.common.Provider<String,T> {}
}
