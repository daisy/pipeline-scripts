package org.daisy.pipeline.braille.dotify;

import org.daisy.dotify.api.translator.BrailleTranslator;

public class DotifyTranslator {
	
	private BrailleTranslator translator;
	
	protected DotifyTranslator(BrailleTranslator translator) {
		this.translator = translator;
	}
	
	public String translate(String text) {
		return translator.translate(text).getTranslatedRemainder();
	}
}
