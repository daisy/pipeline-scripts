package org.daisy.pipeline.braille.liblouis.impl;

import org.daisy.pipeline.braille.liblouis.LiblouisTranslator.Typeform;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class LiblouisJnaImplTest {
	
	@Test
	public void testTypeformFromInlineCSS() {
		assertEquals(Typeform.BOLD + Typeform.UNDERLINE,
		             LiblouisJnaImpl.typeformFromInlineCSS(
			             " text-decoration: underline ;font-weight: bold  ; hyphens:auto; color: #FF00FF "));
	}
}
