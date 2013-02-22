package org.daisy.pipeline.braille.tex;

import org.daisy.pipeline.braille.TableRegistry;

import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.service.component.ComponentContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TexHyphenatorProvider extends TableRegistry<TexHyphenatorTablePath> implements TexHyphenatorTableLookup {
	
	private BundleContext bundleContext;
	
	public void activate(ComponentContext context) {
		if (bundleContext == null)
			bundleContext = context.getBundleContext();
		publishServices();
	}
	
	public void deactivate() {
		unpublishServices();
	}

	private ServiceRegistration hyphenatorRegistration;
	
	private void publishServices() {
		if (hyphenatorRegistration == null) {
			hyphenatorRegistration = bundleContext.registerService(
					TexHyphenator.class.getName(), new TexHyphenator(this), null);
			logger.debug("Publishing TeX hyphenator service"); }
	}
	
	private void unpublishServices() {
		if (hyphenatorRegistration != null) {
			hyphenatorRegistration.unregister();
			hyphenatorRegistration = null;
			logger.debug("Unpublishing TeX hyphenator service"); }
	}
	
	private static final Logger logger = LoggerFactory.getLogger(TexHyphenatorProvider.class);
}
