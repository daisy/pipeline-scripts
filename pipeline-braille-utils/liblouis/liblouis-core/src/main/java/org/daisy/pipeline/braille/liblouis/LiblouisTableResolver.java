package org.daisy.pipeline.braille.liblouis;

import java.io.File;
import java.net.URI;

import org.daisy.pipeline.braille.ResourceResolver;

public interface LiblouisTableResolver extends ResourceResolver {
	
	public File[] resolveTableList(URI[] tableList, File base);
	
}
