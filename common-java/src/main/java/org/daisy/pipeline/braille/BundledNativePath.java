package org.daisy.pipeline.braille;

import java.io.File;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import com.google.common.base.Predicate;
import com.google.common.collect.Iterables;

import org.osgi.service.component.ComponentContext;

import static org.daisy.pipeline.braille.Utilities.Files.chmod775;
import static org.daisy.pipeline.braille.Utilities.Files.resolveURL;
import static org.daisy.pipeline.braille.Utilities.OS;

public class BundledNativePath extends BundledResourcePath implements ResourceLookup<String> {
	
	private static final String OS_FAMILY = "os.family";
	
	@Override
	protected void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		super.activate(context, properties);
		if (properties.get(OS_FAMILY) == null
				|| properties.get(OS_FAMILY).toString().isEmpty()) {
			throw new IllegalArgumentException(OS_FAMILY + " property must not be empty"); }
		if (OS.Family.valueOf(properties.get(OS_FAMILY).toString().toUpperCase()) != OS.getFamily())
			throw new Exception(toString() + " does not work on " + OS.getFamily());
	}
	
	public URL lookup(String name) {
		String path;
		if ((path = lookupExecutable(name)) != null) {}
		else if ((path = lookupSharedLibrary(name)) != null) {}
		else { return null; }
		return resolveURL(identifier, path);
	}
	
	protected String lookupExecutable(String name) {
		String fileName = OS.isWindows() ? name + ".exe" : name;
		String os = OS.getFamily().toString().toLowerCase();
		String arch = OS.is64Bit() ? "x86_64" : "x86";
		List<String> possiblePaths = new ArrayList<String>();
		possiblePaths.add(arch + "/" + fileName);
		possiblePaths.add(os + "/" + arch + "/" + fileName);
		if (OS.is64Bit() && OS.isWindows()) {
			possiblePaths.add("x86/" + fileName);
			possiblePaths.add(os + "/x86/" + fileName); }
		try {
			return Iterables.find(possiblePaths,
				new Predicate<String>() { public boolean apply(String s) { return includes(s); }}); }
		catch (NoSuchElementException e) { return null; }
	}
	
	protected String lookupSharedLibrary(String name) {
		String fileName = name + (OS.isWindows() ? ".dll" : OS.isMacOSX() ? ".dylib" : ".so");
		String os = OS.getFamily().toString().toLowerCase();
		String arch = OS.is64Bit() ? "x86_64" : "x86";
		List<String> possiblePaths = new ArrayList<String>();
		possiblePaths.add(arch + "/" + fileName);
		possiblePaths.add(os + "/" + arch + "/" + fileName);
		try {
			return Iterables.find(possiblePaths,
				new Predicate<String>() { public boolean apply(String s) { return includes(s); }}); }
		catch (NoSuchElementException e) { return null; }
	}
	
	@Override
	protected void unpack(File directory) {
		super.unpack(directory);
		if (!OS.isWindows())
			for (String resource: resources)
				chmod775(new File(directory, resource));
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
