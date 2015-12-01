package org.daisy.pipeline.braille.liblouis.impl;

import org.daisy.pipeline.braille.liblouis.LiblouisTable;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator.Typeform;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class LiblouisTableJnaImplProviderTest {
	
	@Test
	public void testDoubleLetterSpacing() {
		assertEquals(1,
		             LiblouisTableJnaImplProvider.letterSpacingFromInlineCSS("letter-spacing: 1;"));
		assertEquals(2,
			     LiblouisTableJnaImplProvider.letterSpacingFromInlineCSS("letter-spacing: 2;"));
	}

	@Test
	public void testTextFromLetterSpacing() {
		assertEquals("f o o   b a r",
			LiblouisTableJnaImplProvider.textFromLetterSpacing("foo bar",
				1));
		assertEquals("f  o  o     b  a  r",
			LiblouisTableJnaImplProvider.textFromLetterSpacing("foo bar",
				2));
	}
}
