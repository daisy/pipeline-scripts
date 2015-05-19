package org.daisy.pipeline.braille.liblouis.impl;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.util.Locale;
import java.util.Map;

import com.google.common.base.Function;
import com.google.common.base.Optional;
import com.google.common.base.Predicates;
import com.google.common.collect.Iterables;

import static org.daisy.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.BundledNativePath;
import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.util.Files.asFile;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Strings.join;

import org.daisy.pipeline.braille.liblouis.LiblouisTable;
import org.daisy.pipeline.braille.liblouis.LiblouisTableRegistry;
import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;

import org.liblouis.Louis;
import org.liblouis.CompilationException;
import org.liblouis.TableResolver;
import org.liblouis.Translator;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Deactivate;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.liblouis.impl.LiblouisJnaImpl",
	service = {
		LiblouisJnaImpl.class
	}
)
public class LiblouisJnaImpl implements Provider<String,Translator> {
	
	private final static boolean LIBLOUIS_EXTERNAL = Boolean.getBoolean("org.daisy.pipeline.liblouis.external");
	
	private BundledNativePath nativePath;
	private LiblouisTableRegistry tableRegistry;
	
	// Hold a reference to avoid garbage collection
	private TableResolver _tableResolver;
	
	@Activate
	protected void activate() {
		logger.debug("Loading liblouis service");
		try {
			if (LIBLOUIS_EXTERNAL)
				logger.info("Using external liblouis");
			else if (this.nativePath == null)
				throw new RuntimeException("No liblouis library registered");
			logger.debug("liblouis version: {}", Louis.getLibrary().lou_version());
			if (tableRegistry == null)
				throw new RuntimeException("No liblouis table registry bound");
			final LiblouisTableResolver tableResolver = tableRegistry;
			_tableResolver = new TableResolver() {
				public File[] invoke(String tableList, File base) {
					logger.debug("Resolving " + tableList + (base != null ? " against base " + base : ""));
					File[] resolved = tableResolver.resolveLiblouisTable(new LiblouisTable(tableList), base);
					if (resolved != null)
						logger.debug("Resolved to " + join(resolved, ","));
					else
						logger.error("Table could not be resolved");
						return resolved; }};
			Louis.getLibrary().lou_registerTableResolver(_tableResolver); }
		catch (Throwable e) {
			logger.error("liblouis service could not be loaded", e);
			throw e; }
	}
	
	@Deactivate
	protected void deactivate() {
		logger.debug("Unloading liblouis service");
	}
	
	@Reference(
		name = "LiblouisLibrary",
		unbind = "unbindLibrary",
		service = BundledNativePath.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.STATIC
	)
	protected void bindLibrary(BundledNativePath path) {
		if (!LIBLOUIS_EXTERNAL && nativePath == null) {
			URL libraryPath = path.resolve(Iterables.<URI>getFirst(path.get("liblouis"), null));
			if (libraryPath != null) {
				Louis.setLibraryPath(asFile(libraryPath));
				nativePath = path;
				logger.debug("Registering liblouis library: " + libraryPath); }}
	}
	
	protected void unbindLibrary(BundledNativePath path) {
		if (path.equals(nativePath))
			nativePath = null;
	}
	
	@Reference(
		name = "LiblouisTableRegistry",
		unbind = "unbindTableRegistry",
		service = LiblouisTableRegistry.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindTableResolver(LiblouisTableRegistry registry) {
		tableRegistry = registry;
		logger.debug("Registering Liblouis table registry: " + registry);
	}
	
	protected void unbindTableResolver(LiblouisTableRegistry resolver) {
		tableRegistry = null;
	}
	
	public Iterable<Translator> get(String query) {
		return provider.get(query);
	}
	
	private final static Iterable<Translator> empty = Optional.<Translator>absent().asSet();
	
	private CachedProvider<String,Translator> provider
	= new CachedProvider<String,Translator>() {
		public Iterable<Translator> delegate(final String query) {
			final Map<String,Optional<String>> q = parseQuery(query);
			Optional<String> o;
			if ((o = q.get("table")) != null) {
				String table = o.get();
				try {
					return Optional.of(new Translator(table)).asSet(); }
				catch (CompilationException e) {
					logger.warn("Could not compile translator " + table, e);
					return empty; }}
			else if ((o = q.get("locale")) != null) {
				Locale locale = parseLocale(o.get());
				return Iterables.<Translator>filter(
					Iterables.<LiblouisTable,Translator>transform(
						tableRegistry.get(locale),
						new Function<LiblouisTable,Translator>() {
							public Translator apply(LiblouisTable table) {
								try {
									return new Translator(table.toString()); }
								catch (CompilationException e) {
									logger.warn("Could not compile translator " + table, e);
									return null; }}}),
					Predicates.notNull()); }
			else
				return empty;
		}
	};
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisJnaImpl.class);
	
}
