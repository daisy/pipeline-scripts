package org.daisy.pipeline.braille.liblouis;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import com.google.common.base.Function;
import com.google.common.base.Predicate;
import com.google.common.collect.Iterables;

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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.liblouis.LiblouisTableRegistry",
	service = {
		LiblouisTableRegistry.class,
		LiblouisTableResolver.class
	}
)
public class LiblouisTableRegistry extends ResourceRegistry<LiblouisTablePath> implements LiblouisTableResolver {
	
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
		applyPathChangeCallbacks();
	}
	
	@Override
	protected void unregister(LiblouisTablePath path) {
		super.unregister(path);
		applyPathChangeCallbacks();
	}
	
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
	
	private Collection<Function<LiblouisTableRegistry,Void>> pathChangeCallbacks
		= new ArrayList<Function<LiblouisTableRegistry,Void>>();
	
	public void onPathChange(Function<LiblouisTableRegistry,Void> callback) {
		pathChangeCallbacks.add(callback);
	}
	
	private void applyPathChangeCallbacks() {
		for (Function<LiblouisTableRegistry,Void> f : pathChangeCallbacks)
			try {
				f.apply(this); }
			catch (RuntimeException e) {
				logger.error("Could not apply callback function " + f, e); }
	}
	
	private static Function<LiblouisTablePath,Iterable<URI>> listTables = new Function<LiblouisTablePath,Iterable<URI>>() {
		public Iterable<URI> apply(LiblouisTablePath path) {
			return path.listTables();
		}
	};
	
	public Iterable<URI> listAllTables() {
		return Iterables.<URI>concat(
			Iterables.<LiblouisTablePath,Iterable<URI>>transform(
				paths.values(),
				listTables));
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisTableRegistry.class);
	
}
