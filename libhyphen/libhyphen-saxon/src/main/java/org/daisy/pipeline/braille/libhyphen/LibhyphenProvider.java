package org.daisy.pipeline.braille.libhyphen;

import org.daisy.pipeline.braille.TableRegistry;

import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.service.component.ComponentContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LibhyphenProvider extends TableRegistry<LibhyphenTablePath> implements LibhyphenTableLookup {
	
	private BundleContext bundleContext;
	
	public void activate(ComponentContext context) {
		if (bundleContext == null)
			bundleContext = context.getBundleContext();
		publishServices();
	}
	
	public void deactivate() {
		unpublishServices();
	}
	
	public void addTablePath(LibhyphenTablePath path) {
		register(path);
	}
	
	public void removeTablePath(LibhyphenTablePath path) {
		unregister(path);
	}
	
	private ServiceRegistration libhyphenRegistration;
	
	private void publishServices() {
		if (libhyphenRegistration == null) {
			libhyphenRegistration = bundleContext.registerService(
					Libhyphen.class.getName(), new Libhyphen(this), null);
			logger.debug("Publishing libhyphen service"); }
	}
	
	private void unpublishServices() {
		if (libhyphenRegistration != null) {
			libhyphenRegistration.unregister();
			libhyphenRegistration = null;
			logger.debug("Unpublishing libhyphen service"); }
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LibhyphenProvider.class);
}
