package org.daisy.pipeline.braille.liblouis;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import static org.daisy.pipeline.braille.Utilities.Files.asFile;
import static org.daisy.pipeline.braille.Utilities.Files.fileName;
import static org.daisy.pipeline.braille.Utilities.Predicates.matchesGlobPattern;
import static org.daisy.pipeline.braille.Utilities.URIs.asURI;
import static org.daisy.pipeline.braille.Utilities.URLs.asURL;

import org.daisy.pipeline.braille.ResourceLookup;
import org.daisy.pipeline.braille.ResourcePath;
import org.daisy.pipeline.braille.ResourceRegistry;

import com.google.common.base.Predicate;

public class LiblouisTableRegistry extends ResourceRegistry<LiblouisTablePath> implements LiblouisTableLookup, LiblouisTableResolver {
	
	@Override
	protected void register(LiblouisTablePath path) {
		super.register(path);
		cachedLookup.invalidateCache();
	}
	
	@Override
	protected void unregister(LiblouisTablePath path) {
		super.unregister(path);
		cachedLookup.invalidateCache();
	}
	
	/**
	 * Try to find a table based on the given locale.
	 * An automatic fallback mechanism is used: if nothing is found for
	 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
	 */
	public URI[] lookup(Locale query) {
		return cachedLookup.lookup(query);
	}
	
	private final DispatchingLookup<Locale,URI[]> dispatchingLookup = new DispatchingLookup<Locale,URI[]>() {
		public Iterable<? extends ResourceLookup<Locale,URI[]>> dispatch() {
			return paths.values();
		}
	};
	
	private final ResourceLookup<Locale,URI[]> lookup = LocaleBasedLookup.<URI[]>newInstance(dispatchingLookup);
	
	private final CachedLookup<Locale,URI[]> cachedLookup = CachedLookup.<Locale,URI[]>newInstance(lookup);
	
	@Override
	public URL resolve(URI resource) {
		URL resolved = super.resolve(resource);
		if (resolved == null)
			resolved = fileSystem.resolve(resource);
		return resolved;
	}
	
	public File[] resolveTableList(URI[] tableList, File base) {
		File[] resolved = new File[tableList.length];
		List<ResourcePath> paths = new ArrayList<ResourcePath>(this.paths.values());
		paths.add(fileSystem);
		for (int i = 0; i < tableList.length; i++) {
			URI subTable = tableList[i];
			if (base != null)
				subTable = asURI(base).resolve(subTable);
			for (ResourcePath path : paths) {
				resolved[i] = asFile(path.resolve(subTable));
				if (resolved[i] != null) {
					paths.remove(path);
					paths.add(0, path);
					break; }}
			if (resolved[i] == null)
				return null; }
		return resolved;
	}
	
	private final ResourcePath fileSystem = new LiblouisFileSystem();
	
	private static class LiblouisFileSystem implements ResourcePath {

		private static final URI identifier = asURI("file:/");
		
		private static final Predicate<String> isLiblouisTable = matchesGlobPattern("*.{dis,ctb,cti,ctu,dic}");
		
		public URI getIdentifier() {
			return identifier;
		}
		
		public URL resolve(URI resource) {
			try {
				resource = resource.normalize();
				resource = identifier.resolve(resource);
				File file = asFile(resource);
				if (file.exists() && isLiblouisTable.apply(fileName(file)))
					return asURL(resource); }
			catch (Exception e) {}
			return null;
		}
		
		public URI canonicalize(URI resource) {
			return asURI(resolve(resource));
		}
	}
}
