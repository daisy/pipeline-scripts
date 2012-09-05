package org.daisy.pipeline.liblouis;

import com.google.common.base.Function;
import com.google.common.collect.Iterators;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Map;

import org.daisy.pipeline.liblouis.Utilities.Files;
import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

public class LiblouisTableSet {

	private static final String IDENTIFIER = "identifier";
	private static final String DIRECTORY = "directory";
	private static final String MANIFEST = "manifest";

	private String identifier = null;
	private File path = null;
	private URL manifest = null;

	public String getIdentifier() {
		return identifier;
	}

	public File getPath() {
		return path;
	}

	public URL getManifest() {
		return manifest;
	}

	@SuppressWarnings("unchecked")
	public void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		if (properties.get(IDENTIFIER) == null
				|| properties.get(IDENTIFIER).toString().isEmpty()) {
			throw new IllegalArgumentException(IDENTIFIER + " property must not be empty"); }
		identifier = properties.get(IDENTIFIER).toString();
		try {
			new URL(identifier);}
		catch (MalformedURLException e) {
			throw new IllegalArgumentException(IDENTIFIER + " could not be parsed into a URL"); }
		if (!identifier.endsWith("/"))
			throw new IllegalArgumentException(IDENTIFIER + " must end with a forward slash");
		if (properties.get(DIRECTORY) == null
				|| properties.get(DIRECTORY).toString().isEmpty()) {
			throw new IllegalArgumentException(DIRECTORY + " property must not be empty"); }
		String directory = properties.get(DIRECTORY).toString();
		path = context.getBundleContext().getDataFile("tables");
		final Bundle bundle = context.getBundleContext().getBundle();
		if (!path.exists()) {
			path.mkdir();
			if (bundle.getEntry(directory) == null)
				throw new IllegalArgumentException("Table directory at location " + directory + " could not be found");
			Files.unpack(
				Iterators.<String,URL>transform(
					Iterators.<String>forEnumeration(bundle.getEntryPaths(directory)),
					new Function<String,URL>() {
						public URL apply(String s) { return bundle.getEntry(s); }}),
				path); }
		if (properties.get(MANIFEST) != null) {
			String manifestPath = properties.get(MANIFEST).toString();
			manifest = bundle.getEntry(manifestPath);
			if (manifest == null)
				throw new IllegalArgumentException("Manifest at location " + manifestPath + " could not be found"); }
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int hash = 1;
		hash = prime * hash + ((identifier == null) ? 0 : identifier.hashCode());
		hash = prime * hash + ((manifest == null) ? 0 : manifest.hashCode());
		hash = prime * hash + ((path == null) ? 0 : path.hashCode());
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
		LiblouisTableSet that = (LiblouisTableSet)object;
		if (!this.identifier.equals(that.identifier))
			return false;
		if (!this.path.equals(that.path))
			return false;
		if (manifest == null) {
			if (that.manifest != null)
				return false; }
		else if (!manifest.equals(that.manifest))
			return false;
		return true;
	}
}
