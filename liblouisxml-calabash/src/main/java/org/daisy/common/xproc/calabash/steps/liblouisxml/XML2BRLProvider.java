package org.daisy.common.xproc.calabash.steps.liblouisxml;

import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.runtime.XAtomicStep;

public class XML2BRLProvider implements XProcStepProvider {

	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new XML2BRL(runtime, step);
	}

	public void activate(ComponentContext context) {
		Bundle bundle = context.getBundleContext().getBundle();
		XML2BRL.setIniFile(bundle.getEntry("/lbx_files/liblouisutdml.ini"));
	}
}
