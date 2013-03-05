package org.daisy.pipeline.braille;

import static org.daisy.pipeline.braille.Utilities.Files.isAbsoluteFile;

import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class ResourceRegistry<T extends ResourcePath> implements ResourceResolver {
	
	protected void register(T path) {
		if (paths.containsKey(path.getIdentifier()))
			throw new RuntimeException("Resource registry already contains resource path with identifier " + path.getIdentifier());
		paths.put(path.getIdentifier(), path);
		resolverCache.clear();
		logger.debug("Adding resource path to registry: {}", path.getIdentifier());
	}
	
	protected void unregister(T path) {
		paths.remove(path.getIdentifier());
		resolverCache.clear();
		logger.debug("Removing resource path from registry: {}", path.getIdentifier());
	}
	
	protected final Map<URL,T> paths = new HashMap<URL,T>();
	
	/*
	 * ResourceResolver
	 */
	
	public URL resolve(URL url) {
		URL resolved = resolverCache.get(url);
		if (resolved == null) {
			for (T path : paths.values()) {
				resolved = path.resolve(url);
				if (resolved != null) break; }}
		if (resolved == null && isAbsoluteFile(url))
			resolved = url;
		if (resolved != null)
			resolverCache.put(url, resolved);
		return resolved;
	}
	
	private final Map<URL,URL> resolverCache = new HashMap<URL,URL>();
	
	private static final Logger logger = LoggerFactory.getLogger(ResourceRegistry.class);
}
