package org.daisy.braillecss.calabash;

import org.daisy.common.xproc.calabash.XProcStepProvider;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.runtime.XAtomicStep;

public class ApplyStylesheetProvider implements XProcStepProvider {

	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new ApplyStylesheet(runtime, step);
	}
}
