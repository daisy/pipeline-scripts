package org.daisy.common.xproc.calabash.steps.liblouisxml;

import java.net.URL;

import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.runtime.XAtomicStep;

public class XML2BRLProvider implements XProcStepProvider {

	//private URL canonicalFile = null;
	private URL iniFile = null;

	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		//return new XML2BRL(runtime, step, canonicalFile);
		return new XML2BRL(runtime, step, iniFile);
	}

	public void start(ComponentContext context) {
		Bundle bundle = context.getBundleContext().getBundle();
		//canonicalFile = bundle.getEntry("/lbx_files/canonical.cfg");
		iniFile = bundle.getEntry("/lbx_files/liblouisutdml.ini");
	}
}
