package org.daisy.pipeline.braille.dotify;

import org.daisy.dotify.api.translator.BrailleTranslator;
import org.daisy.pipeline.braille.common.Translator;

public class DotifyTranslator implements Translator {
	
	private BrailleTranslator translator;
	
	protected DotifyTranslator(BrailleTranslator translator) {
		this.translator = translator;
	}
	
	public String translate(String text) {
		return translator.translate(text).getTranslatedRemainder();
	}
}
