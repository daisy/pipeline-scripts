package org.daisy.pipeline.braille.libhyphen;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.util.Locale;

import com.google.common.base.Predicate;

import org.daisy.pipeline.braille.common.ResourcePath;
import org.daisy.pipeline.braille.common.ResourceRegistry;
import org.daisy.pipeline.braille.common.Provider;

import static org.daisy.pipeline.braille.common.util.Files.asFile;
import static org.daisy.pipeline.braille.common.util.Files.fileName;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import static org.daisy.pipeline.braille.common.util.URLs.asURL;
import static org.daisy.pipeline.braille.common.util.Predicates.matchesGlobPattern;

public class LibhyphenTableRegistry extends ResourceRegistry<LibhyphenTablePath>
	                                implements LibhyphenTableProvider, LibhyphenTableResolver {
	
	@Override
	protected void register(LibhyphenTablePath path) {
		super.register(path);
		provider.invalidateCache();
	}
	
	@Override
	protected void unregister (LibhyphenTablePath path) {
		super.unregister(path);
		provider.invalidateCache();
	}
	
	/**
	 * Try to find a table based on the given locale.
	 * An automatic fallback mechanism is used: if nothing is found for
	 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
	 */
	public Iterable<URI> get(Locale locale) {
		return provider.get(locale);
	}
	
	private final CachedProvider<Locale,URI> provider
		= CachedProvider.<Locale,URI>newInstance(
			LocaleBasedProvider.<URI>newInstance(
				new DispatchingProvider<Locale,URI>() {
					public Iterable<? extends Provider<Locale,URI>> dispatch() {
						return paths.values(); }}));
	
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
