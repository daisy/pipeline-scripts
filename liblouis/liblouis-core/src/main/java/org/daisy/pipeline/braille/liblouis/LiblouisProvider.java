package org.daisy.pipeline.braille.liblouis;

import com.google.common.base.Predicate;
import com.google.common.collect.Iterables;

import java.net.URL;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.NoSuchElementException;
import java.util.Set;

import org.daisy.pipeline.braille.Binary;
import org.daisy.pipeline.braille.ResourceRegistry;
import org.daisy.pipeline.braille.Utilities.OS;
import org.daisy.pipeline.braille.liblouis.internal.LiblouisJnaImpl;
import org.daisy.pipeline.braille.liblouis.internal.LiblouisutdmlProcessBuilderImpl;

import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.service.component.ComponentContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisProvider {
	
	private BundleContext bundleContext;
	private boolean initialized = false;
	
	public void activate(ComponentContext context) {
		if (!initialized) {
			bundleContext = context.getBundleContext();
			initialized = true; }
		publishServices();
	}
	
	public void deactivate() {
		unpublishServices();
	}
	
	private LiblouisTableRegistry tableRegistry = new LiblouisTableRegistry();
	
	public void addTablePath(LiblouisTablePath path) {
		tableRegistry.register(path);
	}
	
	public void removeTablePath(LiblouisTablePath path) {
		tableRegistry.unregister(path);
	}
	
	private LiblouisJnaImpl liblouis;
	private Liblouisutdml liblouisutdml;
	private ServiceRegistration liblouisRegistration;
	private ServiceRegistration liblouisutdmlRegistration;
	private ServiceRegistration tableLookupRegistration;
	
	private void publishServices() {
		if (!initialized) return;
		if (tableLookupRegistration == null) {
			tableLookupRegistration = bundleContext.registerService(
					LiblouisTableLookup.class.getName(), tableRegistry, null);
			logger.debug("Publishing liblouis table lookup service"); }
		if (liblouisRegistration == null) {
			try {
				if (liblouis == null) {
					liblouis = new LiblouisJnaImpl(
						getBinaryPaths("liblouis"),
						bundleContext.getDataFile("native/liblouis"),
						tableRegistry); }
				liblouisRegistration = bundleContext.registerService(
					Liblouis.class.getName(), liblouis, null);
				logger.debug("Publishing liblouis service"); }
			catch (IllegalArgumentException e) {}
			catch (NoSuchElementException e) {}}
		if (liblouisutdmlRegistration == null) {
			try {
				if (liblouisutdml == null) {
					liblouisutdml = new LiblouisutdmlProcessBuilderImpl(
						getBinaryPaths("file2brl"),
						bundleContext.getDataFile("native/file2brl"),
						tableRegistry); }
				liblouisutdmlRegistration = bundleContext.registerService(
					Liblouisutdml.class.getName(), liblouisutdml, null);
				logger.debug("Publishing liblouisutdml service"); }
			catch (IllegalArgumentException e) {}
			catch (NoSuchElementException e) {}}
	}
	
	private void unpublishServices() {
		if (tableLookupRegistration != null) {
			tableLookupRegistration.unregister();
			tableLookupRegistration = null;
			logger.debug("Unpublishing liblouis table lookup service"); }
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
