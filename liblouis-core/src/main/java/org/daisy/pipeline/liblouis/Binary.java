package org.daisy.pipeline.liblouis;

import com.google.common.base.Function;
import com.google.common.base.Splitter;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterables;

import java.net.URL;
import java.util.Collection;
import java.util.Map;

import org.daisy.pipeline.liblouis.Utilities.OS;
import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

public class Binary {

	private static final String NAME = "name";
	private static final String PATH = "path";
	private static final String OS_FAMILY = "os.family";
	private static final String OS_ARCH = "os.arch";

	private String name = null;
	private Iterable<URL> paths = null;
	private OS.Family family = null;
	private Collection<String> archs = null;

	public String getName() {
		return name;
	}

	/**
	 * First URL is the binary. Following URLs are the dependencies.
	 */
	public Iterable<URL> getPaths() {
		return paths;
	}

	public OS.Family getOsFamily() {
		return family;
	}
	
	public Collection<String> getOsArchs() {
		return archs;
	}

	private static final Splitter commaSplitter = Splitter.on(',').trimResults();

	public void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		if (properties.get(NAME) == null
				|| properties.get(NAME).toString().isEmpty()) {
			throw new IllegalArgumentException(NAME + " property must not be empty"); }
		name = properties.get(NAME).toString();
		if (properties.get(OS_FAMILY) == null
				|| properties.get(OS_FAMILY).toString().isEmpty()) {
			throw new IllegalArgumentException(OS_FAMILY + " property must not be empty"); }
		family = OS.Family.valueOf(properties.get(OS_FAMILY).toString().toUpperCase());
		if (properties.get(OS_ARCH) == null
				|| properties.get(OS_ARCH).toString().isEmpty()) {
			throw new IllegalArgumentException(OS_ARCH + " property must not be empty"); }
		archs = new ImmutableList.Builder<String>()
				.addAll(commaSplitter.split(properties.get(OS_ARCH).toString()))
				.build();
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
		if (!this.name.equals(that.name))
			return false;
		if (!this.paths.equals(that.paths))
			return false;
		if (!this.family.equals(that.family))
			return false;
		if (!this.archs.equals(that.archs))
			return false;
		return true;
	}
}
