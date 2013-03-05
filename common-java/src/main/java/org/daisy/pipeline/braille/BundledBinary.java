package org.daisy.pipeline.braille;

import static org.daisy.pipeline.braille.Utilities.Files.asURL;
import static org.daisy.pipeline.braille.Utilities.Files.chmod775;

import com.google.common.base.Function;
import com.google.common.base.Splitter;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterables;

import java.io.File;
import java.net.URL;
import java.util.Collection;
import java.util.Map;

import org.daisy.pipeline.braille.Utilities.Files;
import org.daisy.pipeline.braille.Utilities.OS;
import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

public class BundledBinary implements Binary {
	
	private static final String NAME = "name";
	private static final String PATH = "path";
	private static final String OS_FAMILY = "os.family";
	private static final String OS_ARCH = "os.arch";
	private static final String UNPACK = "unpack";
	
	private String name = null;
	private Iterable<URL> paths = null;
	private OS.Family family = null;
	private Collection<String> archs = null;
	private String componentName = null;
	private File unpackDirectory = null;
	private boolean unpacked = false;
	
	public String getName() {
		return name;
	}
	
	/**
	 * {@inheritDoc}
	 */
	public Iterable<URL> getPaths() {
		// lazy unpack!
		if (unpackDirectory != null && !unpacked)
			paths = Iterables.transform(
				Files.unpack(paths.iterator(), unpackDirectory),
				new Function<File,URL>() { public URL apply(File file) {
					if (!file.getName().matches(".*\\.(dll|exe)$")) chmod775(file);
					return asURL(file); }});
		return paths;
	}
	
	public OS.Family getOsFamily() {
		return family;
	}
	
	public Collection<String> getOsArchs() {
		return archs;
	}
	
	private static final Splitter commaSplitter = Splitter.on(',').trimResults();
	
	protected void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		componentName = properties.get("component.name").toString();
		if (properties.get(NAME) == null
				|| properties.get(NAME).toString().isEmpty()) {
			throw new IllegalArgumentException(NAME + " property must not be empty"); }
		name = properties.get(NAME).toString();
		if (properties.get(OS_FAMILY) == null
				|| properties.get(OS_FAMILY).toString().isEmpty()) {
			throw new IllegalArgumentException(OS_FAMILY + " property must not be empty"); }
		family = OS.Family.valueOf(properties.get(OS_FAMILY).toString().toUpperCase());
		if (family != OS.getFamily())
			throw new Exception(toString() + " does not work on " + OS.getFamily());
		if (properties.get(OS_ARCH) == null
				|| properties.get(OS_ARCH).toString().isEmpty()) {
			throw new IllegalArgumentException(OS_ARCH + " property must not be empty"); }
		archs = new ImmutableList.Builder<String>()
				.addAll(commaSplitter.split(properties.get(OS_ARCH).toString()))
				.build();
		if (!archs.contains(OS.getArch()))
			throw new Exception(toString() + " does not work on " + OS.getArch());
		if (properties.get(PATH) == null
				|| properties.get(PATH).toString().isEmpty()) {
			throw new IllegalArgumentException(PATH + " property must not be empty"); }
		final Bundle bundle = context.getBundleContext().getBundle();
		paths = Iterables.transform(
			commaSplitter.split(properties.get(PATH).toString()),
			new Function<String,URL>() {
				public URL apply(String s) {
					URL url = bundle.getEntry(s);
					if (url == null) throw new IllegalArgumentException(
						"Binary at location " + s + " could not be found");
					return url; }});
		if (properties.get(UNPACK) != null && (Boolean)properties.get(UNPACK))
			for (int i = 0; true; i++) {
				unpackDirectory = context.getBundleContext().getDataFile("resources" + i);
				if (!unpackDirectory.exists()) break; }
	}
	
	@Override
	public String toString() {
		return componentName;
	}
	
	@Override
	public int hashCode() {
		final int prime = 37;
		int hash = 1;
		hash = prime * hash + name.hashCode();
		hash = prime * hash + paths.hashCode();
		hash = prime * hash + family.hashCode();
		hash = prime * hash + archs.hashCode();
		return hash;
	}
	
	@Override
	public boolean equals(Object object) {
		if (this == object)
			return true;
		if (object == null)
			return false;
		if (getClass() != object.getClass())
			return false;
		Binary that = (Binary)object;
		if (!this.name.equals(that.getName()))
			return false;
		if (!this.paths.equals(that.getPaths()))
			return false;
		if (!this.family.equals(that.getOsFamily()))
			return false;
		if (!this.archs.equals(that.getOsArchs()))
			return false;
		return true;
	}
}
