package org.daisy.pipeline.braille.liblouis.impl;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import com.google.common.base.Function;
import static com.google.common.base.Functions.toStringFunction;
import com.google.common.base.Optional;
import com.google.common.base.Predicates;
import com.google.common.collect.Iterables;

import static org.daisy.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.BundledNativePath;
import org.daisy.pipeline.braille.common.LazyValue.ImmutableLazyValue;
import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.util.Files.asFile;
import org.daisy.pipeline.braille.common.util.Locales;
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
			tableRegistry.onPathChange(
				new Function<LiblouisTableRegistry,Void>() {
					public Void apply(LiblouisTableRegistry r) {
						indexed = false;
						provider.invalidateCache();
						return null; }});
			final LiblouisTableResolver tableResolver = tableRegistry;
			_tableResolver = new TableResolver() {
				public File[] invoke(String table, File base) {
					logger.debug("Resolving " + table + (base != null ? " against base " + base : ""));
					File[] resolved = tableResolver.resolveLiblouisTable(new LiblouisTable(table), base);
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
	
	private boolean indexed = false;
	
	private void lazyIndex() {
		if (indexed)
			return;
		logger.debug("Indexing tables");
		Louis.getLibrary().lou_indexTables(
			Iterables.toArray(
				Iterables.<URI,String>transform(
					tableRegistry.listAllTableFiles(),
					toStringFunction()),
			String.class));
		indexed = true;
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
	protected void bindTableRegistry(LiblouisTableRegistry registry) {
		tableRegistry = registry;
		logger.debug("Registering Liblouis table registry: " + registry);
	}
	
	protected void unbindTableRegistry(LiblouisTableRegistry registry) {
		tableRegistry = null;
	}
	
	public Iterable<Translator> get(String query) {
		return provider.get(query);
	}

	private CachedProvider<String,Translator> provider
	= new CachedProvider<String,Translator>() {
		public Iterable<Translator> delegate(final String query) {
			return provider_.get(new HashMap<String,Optional<String>>(parseQuery(query)));
		}
		@Override
		public void invalidateCache() {
			super.invalidateCache();
			provider__.invalidateCache();
		}
	};
	
	private Provider<Map<String,Optional<String>>,Translator> provider_
	= new LocaleBasedProvider<Map<String,Optional<String>>,Translator>() {
		public Iterable<Translator> delegate(final Map<String,Optional<String>> query) {
			return provider__.get(query);
		}
		public Locale getLocale(Map<String,Optional<String>> query) {
			Optional<String> o;
			if ((o = query.get("locale")) != null)
				return parseLocale(o.get());
			else
				return null;
		}
		public Map<String,Optional<String>> assocLocale(Map<String,Optional<String>> query, Locale locale) {
			query.put("locale", Optional.<String>of(Locales.toString(locale, '_')));
			return query;
		}
	};
	
	private CachedProvider<Map<String,Optional<String>>,Translator> provider__
	= new CachedProvider<Map<String,Optional<String>>,Translator>() {
		public Iterable<Translator> delegate(final Map<String,Optional<String>> query) {
			return Iterables.<Translator>filter(
				new ImmutableLazyValue<Translator>() {
					public Translator delegate() {
						try {
							Optional<String> o;
							if ((o = query.get("table")) != null)
								return new Translator(o.get());
							else if (query.size() > 0) {
								StringBuilder b = new StringBuilder();
								for (String k : query.keySet()) {
									if (!k.matches("[a-zA-Z0-9_-]+")) {
										logger.warn("Invalid syntax for feature key: " + k);
										return null; }
									b.append(k);
									o = query.get(k);
									if (o.isPresent()) {
										String v = o.get();
										if (!v.matches("[a-zA-Z0-9_-]+")) {
											logger.warn("Invalid syntax for feature value: " + v);
											return null; }
										b.append(":" + v); }
									b.append(" "); }
								lazyIndex();
								return Translator.find(b.toString()); }}
						catch (CompilationException e) {
							logger.warn("Could not compile translator", e); }
						return null; }},
				Predicates.notNull());
		}
	};
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisJnaImpl.class);
	
}
