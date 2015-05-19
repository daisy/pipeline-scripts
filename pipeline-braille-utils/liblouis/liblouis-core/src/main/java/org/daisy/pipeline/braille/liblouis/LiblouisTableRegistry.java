package org.daisy.pipeline.braille.liblouis;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import com.google.common.base.Predicate;

import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.ResourcePath;
import org.daisy.pipeline.braille.common.ResourceRegistry;
import static org.daisy.pipeline.braille.common.util.Files.asFile;
import static org.daisy.pipeline.braille.common.util.Files.fileName;
import static org.daisy.pipeline.braille.common.util.Predicates.matchesGlobPattern;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import static org.daisy.pipeline.braille.common.util.URLs.asURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

@Component(
	name = "org.daisy.pipeline.braille.liblouis.LiblouisTableRegistry",
	service = {
		LiblouisTableRegistry.class,
		LiblouisTableResolver.class
	}
)
public class LiblouisTableRegistry extends ResourceRegistry<LiblouisTablePath> implements Provider<Locale,LiblouisTable>, LiblouisTableResolver {
	
	@Reference(
		name = "LiblouisTablePath",
		unbind = "unregister",
		service = LiblouisTablePath.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	@Override
	protected void register(LiblouisTablePath path) {
		super.register(path);
		provider.invalidateCache();
	}
	
	@Override
	protected void unregister(LiblouisTablePath path) {
		super.unregister(path);
		provider.invalidateCache();
	}
	
	/**
	 * Try to find a table based on the given locale.
	 * An automatic fallback mechanism is used: if nothing is found for
	 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
	 */
	public Iterable<LiblouisTable> get(Locale query) {
		return provider.get(query);
	}
	
	private final CachedProvider<Locale,LiblouisTable> provider
		= CachedProvider.<Locale,LiblouisTable>newInstance(
			LocaleBasedProvider.<LiblouisTable>newInstance(
				new DispatchingProvider<Locale,LiblouisTable>() {
					public Iterable<? extends Provider<Locale,LiblouisTable>> dispatch() {
						return paths.values(); }}));
	
	@Override
	public URL resolve(URI resource) {
		URL resolved = super.resolve(resource);
		if (resolved == null)
			resolved = fileSystem.resolve(resource);
		return resolved;
	}
	
	public File[] resolveLiblouisTable(LiblouisTable table, File base) {
		URI[] tableList = table.asURIs();
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
