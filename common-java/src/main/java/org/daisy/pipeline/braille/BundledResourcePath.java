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
import static org.daisy.pipeline.braille.Utilities.Files.isAbsoluteFile;
import static org.daisy.pipeline.braille.Utilities.Function0;
import static org.daisy.pipeline.braille.Utilities.Functions.noOp;
import static org.daisy.pipeline.braille.Utilities.Pair;
import static org.daisy.pipeline.braille.Utilities.Predicates.matchesGlobPattern;

import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

public abstract class BundledResourcePath implements ResourcePath {
	
	protected static final String IDENTIFIER = "identifier";
	protected static final String PATH = "path";
	protected static final String UNPACK = "unpack";
	protected static final String INCLUDES = "includes";
	
	protected URL identifier = null;
	protected URL path = null;
	protected Collection<String> resources = null;
	
	public URL getIdentifier() {
		return identifier;
	}
	
	public URL resolve(String resource) {
		if (resource.endsWith("/") && (resource.equals(path.toString()) || resource.equals(identifier.toString()))) {
			lazyUnpack.apply();
			return path; }
		String relativeURL = Files.relativize(resource.startsWith(path.toString()) ? path : identifier,
				Files.resolve(identifier, resource));
		if (includes(relativeURL)) {
			lazyUnpack.apply();
			return Files.resolve(path, relativeURL); }
		return null;
	}
	
	protected boolean includes(String path) {
		return resources.contains(path);
	}
	
	@SuppressWarnings("unchecked")
	protected void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		if (properties.get(IDENTIFIER) == null || properties.get(IDENTIFIER).toString().isEmpty()) {
			throw new IllegalArgumentException(IDENTIFIER + " property must not be empty"); }
		String id = properties.get(IDENTIFIER).toString();
		if (!id.endsWith("/")) id += "/";
		try { identifier = new URL(id); }
		catch (MalformedURLException e) {
			throw new IllegalArgumentException(IDENTIFIER + " could not be parsed into a URL"); }
		if (properties.get(PATH) == null || properties.get(PATH).toString().isEmpty()) {
			throw new IllegalArgumentException(PATH + " property must not be empty"); }
		final Bundle bundle = context.getBundleContext().getBundle();
		String relativePath = properties.get(PATH).toString();
		if (!relativePath.endsWith("/")) relativePath += "/";
		path = bundle.getEntry(relativePath);
		if (path == null)
			throw new IllegalArgumentException("Resource path at location " + relativePath + " could not be found");
		Predicate<String> includes =
			(properties.get(INCLUDES) != null && !properties.get(INCLUDES).toString().isEmpty()) ?
				matchesGlobPattern(properties.get(INCLUDES).toString()) :
				Predicates.<String>alwaysTrue();
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
						public String apply(String s) { return Files.relativize(path, bundle.getEntry(s)); }}),
				includes))
			.build();
		if (properties.get(UNPACK) != null && (Boolean)properties.get(UNPACK))
			lazyUnpack(context);
	}
	
	protected void unpack(File directory) {
		directory.mkdirs();
		for (String resource: resources)
			Files.unpack(Files.resolve(path, resource), new File(directory, resource));
		path = asURL(directory);
	}
	
	protected void unpack(ComponentContext context) {
		File directory;
		for (int i = 0; true; i++) {
			directory = context.getBundleContext().getDataFile("resources" + i);
			if (!directory.exists()) break; }
		unpack(directory);
	}
	
	private Function0<Void> lazyUnpack = noOp;
	
	protected void lazyUnpack(final ComponentContext context) {
		lazyUnpack = new Function0<Void>() {
			private boolean unpacked = false;
			public Void apply() {
				if (!unpacked) {
					unpack(context);
					unpacked = true; }
				return null; }};
	}
	
	@Override
	public String toString() {
		return identifier.toString();
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
