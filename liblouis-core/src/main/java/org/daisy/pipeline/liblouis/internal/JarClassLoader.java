package org.daisy.pipeline.liblouis.internal;

import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.Collection;

public class JarClassLoader extends URLClassLoader {
	
	public JarClassLoader(Collection<URL> urls) {
		
		super(new URL[0], JarClassLoader.class.getClassLoader());
		
		for (URL url : urls) {
			if (!url.getPath().endsWith(".jar"))
				continue;
			try {
				addURL(new URL("jar:" + url.toExternalForm() + "!/"));
			} catch (MalformedURLException e) {}
		}
	}
}
