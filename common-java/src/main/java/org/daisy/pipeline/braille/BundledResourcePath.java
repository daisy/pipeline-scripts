package org.daisy.pipeline.braille;

import com.google.common.base.Function;
import com.google.common.base.Predicate;
import com.google.common.base.Predicates;
import com.google.common.collect.Collections2;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterators;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;

import static org.daisy.pipeline.braille.Utilities.Iterators.partition;
import static org.daisy.pipeline.braille.Utilities.Files;
import static org.daisy.pipeline.braille.Utilities.Files.asURL;
import static org.daisy.pipeline.braille.Utilities.Files.relativizeURL;
import static org.daisy.pipeline.braille.Utilities.Files.resolveURL;
import static org.daisy.pipeline.braille.Utilities.Pair;

import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

public abstract class BundledResourcePath implements ResourcePath {
	
	protected static final String IDENTIFIER = "identifier";
	protected static final String PATH = "path";
	//protected static final String INCLUDES = "includes";
	
	protected URL identifier = null;
	protected URL path = null;
	protected Collection<String> resources = null;
	
	public URL getIdentifier() {
		return identifier;
	}
	
	public URL resolve(URL url) {
		String relativeURL = relativizeURL(identifier, url);
		if (includes(relativeURL) || relativeURL.equals(""))
			return resolveURL(path, relativeURL);
		return null;
	}
	
	protected boolean includes(String name) {
		return resources.contains(name);
	}
	
	@SuppressWarnings("unchecked")
	protected void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		if (properties.get(IDENTIFIER) == null
				|| properties.get(IDENTIFIER).toString().isEmpty()) {
			throw new IllegalArgumentException(IDENTIFIER + " property must not be empty"); }
		String id = properties.get(IDENTIFIER).toString();
		if (!id.endsWith("/")) id += "/";
		try {
			identifier = new URL(id); }
		catch (MalformedURLException e) {
			throw new IllegalArgumentException(IDENTIFIER + " could not be parsed into a URL"); }
		if (properties.get(PATH) == null
				|| properties.get(PATH).toString().isEmpty()) {
			throw new IllegalArgumentException(PATH + " property must not be empty"); }
		final Bundle bundle = context.getBundleContext().getBundle();
		String relativePath = properties.get(PATH).toString();
		if (!relativePath.endsWith("/")) relativePath += "/";
		path = bundle.getEntry(relativePath);
		if (path == null)
			throw new IllegalArgumentException("Resource path at location " + relativePath + " could not be found");
		
		Predicate<String> includes = Predicates.<String>alwaysTrue();
		// TODO if (properties.get(INCLUDES) != null) --> includes = globMatcher(...)
		
		Function<String,Collection<String>> getFilePaths = new Function<String,Collection<String>>() {
			public Collection<String> apply(String path) {
				Pair<Collection<String>,Collection<String>> entries = partition(
					Iterators.<String>forEnumeration(bundle.getEntryPaths(path)),
					new Predicate<String>() { public boolean apply(String s) { return s.endsWith("/"); }});
				Collection<String> files = new ArrayList<String>();
				files.addAll(entries._2);
				for (String folder : entries._1) files.addAll(apply(folder));
				return files; }};
		
		resources = new ImmutableList.Builder<String>()
			.addAll(Collections2.<String>filter(
				Collections2.<String,String>transform(
					getFilePaths.apply(relativePath),
					new Function<String,String>() {
						public String apply(String s) { return relativizeURL(path, bundle.getEntry(s)); }}),
				includes))
			.build();
	}
	
	protected void unpack(ComponentContext context) {
		File directory;
		for (int i = 0; true; i++) {
			directory = context.getBundleContext().getDataFile("resources" + i);
			if (!directory.exists()) break; }
		for (String resource: resources)
			Files.unpack(resolveURL(path, resource), new File(directory, resource));
		path = asURL(directory);
	}
	
	@Override
	public String toString() {
		return identifier.toExternalForm();
	}
	
	@Override
	public int hashCode() {
		final int prime = 31;
		int hash = 1;
		hash = prime * hash + ((identifier == null) ? 0 : identifier.hashCode());
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
		ResourcePath that = (ResourcePath)object;
		if (!this.identifier.equals(that.getIdentifier()))
			return false;
		return true;
	}
}