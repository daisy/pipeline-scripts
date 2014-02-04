package org.daisy.pipeline.braille.libhyphen;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.util.Locale;

import com.google.common.base.Predicate;

import org.daisy.pipeline.braille.ResourceLookup;
import org.daisy.pipeline.braille.ResourcePath;
import org.daisy.pipeline.braille.ResourceRegistry;

import static org.daisy.pipeline.braille.Utilities.Files.asFile;
import static org.daisy.pipeline.braille.Utilities.Files.fileName;
import static org.daisy.pipeline.braille.Utilities.URIs.asURI;
import static org.daisy.pipeline.braille.Utilities.URLs.asURL;
import static org.daisy.pipeline.braille.Utilities.Predicates.matchesGlobPattern;

public class LibhyphenTableRegistry extends ResourceRegistry<LibhyphenTablePath>
	                                implements LibhyphenTableLookup, LibhyphenTableResolver {
	
	@Override
	protected void register(LibhyphenTablePath path) {
		super.register(path);
		cachedLookup.invalidateCache();
	}
	
	@Override
	protected void unregister (LibhyphenTablePath path) {
		super.unregister(path);
		cachedLookup.invalidateCache();
	}
	
	/**
	 * Try to find a table based on the given locale.
	 * An automatic fallback mechanism is used: if nothing is found for
	 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
	 */
	public URI lookup(Locale locale) {
		return cachedLookup.lookup(locale);
	}
	
	private final DispatchingLookup<Locale,URI> dispatchingLookup = new DispatchingLookup<Locale,URI>() {
		public Iterable<? extends ResourceLookup<Locale,URI>> dispatch() {
			return paths.values();
		}
	};
	
	private final ResourceLookup<Locale,URI> lookup = LocaleBasedLookup.<URI>newInstance(dispatchingLookup);
	private final CachedLookup<Locale,URI> cachedLookup = CachedLookup.<Locale,URI>newInstance(lookup);
	
	@Override
	public URL resolve(URI resource) {
		URL resolved = super.resolve(resource);
		if (resolved == null)
			resolved = fileSystem.resolve(resource);
		return resolved;
	}
	
	private final ResourcePath fileSystem = new LibhyphenFileSystem();
	
	private static class LibhyphenFileSystem implements ResourcePath {

		private static final URI identifier = asURI("file:/");
		
		private static final Predicate<String> isLibhyphenTable = matchesGlobPattern("hyph_*.dic");
		
		public URI getIdentifier() {
			return identifier;
		}
		
		public URL resolve(URI resource) {
			try {
				resource = resource.normalize();
				resource = identifier.resolve(resource);
				File file = asFile(resource);
				if (file.exists() && isLibhyphenTable.apply(fileName(file)))
					return asURL(resource); }
			catch (Exception e) {}
			return null;
		}
		
		public URI canonicalize(URI resource) {
			return asURI(resolve(resource));
		}
	}
}
