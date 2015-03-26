package org.daisy.pipeline.braille.common;

/**
 * Tag interface for anything that can transform a node.
 *
 * Classes that implement this interface must have some kind of "transform"
 * method.
 */
public interface Transform {
	
	public interface Provider<T extends Transform> extends org.daisy.pipeline.braille.common.Provider<String,T> {}
	
}
