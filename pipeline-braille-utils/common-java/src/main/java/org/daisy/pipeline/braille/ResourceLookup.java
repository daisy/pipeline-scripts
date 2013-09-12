package org.daisy.pipeline.braille;

import java.net.URL;

public interface ResourceLookup<T> {
	
	/**
	 * Lookup a resource based on a key.
	 * @param key
	 * @return The resource associated with the key, or null if no resource can be found.
	 */
	public URL lookup(T key);
	
}
