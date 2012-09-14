package org.daisy.pipeline.braille;

import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;

public class JarClassLoader extends URLClassLoader {
	
	public JarClassLoader(Iterable<URL> urls) {
		
		super(new URL[0], JarClassLoader.class.getClassLoader());
		
		int jarCount = 0;
		for (URL url : urls) {
			if (!url.getPath().endsWith(".jar"))
				continue;
			try {
				addURL(new URL("jar:" + url.toExternalForm() + "!/"));
				jarCount++; }
			catch (MalformedURLException e) {}}
		if (jarCount == 0)
			throw new IllegalArgumentException("No JARs could be loaded");
	}
}
