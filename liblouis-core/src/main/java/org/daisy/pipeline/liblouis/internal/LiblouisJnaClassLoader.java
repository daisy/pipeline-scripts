package org.daisy.pipeline.liblouis.internal;

import java.io.File;
import java.lang.reflect.Method;
import java.net.URL;

public class LiblouisJnaClassLoader extends JarClassLoader {
	
	public LiblouisJnaClassLoader(Iterable<URL> jarURLs, File nativeDirectory) {
		
		super(jarURLs);
		
		try {
			
			Method addSearchPath = loadClass("com.sun.jna.NativeLibrary")
					.getMethod("addSearchPath", String.class, String.class);
			addSearchPath.invoke(null, "louis", nativeDirectory.getAbsolutePath());
			
			System.out.println("Loaded liblouis native library"); }
			
		catch (Exception e) {
			throw new RuntimeException("Failed to load liblouis native library", e); }
	}
	
	public void finalize() {
		System.out.println("Unloaded liblouis native library");
	}
}
