package org.daisy.common.xproc.calabash.steps.liblouisxml;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.Enumeration;

import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.runtime.XAtomicStep;

public class XML2BRLProvider implements XProcStepProvider {

	private URL canonicalFile = null;

	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new XML2BRL(runtime, step, canonicalFile);
	}

	public void start(ComponentContext context) {
		Bundle bundle = context.getBundleContext().getBundle();
		canonicalFile = bundle.getEntry("/lbx_files/canonical.cfg");
	}
}
