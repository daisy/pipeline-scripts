package org.daisy.pipeline.braille;

import com.google.common.base.Function;
import com.google.common.base.Predicate;
import com.google.common.base.Predicates;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterators;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.Collection;
import java.util.Map;

import org.daisy.pipeline.braille.Utilities.Files;

import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

public abstract class BundledTablePath implements TablePath {

	protected static final String IDENTIFIER = "identifier";
	protected static final String DIRECTORY = "directory";
	protected static final String MANIFEST = "manifest";

	protected URL identifier = null;
	protected URL path = null;
	protected URL manifest = null;
	protected Collection<String> tableNames = null;

	public URL getIdentifier() {
		return identifier;
	}

	public URL getPath() {
		return path;
	}

	public URL getManifest() {
		return manifest;
	}
	
	public URL getTable(String tableName) {
		if (hasTable(tableName)) {
			try { return new URL(identifier.toExternalForm() + tableName); }
			catch (Exception e) {}}
		throw new RuntimeException("Unable to find table " + tableName);
	}
	
	public boolean hasTable(String tableName) {
		return tableNames.contains(tableName);
	}

	protected Predicate<String> tableNameFilter = Predicates.<String>alwaysTrue();
	
	@SuppressWarnings("unchecked")
	public void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		if (properties.get(IDENTIFIER) == null
				|| properties.get(IDENTIFIER).toString().isEmpty()) {
			throw new IllegalArgumentException(IDENTIFIER + " property must not be empty"); }
		String id = properties.get(IDENTIFIER).toString();
		try {
			identifier = new URL(id);}
		catch (MalformedURLException e) {
			throw new IllegalArgumentException(IDENTIFIER + " could not be parsed into a URL"); }
		if (!id.matches("^http:/.*/$"))
			throw new IllegalArgumentException(IDENTIFIER + " must be of the form 'http:/.../'");
		if (properties.get(DIRECTORY) == null
				|| properties.get(DIRECTORY).toString().isEmpty()) {
			throw new IllegalArgumentException(DIRECTORY + " property must not be empty"); }
		final Bundle bundle = context.getBundleContext().getBundle();
		String directory = properties.get(DIRECTORY).toString();
		path = bundle.getEntry(directory);
		if (path == null)
			throw new IllegalArgumentException("Table directory at location " + directory + " could not be found");
		tableNames = new ImmutableList.Builder<String>()
			.addAll(Iterators.<String>filter(
				Iterators.<String,String>transform(
					Iterators.<String>forEnumeration(bundle.getEntryPaths(directory)),
					new Function<String,String>() {
						public String apply(String s) { return Files.fileName(bundle.getEntry(s)); }}),
				tableNameFilter))
			.build();
		if (properties.get(MANIFEST) != null) {
			String manifestPath = properties.get(MANIFEST).toString();
			manifest = bundle.getEntry(manifestPath);
			if (manifest == null)
				throw new IllegalArgumentException("Manifest at location " + manifestPath + " could not be found"); }
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
		TablePath that = (TablePath)object;
		if (!this.identifier.equals(that.getIdentifier()))
			return false;
		if (!this.path.equals(that.getPath()))
			return false;
		if (manifest == null) {
			if (that.getManifest() != null)
				return false; }
		else if (!manifest.equals(that.getManifest()))
			return false;
		return true;
	}
}
