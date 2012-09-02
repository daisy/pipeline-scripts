package org.daisy.pipeline.liblouis.internal;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;

import org.daisy.pipeline.liblouis.LiblouisTableRegistry;
import org.daisy.pipeline.liblouis.Utilities.VoidFunction;

public class Environment {
	
	private Method setLouisTablePath;
	
	public Environment(Iterable<URL> jarURLs, LiblouisTableRegistry tableRegistry) {
		ClassLoader classLoader = new JarClassLoader(jarURLs);
		try {
			Class<?> EnvironmentClass = classLoader.loadClass("org.liblouis.util.Environment");
			setLouisTablePath = EnvironmentClass.getMethod("setLouisTablePath", String.class); }
		catch (Exception e) {}
		tableRegistry.onLouisTablePathUpdate(new VoidFunction<String>() {
			public void apply(String tablePath) {
				setLouisTablePath(tablePath); }});
	}
	
	private void setLouisTablePath(String path) {
		try {
			setLouisTablePath.invoke(null, path); }
		catch (InvocationTargetException e) {
			throw new RuntimeException(e.getCause()); }
		catch (Exception e) {
			throw new RuntimeException(e); }
	}
}