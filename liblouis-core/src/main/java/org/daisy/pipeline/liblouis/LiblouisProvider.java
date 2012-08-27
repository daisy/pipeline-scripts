package org.daisy.pipeline.liblouis;

import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.daisy.pipeline.liblouis.Utilities.Collections;
import org.daisy.pipeline.liblouis.Utilities.OS;
import org.daisy.pipeline.liblouis.Utilities.Predicates;
import org.daisy.pipeline.liblouis.Utilities.Strings;
import org.daisy.pipeline.liblouis.internal.Environment;
import org.daisy.pipeline.liblouis.internal.LiblouisJnaImpl;
import org.daisy.pipeline.liblouis.internal.LiblouisTableFinderImpl;
import org.daisy.pipeline.liblouis.internal.LiblouisutdmlJniImpl;

import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.service.component.ComponentContext;

public class LiblouisProvider implements LiblouisTableRegistry {

	private Environment environment;
	private LiblouisJnaImpl liblouis;
	private LiblouisutdmlJniImpl liblouisutdml;
	private LiblouisTableFinderImpl tableFinder;
	private ServiceRegistration liblouisRegistration;
	private ServiceRegistration liblouisutdmlRegistration;
	private ServiceRegistration tableFinderRegistration;
	private boolean initialized = false;
	
	public LiblouisProvider() {
		tableFinder = new LiblouisTableFinderImpl();
	}
	
	public void activate(ComponentContext context) {
		BundleContext bundleContext = context.getBundleContext();
		if (!initialized) initialize(bundleContext);
		publishServices(bundleContext);
	}
	
	public void deactivate() {
		unpublishServices();
		liblouis.unload();
		liblouisutdml.unload();
	}
	
	private void initialize(BundleContext bundleContext) {
		Bundle bundle = bundleContext.getBundle();
		@SuppressWarnings("unchecked")
		Enumeration<String> paths = bundle.getEntryPaths("/native");
		if (paths == null)
			throw new RuntimeException("Native libraries could not be found");
		Collection<URL> urls = new ArrayList<URL>();
		while (paths.hasMoreElements())
			urls.add(bundle.getEntry(paths.nextElement()));
		Collection<URL> liblouisJars = Collections.filter(urls,
				Predicates.<URL>matchesPattern(".*(jna|liblouis)\\.jar$"));
		Collection<URL> liblouisNative = Collections.filter(urls,
				Predicates.<URL>matchesPattern(".*liblouis\\.(?!jar)(\\w|\\.)+$"));
		Collection<URL> liblouisutdmlJars = Collections.filter(urls,
				Predicates.<URL>matchesPattern(".*liblouisutdml\\.jar$"));
		Collection<URL> liblouisutdmlNative = Collections.filter(urls,
				Predicates.<URL>matchesPattern(".*(?<!\\.jar)$"));
		environment = new Environment(liblouisJars);
		environment.setLouisTablePath(getLouisTablePath());
		liblouis = new LiblouisJnaImpl(liblouisJars, liblouisNative,
				bundleContext.getDataFile("native/liblouis"));
		liblouisutdml = new LiblouisutdmlJniImpl(liblouisutdmlJars, liblouisutdmlNative,
				bundleContext.getDataFile("native/liblouisutdml"));
		initialized = true;
	}
	
	private void publishServices(BundleContext bundleContext) {
		tableFinderRegistration = bundleContext.registerService(
				LiblouisTableFinder.class.getName(), (LiblouisTableFinder)tableFinder, null);
		liblouisRegistration = bundleContext.registerService(
				Liblouis.class.getName(), (Liblouis)liblouis, null);
		liblouisutdmlRegistration = bundleContext.registerService(
				Liblouisutdml.class.getName(), (Liblouisutdml)liblouisutdml, null);
	}
	
	private void unpublishServices() {
		if (liblouisRegistration != null) {
			liblouisRegistration.unregister();
			liblouisRegistration = null;
		}
		if (liblouisutdmlRegistration != null) {
			liblouisutdmlRegistration.unregister();
			liblouisutdmlRegistration = null;
		}
		if (tableFinderRegistration != null) {
			tableFinderRegistration.unregister();
			tableFinderRegistration = null;
		}
	}

	private final Map<String,LiblouisTableSet> tableSets = new HashMap<String,LiblouisTableSet>();
	
	public void addTableSet(LiblouisTableSet tableSet) {
		if (tableSets.containsKey(tableSet.getIdentifier())) {
			throw new RuntimeException("Table registry already contains table set with identifier " + tableSet.getIdentifier());
		}
		tableSets.put(tableSet.getIdentifier(), tableSet);
		try {
			if (initialized) {
				environment.setLouisTablePath(getLouisTablePath());
				if (OS.isWindows()) {
					liblouis.unload();
					liblouisutdml.unload();
				}
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
		if (initialized)
			environment.setLouisTablePath(getLouisTablePath());
		System.out.println("Removed table set from registry: " + tableSet.getIdentifier());
	}

	private String getLouisTablePath() {
		List<String> paths = new ArrayList<String>();
		for (LiblouisTableSet tableSet : tableSets.values()) {
			paths.add(tableSet.getPath().getAbsolutePath());
		}
		return Strings.join(paths, ",");
	}
}
