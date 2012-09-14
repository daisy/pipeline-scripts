package org.daisy.pipeline.braille;

import java.net.URL;
import java.util.Locale;

public interface TableFinder {

	public URL find(String locale);

	/**
	 * Try to find a table based on the given locale.
	 */
	public URL find(Locale locale);
	
}
