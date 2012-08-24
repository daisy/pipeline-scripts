package org.daisy.pipeline.liblouis;

import java.io.File;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.daisy.pipeline.liblouis.Utilities.FunctionalUtils;
import org.daisy.pipeline.liblouis.Utilities.FunctionalUtils.Predicate;
import org.daisy.pipeline.liblouis.Utilities.OSUtils;
import org.daisy.pipeline.liblouis.Utilities.StringUtils;
import org.daisy.pipeline.liblouis.internal.Environment;
import org.daisy.pipeline.liblouis.internal.JarClassLoader;
import org.daisy.pipeline.liblouis.internal.LiblouisClassLoader;
import org.daisy.pipeline.liblouis.internal.LiblouisImpl;
import org.daisy.pipeline.liblouis.internal.LiblouisTableFinderImpl;
import org.daisy.pipeline.liblouis.internal.LiblouisutdmlImpl;

import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.service.component.ComponentContext;

public class LiblouisProvider implements LiblouisTableRegistry {

	private BundleContext bundleContext = null;
	private Collection<URL> jarURLs = null;
	private Collection<URL> nativeURLs = null;
	private File unpackDirectory = null;
	private ServiceRegistration liblouisRegistration = null;
	private ServiceRegistration liblouisutdmlRegistration = null;
	private LiblouisTableFinderImpl tableFinder = new LiblouisTableFinderImpl();
	private Environment environment;
	
	public void activate(ComponentContext context) {
		bundleContext = context.getBundleContext();
		unpackDirectory = bundleContext.getDataFile("native");
		if (!unpackDirectory.exists()) {
			unpackDirectory.mkdir();
		}
		Bundle bundle = bundleContext.getBundle();
		@SuppressWarnings("unchecked")
		Enumeration<String> paths = bundle.getEntryPaths("/native");
		if (paths == null) {
			throw new RuntimeException("Native libraries could not be found");
		}
		Collection<URL> urls = new ArrayList<URL>();
		while (paths.hasMoreElements()) {
			urls.add(bundle.getEntry(paths.nextElement()));
		}
		Predicate<URL> isJar = new Predicate<URL>() {
			public boolean test(URL url) {
				return url.getPath().endsWith(".jar"); }};
		jarURLs = FunctionalUtils.filter(urls, isJar);
		nativeURLs = FunctionalUtils.filter(urls, FunctionalUtils.not(isJar));
		if (environment == null) {
			environment = new Environment(new JarClassLoader(jarURLs));
			environment.setLouisTablePath(getLouisTablePath());
		}
		bundleContext.registerService(LiblouisTableFinder.class.getName(), tableFinder, null);
		loadLiblouis();
	}
	
	public void deactivate() {
		unloadLiblouis();
	}
	
	private void loadLiblouis() {
		ClassLoader classLoader = new LiblouisClassLoader(jarURLs, nativeURLs, unpackDirectory);
		liblouisRegistration = bundleContext.registerService(Liblouis.class.getName(),
				(Liblouis)new LiblouisImpl(classLoader), null);
		liblouisutdmlRegistration = bundleContext.registerService(Liblouisutdml.class.getName(),
				(Liblouisutdml)new LiblouisutdmlImpl(classLoader), null);
	}
	
	private void unloadLiblouis() {
		if (liblouisRegistration != null) {
			liblouisRegistration.unregister();
			liblouisRegistration = null;
		}
		if (liblouisutdmlRegistration != null) {
			liblouisutdmlRegistration.unregister();
			liblouisutdmlRegistration = null;
		}
		System.gc();
	}
	
	private void reloadLiblouis() {
		unloadLiblouis();
		loadLiblouis();
	}

	private final Map<String,LiblouisTableSet> tableSets = new HashMap<String,LiblouisTableSet>();
	
	public void addTableSet(LiblouisTableSet tableSet) {
		if (tableSets.containsKey(tableSet.getIdentifier())) {
			throw new RuntimeException("Table registry already contains table set with identifier " + tableSet.getIdentifier());
		}
		tableSets.put(tableSet.getIdentifier(), tableSet);
		try {
			if (environment != null) {
				environment.setLouisTablePath(getLouisTablePath());
				if (OSUtils.isWindows()) reloadLiblouis();
			}
			tableFinder.addTableSet(tableSet);
		} catch (RuntimeException e) {
			tableSets.remove(tableSet.getIdentifier());
			throw e;
		}
		System.out.println("Added table set to registry: " + tableSet.getIdentifier());
	}

	public void removeTableSet(LiblouisTableSet tableSet) {
		tableSets.remove(tableSet.getIdentifier());
		tableFinder.removeTableSet(tableSet);
		if (environment != null)
			environment.setLouisTablePath(getLouisTablePath());
		System.out.println("Removed table set from registry: " + tableSet.getIdentifier());
	}

	private String getLouisTablePath() {
		List<String> paths = new ArrayList<String>();
		for (LiblouisTableSet tableSet : tableSets.values()) {
			paths.add(tableSet.getPath().getAbsolutePath());
		}
		return StringUtils.join(paths, ",");
	}
}
