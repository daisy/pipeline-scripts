package org.daisy.pipeline.braille.liblouis;

import java.util.Map;

import org.daisy.pipeline.braille.BundledTablePath;
import org.osgi.service.component.ComponentContext;

import com.google.common.base.Splitter;

public class LiblouisTablePath extends BundledTablePath {
	
	@Override
	protected void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		super.activate(context, properties);
		lazyUnpack(context);
	}
	
	/* A liblouis table name can be a comma separated list of file names */
	@Override
	protected boolean includes(String tableName) {
		if ("".equals(tableName))
			return false;
		for(String t : Splitter.on(',').split(tableName))
			if (!resources.contains(t)) return false;
		return true;
	}
}
