package org.daisy.pipeline.liblouis.internal;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.Collection;

public class Environment {

	private Method setLouisTablePath;
	
	public Environment(Collection<URL> jarURLs) {
		ClassLoader classLoader = new JarClassLoader(jarURLs);
		try {
			Class<?> EnvironmentClass = classLoader.loadClass("org.liblouis.util.Environment");
			setLouisTablePath = EnvironmentClass.getMethod("setLouisTablePath", String.class);
		} catch (Exception e) {
		}
	}
	
	
	public void setLouisTablePath(String path) {
		try {
			setLouisTablePath.invoke(null, path);
		} catch (InvocationTargetException e) {
			throw new RuntimeException(e.getCause());
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}
}