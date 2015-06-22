package org.daisy.pipeline.braille.liblouis.impl;

import org.daisy.pipeline.braille.liblouis.LiblouisTranslator.Typeform;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class LiblouisTranslatorJnaImplTest {
	
	@Test
	public void testTypeformFromInlineCSS() {
		assertEquals(Typeform.BOLD + Typeform.UNDERLINE,
		             LiblouisTranslatorJnaImpl.typeformFromInlineCSS(
			             " text-decoration: underline ;font-weight: bold  ; hyphens:auto; color: #FF00FF "));
	}

	@Test
	public void testTextFromTextTransform() {
		assertEquals("IK BEN MOOS",
			LiblouisTranslatorJnaImpl.textFromTextTransform("Ik ben Moos",
				" uppercase "));
		assertEquals("ik ben moos",
			LiblouisTranslatorJnaImpl.textFromTextTransform("Ik ben Moos",
				" lowercase "));
		assertEquals("ik ben moos",
			LiblouisTranslatorJnaImpl.textFromTextTransform("Ik ben Moos",
				" uppercase lowercase "));
		assertEquals("Ik ben Moos",
			LiblouisTranslatorJnaImpl.textFromTextTransform("Ik ben Moos",
				" foo bar "));
	}
	
	@Test
	public void testTypeformFromTextTransform() {
		assertEquals(Typeform.BOLD + Typeform.UNDERLINE,
		             LiblouisTranslatorJnaImpl.typeformFromTextTransform(" louis-bold  ital louis-under foo "));
	}
}
