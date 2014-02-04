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
	
	public static abstract class CachedResolver implements ResourceResolver {
		private final Map<URI,URL> cache = new HashMap<URI,URL>();
		public abstract URL delegate(URI resource);
		public URL resolve(URI resource) {
			if (cache.containsKey(resource))
				return cache.get(resource);
			URL resolved = delegate(resource);
			if (resolved != null) {
				cache.put(resource, resolved);
				return resolved; }
			return null;
		}
		public void invalidateCache() {
			cache.clear();
		}
	}
}
