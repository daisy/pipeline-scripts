package org.daisy.pipeline.braille;

import java.net.URI;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

public interface ResourceResolver {
	
	/**
	 * Resolve a resource from a URI.
	 * @param resource
	 * @return The resolved URL, or null if the resource cannot be resolved.
	 */
	public URL resolve(URI resource);
	
	public static abstract class CachedResolver extends Cached<URI,URL> implements ResourceResolver {
		public URL resolve(URI resource) {
			return get(resource);
		}
	}
}
