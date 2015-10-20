package org.daisy.pipeline.braille.dotify;

import org.daisy.dotify.api.translator.BrailleFilter;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.CSSStyledTextTransform;

public interface DotifyTranslator extends BrailleTranslator, CSSStyledTextTransform {
	
	public BrailleFilter asBrailleFilter();
	
	public interface Provider extends CSSStyledTextTransform.Provider<DotifyTranslator>,
	                                  BrailleTranslator.Provider<DotifyTranslator> {}
	
}
