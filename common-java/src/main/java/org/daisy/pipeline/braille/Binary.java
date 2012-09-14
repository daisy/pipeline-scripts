package org.daisy.pipeline.braille;

import java.net.URL;
import java.util.Collection;

import org.daisy.pipeline.braille.Utilities.OS;

public interface Binary {

	public String getName();

	/**
	 * First URL is the binary. Following URLs are the dependencies.
	 */
	public Iterable<URL> getPaths();

	public OS.Family getOsFamily();
	
	public Collection<String> getOsArchs();
}
