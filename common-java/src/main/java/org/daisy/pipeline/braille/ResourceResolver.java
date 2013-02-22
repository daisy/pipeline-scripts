package org.daisy.pipeline.braille;

import java.net.URL;

public interface ResourceResolver {
	
	/**
	 * Resolve a resource from a URL.
	 * @param url
	 * @return The resolved URL, or null if the resource cannot be resolved.
	 */
	public URL resolve(URL url);
	
}
