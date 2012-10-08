package org.daisy.pipeline.liblouis;

import com.google.common.base.Function;
import com.google.common.base.Predicate;
import com.google.common.collect.Iterables;

import java.net.URL;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.NoSuchElementException;
import java.util.Set;

import org.daisy.pipeline.braille.Binary;
import org.daisy.pipeline.braille.TableRegistry;
import org.daisy.pipeline.braille.Utilities.OS;
import org.daisy.pipeline.braille.Utilities.Predicates;
import org.daisy.pipeline.liblouis.internal.LiblouisJnaImpl;
import org.daisy.pipeline.liblouis.internal.LiblouisutdmlJniImpl;
import org.daisy.pipeline.liblouis.internal.LiblouisutdmlProcessBuilderImpl;

import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.service.component.ComponentContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisProvider extends TableRegistry<LiblouisTablePath> implements LiblouisTableResolver, LiblouisTableFinder {
	
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
	private ServiceRegistration liblouisRegistration;
	private ServiceRegistration liblouisutdmlRegistration;
	
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
					Liblouis.class.getName(), liblouis, null);
				logger.debug("Publishing liblouis service"); }
			catch (IllegalArgumentException e) {}
			catch (NoSuchElementException e) {}}
		if (liblouisutdmlRegistration == null) {
			try {
				if (liblouisutdml == null) {
					if (OS.isWindows()) {
						liblouisutdml = new LiblouisutdmlProcessBuilderImpl(
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
					Liblouisutdml.class.getName(), liblouisutdml, null);
				logger.debug("Publishing liblouisutdml service"); }
			catch (IllegalArgumentException e) {}
			catch (NoSuchElementException e) {}}
	}
	
	private void unpublishServices() {
		if (liblouisRegistration != null) {
			liblouisRegistration.unregister();
			liblouisRegistration = null;
			logger.debug("Unpublishing liblouis service"); }
		if (liblouisutdmlRegistration != null) {
			liblouisutdmlRegistration.unregister();
			liblouisutdmlRegistration = null;
			logger.debug("Unpublishing liblouisutdml service"); }
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
				if (OS.isWindows() && "file2brl".equals(binary.getName()))
					return true;
				return binary.getOsArchs().contains(OS.getArch()); }};
	
	public void addBinary(Binary binary) {
		if (binaryFilter.apply(binary)) {
			binaries.add(binary);
			publishServices();
			logger.debug("Registering binary '" + binary + "'"); }
		else
			logger.debug("Binary '" + binary + "' does not work on platform '" + OS.getFamily() + " (" + OS.getArch() + ")'");
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
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisProvider.class);
}
