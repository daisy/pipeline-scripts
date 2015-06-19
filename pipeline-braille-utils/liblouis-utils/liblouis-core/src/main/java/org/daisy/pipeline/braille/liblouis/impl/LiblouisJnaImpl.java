package org.daisy.pipeline.braille.liblouis.impl;

import java.io.File;
import java.net.URL;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import com.google.common.base.Function;
import static com.google.common.base.Functions.toStringFunction;
import com.google.common.base.Optional;
import static com.google.common.base.Predicates.notNull;
import static com.google.common.collect.Iterables.filter;
import static com.google.common.collect.Iterables.getFirst;
import static com.google.common.collect.Iterables.toArray;
import static com.google.common.collect.Iterables.transform;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.BundledNativePath;
import org.daisy.pipeline.braille.common.LazyValue.ImmutableLazyValue;
import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.util.Files.unpack;
import static org.daisy.pipeline.braille.common.util.Files.asFile;
import org.daisy.pipeline.braille.common.util.Locales;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;

import org.daisy.pipeline.braille.liblouis.LiblouisTable;
import org.daisy.pipeline.braille.liblouis.LiblouisTableRegistry;
import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;

import org.liblouis.Louis;
import org.liblouis.CompilationException;
import static org.liblouis.Logger.Level.ALL;
import static org.liblouis.Logger.Level.DEBUG;
import static org.liblouis.Logger.Level.INFO;
import static org.liblouis.Logger.Level.WARN;
import static org.liblouis.Logger.Level.ERROR;
import static org.liblouis.Logger.Level.FATAL;
import org.liblouis.TableResolver;
import org.liblouis.Translator;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Deactivate;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.ComponentContext;

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
	private org.liblouis.Logger _logger;
	
	private File unicodeDisFile;
	
	@Activate
	protected void activate(ComponentContext context) {
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
			Louis.getLibrary().lou_registerTableResolver(_tableResolver);
			unicodeDisFile = new File(makeUnpackDir(context), "unicode.dis");
			unpack(
				context.getBundleContext().getBundle().getEntry("/tables/unicode.dis"),
				unicodeDisFile);
			_logger = new org.liblouis.Logger() {
				public void invoke(int level, String message) {
					switch (level) {
					case ALL: logger.trace(message); break;
					case DEBUG: logger.debug(message); break;
					case INFO: logger.info(message); break;
					case WARN: logger.warn(message); break;
					case ERROR: logger.error(message); break;
					case FATAL: logger.error(message); break; }}};
			Louis.getLibrary().lou_registerLogCallback(_logger); }
		catch (Throwable e) {
			logger.error("liblouis service could not be loaded", e);
			throw e; }
	}
	
	private static File makeUnpackDir(ComponentContext context) {
		File directory;
		for (int i = 0; true; i++) {
			directory = context.getBundleContext().getDataFile("resources" + i);
			if (!directory.exists()) break; }
		directory.mkdirs();
		return directory;
	}
	
	private boolean indexed = false;
	
	private void lazyIndex() {
		if (indexed)
			return;
		logger.debug("Indexing tables");
		Louis.getLibrary().lou_indexTables(
			toArray(
				transform(
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
			URL libraryPath = path.resolve(getFirst(path.get("liblouis"), null));
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

	private Provider.MemoizingProvider<String,Translator> provider
	= new Provider.MemoizingProvider<String,Translator>() {
		public Iterable<Translator> _get(final String query) {
			return _provider.get(parseQuery(query));
		}
		@Override
		public void invalidateCache() {
			super.invalidateCache();
			__provider.invalidateCache();
		}
	};
	
	private Provider<Map<String,Optional<String>>,Translator> _provider
	= new LocaleBasedProvider<Map<String,Optional<String>>,Translator>() {
		public Iterable<Translator> _get(final Map<String,Optional<String>> query) {
			return __provider.get(query);
		}
		public Locale getLocale(Map<String,Optional<String>> query) {
			Optional<String> o;
			if ((o = query.get("locale")) != null)
				return parseLocale(o.get());
			else
				return null;
		}
		public Map<String,Optional<String>> assocLocale(Map<String,Optional<String>> query, Locale locale) {
			Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(query);
			q.put("locale", Optional.of(Locales.toString(locale, '_')));
			return q;
		}
	};
	
	private Provider.MemoizingProvider<Map<String,Optional<String>>,Translator> __provider
	= new Provider.MemoizingProvider<Map<String,Optional<String>>,Translator>() {
		public Iterable<Translator> _get(final Map<String,Optional<String>> query) {
			final Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(query);
			return filter(
				new ImmutableLazyValue<Translator>() {
					public Translator _apply() {
						String table = null;
						boolean unicode = false;
						Optional<String> o;
						if ((o = q.remove("unicode")) != null)
							unicode = true;
						if ((o = q.get("table")) != null || (o = q.get("liblouis-table")) != null)
							table = o.get();
						else if (q.size() > 0) {
							StringBuilder b = new StringBuilder();
							for (String k : q.keySet()) {
								if (!k.matches("[a-zA-Z0-9_-]+")) {
									logger.warn("Invalid syntax for feature key: " + k);
									return null; }
								b.append(k);
								o = q.get(k);
								if (o.isPresent()) {
									String v = o.get();
									if (!v.matches("[a-zA-Z0-9_-]+")) {
										logger.warn("Invalid syntax for feature value: " + v);
										return null; }
									b.append(":" + v); }
								b.append(" "); }
							lazyIndex();
							table = Louis.getLibrary().lou_findTable(b.toString()); }
						if (table != null) {
							if (unicode)
								table = asURI(unicodeDisFile) + "," + table;
							try {
								return new Translator(table); }
							catch (CompilationException e) {
								logger.warn("Could not compile translator", e); }}
						return null; }},
				notNull());
		}
	};
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisJnaImpl.class);
	
}
