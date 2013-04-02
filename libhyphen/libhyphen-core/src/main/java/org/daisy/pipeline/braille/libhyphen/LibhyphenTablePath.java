package org.daisy.pipeline.braille.libhyphen;

import java.util.Map;

import org.daisy.pipeline.braille.BundledTablePath;
import org.osgi.service.component.ComponentContext;

public class LibhyphenTablePath extends BundledTablePath {
	
	@Override
	protected void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		super.activate(context, properties);
		lazyUnpack(context);
	}
}
