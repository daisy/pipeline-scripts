package org.daisy.pipeline.liblouis;

import com.google.common.base.Function;
import com.google.common.base.Predicate;
import com.google.common.collect.Iterables;

import java.io.File;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Set;

import org.daisy.pipeline.liblouis.Utilities.OS;
import org.daisy.pipeline.liblouis.Utilities.Predicates;
import org.daisy.pipeline.liblouis.Utilities.Strings;
import org.daisy.pipeline.liblouis.Utilities.VoidFunction;
import org.daisy.pipeline.liblouis.internal.Environment;
import org.daisy.pipeline.liblouis.internal.LiblouisJnaImpl;
import org.daisy.pipeline.liblouis.internal.LiblouisTableFinderImpl;
import org.daisy.pipeline.liblouis.internal.LiblouisutdmlJniImpl;
import org.daisy.pipeline.liblouis.internal.LiblouisutdmlRuntimeExecImpl;

import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.service.component.ComponentContext;

public class LiblouisProvider implements LiblouisTableRegistry {
	
	private BundleContext bundleContext;
	private boolean initialized = false;
	
	public void activate(ComponentContext context) {
		if (!initialized) {
			bundleContext = context.getBundleContext();
			initialize();
			initialized = true; }
		publishServices();
	}
	
	public void deactivate() {
		unpublishServices();
		if (liblouis != null) liblouis.unload();
		if (liblouisutdml != null && !OS.isWindows())
			((LiblouisutdmlJniImpl)liblouisutdml).unload();
	}
	
	private Iterable<URL> jars = null;
	
	@SuppressWarnings("unchecked")
	private void initialize() {
		final Bundle bundle = bundleContext.getBundle();
		jars = Iterables.<String,URL>transform(
			Collections.<String>list(bundle.getEntryPaths("/jars")),
			new Function<String,URL>() {
				public URL apply(String s) { return bundle.getEntry(s); }});
	}
	
	private LiblouisJnaImpl liblouis;
	private Liblouisutdml liblouisutdml;
	private LiblouisTableFinderImpl tableFinder = new LiblouisTableFinderImpl();
	private ServiceRegistration liblouisRegistration;
	private ServiceRegistration liblouisutdmlRegistration;
	private ServiceRegistration tableFinderRegistration;
	
	private void publishServices() {
		if (!initialized) return;
		if (liblouisRegistration == null) {
			try {
				if (liblouis == null) {
					liblouis = new LiblouisJnaImpl(
						Iterables.<URL>filter(jars, Predicates.<URL>matchesPattern(".*(jna|liblouis)\\.jar$")),
						getBinaryPaths("liblouis"),
						bundleContext.getDataFile("native/liblouis"),
						this); }
				liblouisRegistration = bundleContext.registerService(
					Liblouis.class.getName(), liblouis, null); }
			catch (IllegalArgumentException e) {}
			catch (NoSuchElementException e) {}}
		if (liblouisutdmlRegistration == null) {
			try {
				if (liblouisutdml == null) {
					if (OS.isWindows()) {
						liblouisutdml = new LiblouisutdmlRuntimeExecImpl(
							getBinaryPaths("file2brl"),
							bundleContext.getDataFile("native/file2brl"),
							this); }
					else {
						liblouisutdml = new LiblouisutdmlJniImpl(
							Iterables.<URL>filter(jars, Predicates.<URL>matchesPattern(".*liblouisutdml\\.jar$")),
							getBinaryPaths("liblouisutdml"),
							bundleContext.getDataFile("native/liblouisutdml"),
							this); }}
				liblouisutdmlRegistration = bundleContext.registerService(
					Liblouisutdml.class.getName(), liblouisutdml, null); }
			catch (IllegalArgumentException e) {}
			catch (NoSuchElementException e) {}}
		if (tableFinderRegistration == null) {
			tableFinderRegistration = bundleContext.registerService(
				LiblouisTableFinder.class.getName(), tableFinder, null); }
	}
	
	private void unpublishServices() {
		if (liblouisRegistration != null) {
			liblouisRegistration.unregister();
			liblouisRegistration = null; }
		if (liblouisutdmlRegistration != null) {
			liblouisutdmlRegistration.unregister();
			liblouisutdmlRegistration = null; }
		if (tableFinderRegistration != null) {
			tableFinderRegistration.unregister();
			tableFinderRegistration = null; }
	}
	
	private final Set<Binary> binaries = new HashSet<Binary>();
	private final static Predicate<Binary> binaryFilter
		= new Predicate<Binary>() {
			private final Collection<String> names
				= Arrays.asList(new String[]{"liblouis", "liblouisutdml", "file2brl"});
			public boolean apply(Binary binary) {
				if (!names.contains(binary.getName()))
					return false;
				if (OS.getFamily() != binary.getOsFamily())
					return false;
				if ("file2brl".equals(binary.getName()))
					return true;
				return binary.getOsArchs().contains(OS.getArch()); }};
	
	public void addBinary(Binary binary) {
		if (binaryFilter.apply(binary)) {
			binaries.add(binary);
			publishServices(); }
	}
	
	public void removeBinary(Binary binary) {
		binaries.remove(binary);
	}
	
	private Iterable<URL> getBinaryPaths(final String name) {
		return Iterables.<Binary>getOnlyElement(
			Iterables.<Binary>filter(binaries,
				new Predicate<Binary>() {
					public boolean apply(Binary binary) {
						return name.equals(binary.getName()); }})).getPaths();
	}

	private final Map<String,LiblouisTableSet> tableSets = new HashMap<String,LiblouisTableSet>();
	
	public void addTableSet(LiblouisTableSet tableSet) {
		if (tableSets.containsKey(tableSet.getIdentifier()))
			throw new RuntimeException("Table registry already contains table set with identifier " + tableSet.getIdentifier());
		tableSets.put(tableSet.getIdentifier(), tableSet);
		try {
			for (VoidFunction<String> f : callbacks) f.apply(getLouisTablePath());
			tableFinder.addTableSet(tableSet); }
		catch (RuntimeException e) {
			tableSets.remove(tableSet.getIdentifier());
			throw e; }
		urlResolverCache.clear();
		System.out.println("Added table set to registry: " + tableSet.getIdentifier());
	}

	public void removeTableSet(LiblouisTableSet tableSet) {
		tableSets.remove(tableSet.getIdentifier());
		tableFinder.removeTableSet(tableSet);
		urlResolverCache.clear();
		for (VoidFunction<String> f : callbacks) f.apply(getLouisTablePath());
		System.out.println("Removed table set from registry: " + tableSet.getIdentifier());
	}
	
	private final Map<String,String> urlResolverCache = new HashMap<String,String>();
	
	public String resolveTableURL(String table) {
		String resolved = urlResolverCache.get(table);
		if (resolved == null) {
			try {
				int i = table.lastIndexOf('/') + 1;
				File path = tableSets.get(table.substring(0, i)).getPath();
				resolved = path.getAbsolutePath() + File.separator + table.substring(i);
				urlResolverCache.put(table, resolved); }
			catch (Exception e) {
				throw new RuntimeException("Cannot resolve table URL: " + table, e); }}
		return resolved;
	}
	
	private Collection<VoidFunction<String>> callbacks = new ArrayList<VoidFunction<String>>();
	
	public void onLouisTablePathUpdate(VoidFunction<String> callback) {
		callback.apply(getLouisTablePath());
		callbacks.add(callback);
	}

	private String getLouisTablePath() {
		Collection<String> paths = new ArrayList<String>();
		for (LiblouisTableSet tableSet : tableSets.values())
			paths.add(tableSet.getPath().getAbsolutePath());
		return Strings.join(paths.iterator(), ",");
	}
}
