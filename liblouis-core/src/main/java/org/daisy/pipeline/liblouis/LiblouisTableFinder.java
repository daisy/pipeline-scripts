package org.daisy.pipeline.liblouis;

import java.util.Locale;

public interface LiblouisTableFinder {

	public String find(String locale);

	public String find(Locale locale);
	
}
