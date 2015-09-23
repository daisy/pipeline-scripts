package org.daisy.pipeline.braille.liblouis.impl;

import java.io.File;
import java.net.URI;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.NoSuchElementException;

import com.google.common.base.Function;
import static com.google.common.base.Functions.toStringFunction;
import com.google.common.base.Objects;
import com.google.common.base.Objects.ToStringHelper;
import com.google.common.base.Optional;
import static com.google.common.collect.Iterables.toArray;
import static com.google.common.collect.Iterables.transform;

import static org.daisy.pipeline.braille.css.Query.parseQuery;

import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.warn;
import org.daisy.pipeline.braille.common.LazyValue.ImmutableLazyValue;
import org.daisy.pipeline.braille.common.NativePath;
import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.Transform;
import static org.daisy.pipeline.braille.common.util.Files.unpack;
import static org.daisy.pipeline.braille.common.util.Files.asFile;
import org.daisy.pipeline.braille.common.util.Locales;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.common.WithSideEffect;

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
public class LiblouisJnaImpl extends AbstractTransform.Provider<LiblouisJnaImpl.Table> {
	
	public class Table extends LiblouisTable implements Transform {
		private final Translator translator;
		private Table(String table) throws CompilationException {
			super(table);
			translator = new Translator(table);
		}
		public Translator getTranslator() {
			return translator;
		}
		public String getIdentifier() {
			return toString();
		}
	}
	
	private final static boolean LIBLOUIS_EXTERNAL = Boolean.getBoolean("org.daisy.pipeline.liblouis.external");
	
	private LiblouisTableRegistry tableRegistry;
	
	// Hold a reference to avoid garbage collection
	private TableResolver _tableResolver;
	private org.liblouis.Logger _logger;
	
	private File unicodeDisFile;
	private File spacesFile;
	
	@Activate
	protected void activate(ComponentContext context) {
		logger.debug("Loading liblouis service");
		logger.debug("liblouis version: {}", Louis.getLibrary().lou_version());
		try {
			tableRegistry.onPathChange(
				new Function<LiblouisTableRegistry,Void>() {
					public Void apply(LiblouisTableRegistry r) {
						indexed = false;
						invalidateCache();
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
			spacesFile = new File(makeUnpackDir(context), "spaces.cti");
			unpack(
				context.getBundleContext().getBundle().getEntry("/tables/spaces.cti"),
				spacesFile);
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
		unbind = "-",
		service = NativePath.class,
		target = "(identifier=http://www.liblouis.org/native/*)",
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindLibrary(NativePath path) {
		if (LIBLOUIS_EXTERNAL)
			logger.info("Using external liblouis");
		else {
			URI libraryPath = path.get("liblouis").iterator().next();
			Louis.setLibraryPath(asFile(path.resolve(libraryPath)));
			logger.debug("Registering liblouis library: " + libraryPath); }
	}
	
	@Reference(
		name = "LiblouisTableRegistry",
		unbind = "-",
		service = LiblouisTableRegistry.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindTableRegistry(LiblouisTableRegistry registry) {
		tableRegistry = registry;
		logger.debug("Registering Liblouis table registry: " + registry);
	}
	
	protected Iterable<Table> _get(final String query) {
		return Iterables.of(
			_provider.get(parseQuery(query))
		);
	}
	
	@Override
	public ToStringHelper toStringHelper() {
		return Objects.toStringHelper("o.d.p.b.liblouis.impl.LiblouisJnaImpl$ProviderImpl");
	}
	
	private Provider<Map<String,Optional<String>>,WithSideEffect<Table,Logger>> _provider
	= new LocaleBasedProvider<Map<String,Optional<String>>,WithSideEffect<Table,Logger>>() {
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
		public java.lang.Iterable<WithSideEffect<Table,Logger>> _get(final Map<String,Optional<String>> query) {
			return new ImmutableLazyValue<WithSideEffect<Table,Logger>>() {
				public WithSideEffect<Table,Logger> _apply() {
					return new WithSideEffect<Table,Logger>() {
						public Table _apply() {
							final Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(query);
							String table = null;
							boolean unicode = false;
							boolean whiteSpace = false;
							Optional<String> o;
							if ((o = q.remove("unicode")) != null)
								unicode = true;
							if ((o = q.remove("white-space")) != null)
								whiteSpace = true;
							if ((o = q.get("table")) != null || (o = q.get("liblouis-table")) != null)
								table = o.get();
							else if (q.size() > 0) {
								StringBuilder b = new StringBuilder();
								for (String k : q.keySet()) {
									if (!k.matches("[a-zA-Z0-9_-]+")) {
										__apply(
											warn("Invalid syntax for feature key: " + k));
										throw new NoSuchElementException(); }
									b.append(k);
									o = q.get(k);
									if (o.isPresent()) {
										String v = o.get();
										if (!v.matches("[a-zA-Z0-9_-]+")) {
											__apply(
												warn("Invalid syntax for feature value: " + v));
											throw new NoSuchElementException(); }
										b.append(":" + v); }
									b.append(" "); }
								lazyIndex();
								table = Louis.getLibrary().lou_findTable(b.toString()); }
							if (table != null) {
								if (whiteSpace)
									table = asURI(spacesFile) + "," + table;
								if (unicode)
									table = asURI(unicodeDisFile) + "," + table;
								try {
									return new Table(table); }
								catch (CompilationException e) {
									__apply(
										warn("Could not compile table " + table));
									logger.warn("Could not compile table", e); }}
							throw new NoSuchElementException();
						}
					};
				}
			};
		}
	};
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisJnaImpl.class);
	
}
