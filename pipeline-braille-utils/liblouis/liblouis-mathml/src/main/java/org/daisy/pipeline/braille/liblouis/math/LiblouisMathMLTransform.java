package org.daisy.pipeline.braille.liblouis.math;

import org.daisy.pipeline.braille.common.MathMLTransform;
import org.daisy.pipeline.braille.common.XProcTransform;

public interface LiblouisMathMLTransform extends MathMLTransform, XProcTransform {
	public enum MathCode {
		NEMETH, UKMATHS, MARBURG, WOLUWE
	}
}
