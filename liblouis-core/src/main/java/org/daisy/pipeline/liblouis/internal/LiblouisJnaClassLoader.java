package org.daisy.pipeline.liblouis.internal;

import java.io.File;
import java.lang.reflect.Method;
import java.net.URL;

import org.daisy.pipeline.braille.JarClassLoader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisJnaClassLoader extends JarClassLoader {
	
	public LiblouisJnaClassLoader(Iterable<URL> jarURLs, File nativeDirectory) {
		
		super(jarURLs);
		
		try {
			Method addSearchPath = loadClass("com.sun.jna.NativeLibrary")
					.getMethod("addSearchPath", String.class, String.class);
			addSearchPath.invoke(null, "louis", nativeDirectory.getAbsolutePath());
			logger.debug("Loading liblouis native library"); }
		catch (Exception e) {
			throw new RuntimeException("Failed to load liblouis native library", e); }
	}
	
	public void finalize() {
		logger.debug("Unloading liblouis native library");
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisJnaClassLoader.class);
}
