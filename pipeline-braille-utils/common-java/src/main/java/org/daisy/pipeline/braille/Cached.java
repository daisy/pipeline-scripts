package org.daisy.pipeline.braille;

import java.util.HashMap;
import java.util.Map;

public abstract class Cached<K,V> {
	
	private final Map<K,V> cache = new HashMap<K,V>();
	
	public abstract V delegate(K key);
	
	public V get(K key) {
		if (cache.containsKey(key))
			return cache.get(key);
		V value = delegate(key);
		if (value != null) {
			cache.put(key, value);
			return value; }
		return null;
	}
	
	public void invalidateCache() {
		cache.clear();
	}
}
