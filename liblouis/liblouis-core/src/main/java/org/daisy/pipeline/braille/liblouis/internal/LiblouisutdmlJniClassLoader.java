package org.daisy.pipeline.braille.liblouis.internal;

import java.io.File;
import java.lang.reflect.Method;
import java.net.URL;

import org.daisy.pipeline.braille.JarClassLoader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisutdmlJniClassLoader extends JarClassLoader {
	
	public LiblouisutdmlJniClassLoader(Iterable<URL> jarURLs, File nativeDirectory) {
		
		super(jarURLs);
		
		try {
			String liblouisPath = null;
			String liblouisutdmlPath = null;
			for (String file : nativeDirectory.list()) {
				if (file.startsWith("liblouisutdml"))
					liblouisutdmlPath = nativeDirectory.getAbsolutePath() + File.separator + file;
				else if (file.startsWith("liblouis"))
					liblouisPath = nativeDirectory.getAbsolutePath() + File.separator + file;}
			Method loadLibrary = loadClass("org.liblouis.liblouisutdml")
					.getMethod("loadLibrary", String.class, String.class);
			loadLibrary.invoke(null, liblouisPath, liblouisutdmlPath);
			logger.debug("Loading liblouisutdml native libraries"); }
		catch (Exception e) {
			throw new RuntimeException("Failed to load liblouisutdml native libraries", e); }
	}
	
	public void finalize() {
		logger.debug("Unloading liblouisutdml native libraries");
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisutdmlJniClassLoader.class);
}
