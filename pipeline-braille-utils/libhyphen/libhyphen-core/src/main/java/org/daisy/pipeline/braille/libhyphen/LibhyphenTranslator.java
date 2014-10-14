package org.daisy.pipeline.braille.libhyphen;

import org.daisy.pipeline.braille.common.Translator;

public interface LibhyphenTranslator extends Translator {
	
	/**
	 * @param text The text to be hyphenated.
	 */
	public String hyphenate(String text);
	
}
