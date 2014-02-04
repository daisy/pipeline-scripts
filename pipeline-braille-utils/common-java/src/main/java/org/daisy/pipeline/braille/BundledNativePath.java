package org.daisy.pipeline.braille;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import com.google.common.base.Predicate;
import com.google.common.collect.Iterables;

import org.osgi.service.component.ComponentContext;

import static org.daisy.pipeline.braille.Utilities.Files.chmod775;
import static org.daisy.pipeline.braille.Utilities.URIs.asURI;
import static org.daisy.pipeline.braille.Utilities.OS;

public class BundledNativePath extends BundledResourcePath implements ResourceLookup<String,URI> {
	
	private static final String OS_FAMILY = "os.family";
	
	@Override
	protected void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		if (properties.get(UNPACK) != null)
			throw new IllegalArgumentException(UNPACK + " property not supported");
		super.activate(context, properties);
		lazyUnpack(context);
		if (properties.get(OS_FAMILY) == null
				|| properties.get(OS_FAMILY).toString().isEmpty()) {
			throw new IllegalArgumentException(OS_FAMILY + " property must not be empty"); }
		if (OS.Family.valueOf(properties.get(OS_FAMILY).toString().toUpperCase()) != OS.getFamily())
			throw new Exception(toString() + " does not work on " + OS.getFamily());
	}
	
	@Override
	public URL resolve(URI resource) {
		URL resolved = super.resolve(resource);
		if (resolved != null)
			maybeUnpack(asURI("."));
		return resolved;
	}
	
	/**
	 * Lookup an executable or a shared library.
	 * @param name The name (minus the extension)
	 * @return The executable or library, or null.
	 */
	public URI lookup(String name) {
		URI path;
		if ((path = lookupExecutable(name)) != null) {}
		else if ((path = lookupSharedLibrary(name)) != null) {}
		else { return null; }
		return canonicalize(path);
	}
	
	private URI lookupExecutable(String name) {
		String fileName = OS.isWindows() ? name + ".exe" : name;
		String os = OS.getFamily().toString().toLowerCase();
		String arch = OS.is64Bit() ? "x86_64" : "x86";
		List<URI> possiblePaths = new ArrayList<URI>();
		possiblePaths.add(asURI(arch + "/" + fileName));
		possiblePaths.add(asURI(os + "/" + arch + "/" + fileName));
		if (OS.is64Bit() && OS.isWindows()) {
			possiblePaths.add(asURI("x86/" + fileName));
			possiblePaths.add(asURI(os + "/x86/" + fileName)); }
		try {
			return Iterables.find(
				possiblePaths,
				new Predicate<URI>() { public boolean apply(URI p) { return resources.contains(p); }}); }
		catch (NoSuchElementException e) { return null; }
	}
	
 	private URI lookupSharedLibrary(String name) {
		String fileName = name + (OS.isWindows() ? ".dll" : OS.isMacOSX() ? ".dylib" : ".so");
		String os = OS.getFamily().toString().toLowerCase();
		String arch = OS.is64Bit() ? "x86_64" : "x86";
		List<URI> possiblePaths = new ArrayList<URI>();
		possiblePaths.add(asURI(arch + "/" + fileName));
		possiblePaths.add(asURI(os + "/" + arch + "/" + fileName));
		try {
			return Iterables.find(
				possiblePaths,
				new Predicate<URI>() { public boolean apply(URI p) { return resources.contains(p); }}); }
		catch (NoSuchElementException e) { return null; }
	}
	
	@Override
	protected void unpack(URL url, File file) {
		super.unpack(url, file);
		if (!OS.isWindows())
			chmod775(file);
	}
	
	@Override
	public boolean equals(Object object) {
		if (this == object)
			return true;
		if (object == null)
			return false;
		if (getClass() != object.getClass())
			return false;
		return super.equals((BundledResourcePath)object);
	}
}
