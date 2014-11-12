package org.daisy.pipeline.braille.dotify;

import org.daisy.dotify.api.translator.BrailleTranslator;
import org.daisy.pipeline.braille.common.TextTransform;

public class DotifyTranslator implements TextTransform {
	
	private BrailleTranslator translator;
	
	protected DotifyTranslator(BrailleTranslator translator) {
		this.translator = translator;
	}
	
	public String transform(String text) {
		return translator.translate(text).getTranslatedRemainder();
	}
	
	public String[] transform(String[] text) {
		throw new UnsupportedOperationException();
	}
	
	public BrailleTranslator asBrailleTranslator() {
		return translator;
	}
}
