package org.daisy.pipeline.braille.libhyphen.impl;

import java.io.File;
import java.io.FileNotFoundException;
import java.net.URI;
import java.net.URL;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import ch.sbs.jhyphen.Hyphen;
import ch.sbs.jhyphen.Hyphenator;

import com.google.common.base.Function;
import static com.google.common.base.Objects.toStringHelper;
import com.google.common.base.Optional;
import static com.google.common.base.Predicates.notNull;
import com.google.common.base.Splitter;
import static com.google.common.collect.Iterables.filter;
import static com.google.common.collect.Iterables.toArray;
import static com.google.common.collect.Iterables.transform;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.NativePath;
import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.ResourceResolver;
import org.daisy.pipeline.braille.common.TextTransform;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.Transform.AbstractTransform;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.debug;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.logCreate;
import static org.daisy.pipeline.braille.common.util.Files.asFile;
import static org.daisy.pipeline.braille.common.util.Files.isAbsoluteFile;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Strings.extractHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.insertHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import org.daisy.pipeline.braille.common.util.Tuple2;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import static org.daisy.pipeline.braille.common.util.URLs.asURL;
import org.daisy.pipeline.braille.common.WithSideEffect;
import org.daisy.pipeline.braille.libhyphen.LibhyphenHyphenator;
import org.daisy.pipeline.braille.libhyphen.LibhyphenTableProvider;
import org.daisy.pipeline.braille.libhyphen.LibhyphenTableResolver;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Deactivate;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.libhyphen.LibhyphenJnaImpl",
	service = {
		LibhyphenHyphenator.Provider.class,
		TextTransform.Provider.class,
		org.daisy.pipeline.braille.common.Hyphenator.Provider.class
	}
)
public class LibhyphenJnaImpl implements LibhyphenHyphenator.Provider {
	
	private final static char SHY = '\u00AD';
	private final static char ZWSP = '\u200B';
	
	private ResourceResolver tableResolver;
	private LibhyphenTableProvider tableProvider;
	
	@Activate
	protected void activate() {
		logger.debug("Loading libhyphen service");
	}
	
	@Deactivate
	protected void deactivate() {
		logger.debug("Unloading libhyphen service");
	}
	
	@Reference(
		name = "LibhyphenLibrary",
		unbind = "-",
		service = NativePath.class,
		target = "(identifier=http://hunspell.sourceforge.net/Hyphen/native/*)",
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindLibrary(NativePath path) {
		URI libraryPath = path.get("libhyphen").iterator().next();
		Hyphen.setLibraryPath(asFile(path.resolve(libraryPath)));
		logger.debug("Registering libhyphen library: " + libraryPath);
	}
	
	@Reference(
		name = "LibhyphenTableResolver",
		unbind = "-",
		service = LibhyphenTableResolver.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindTableResolver(LibhyphenTableResolver resolver) {
		tableResolver = resolver;
		logger.debug("Registering libhyphen table resolver: " + resolver);
	}
	
	@Reference(
		name = "LibhyphenTableProvider",
		unbind = "-",
		service = LibhyphenTableProvider.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindTableProvider(LibhyphenTableProvider provider) {
		tableProvider = provider;
		logger.debug("Registering libhyphen table provider: " + provider);
	}
	
	private WithSideEffect<LibhyphenHyphenator,Logger> get(final URI table) {
		try {
			return logCreate((LibhyphenHyphenator)new LibhyphenHyphenatorImpl(table)); }
		catch (final Throwable e) {
			return new WithSideEffect<LibhyphenHyphenator,Logger>() {
				public LibhyphenHyphenator _apply() throws FileNotFoundException {
					applyWithSideEffect(debug("Could not create hyphenator for table " + table));
					throw e;
				}
			};
		}
	}
	
	/**
	 * Recognized features:
	 *
	 * - id: If present it must be the only feature. Matches a hyphenator with a unique ID.
	 *
	 * - hyphenator: Will only match if the value is `hyphen', or if it's a hyphenator's ID.
	 *
	 * - table or libhyphen-table: A Hyphen table is a URI that can be either a file name, a file
	 *   path relative to a registered table path, an absolute file URI, or a fully qualified table
	 *   identifier. This feature is not compatible with other features except `hyphenator'.
	 *
	 * - locale: Matches only hyphenators with that locale.
	 *
	 */
	public Iterable<LibhyphenHyphenator> get(String query) {
		return impl.get(query);
	}
	
	public Transform.Provider<LibhyphenHyphenator> withContext(Logger context) {
		return impl.withContext(context);
	}
	
	private Transform.Provider.MemoizingProvider<LibhyphenHyphenator> impl = new ProviderImpl(null);
	
	private final static Iterable<WithSideEffect<LibhyphenHyphenator,Logger>> empty
		= Optional.<WithSideEffect<LibhyphenHyphenator,Logger>>absent().asSet();
	
	private class ProviderImpl extends AbstractProvider<LibhyphenHyphenator> {
		
		private ProviderImpl(Logger context) {
			super(context);
		}
		
		protected Transform.Provider.MemoizingProvider<LibhyphenHyphenator> _withContext(Logger context) {
			return new ProviderImpl(context);
		}
		
		protected final Iterable<WithSideEffect<LibhyphenHyphenator,Logger>> __get(String query) {
			final Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.remove("hyphenator")) != null)
				if (!"hyphen".equals(o.get()))
					return Optional.of(
						WithSideEffect.<LibhyphenHyphenator,Logger>fromNullable( fromId(o.get()) )
					).asSet();
			String table = null;
			if ((o = q.remove("libhyphen-table")) != null)
				table = o.get();
			if ((o = q.remove("table")) != null)
				if (table != null) {
					logger.warn("A query with both 'table' and 'libhyphen-table' never matches anything");
					return empty; }
				else
					table = o.get();
			if (table != null) {
				if (q.size() > 0) {
					logger.warn("A query with both 'table' or 'libhyphen-table' and '"
					            + q.keySet().iterator().next() + "' never matches anything");
					return empty; }
				return Optional.of(LibhyphenJnaImpl.this.get(asURI(table))).asSet(); }
			if (tableProvider != null) {
				String locale = "und";
				if ((o = q.remove("locale")) != null)
					locale = o.get();
				return filter(
					transform(
						tableProvider.get(parseLocale(locale)),
						new Function<URI,WithSideEffect<LibhyphenHyphenator,Logger>>() {
							public WithSideEffect<LibhyphenHyphenator,Logger> apply(URI table) {
								return LibhyphenJnaImpl.this.get(table); }}),
					notNull()); }
			return empty;
		}
	}
		
	private final static char US = '\u001F';
	private final static Splitter SEGMENT_SPLITTER = Splitter.on(US);
	
	private class LibhyphenHyphenatorImpl extends AbstractTransform implements LibhyphenHyphenator {
		
		private final URI table;
		private final Hyphenator hyphenator;
		
		private LibhyphenHyphenatorImpl(URI table) throws FileNotFoundException {
			this.table = table;
			hyphenator = new Hyphenator(resolveTable(table));
		}
		
		public URI asLibhyphenTable() {
			return table;
		}
		
		public String transform(String text) {
			return transform(new String[]{text})[0];
		}
		
		public String[] transform(String[] text) {
			try {
				// This byte array is used not only to track the hyphen
				// positions but also the segment boundaries.
				byte[] positions;
				Tuple2<String,byte[]> t = extractHyphens(join(text, US), SHY, ZWSP);
				String[] unhyphenated = toArray(SEGMENT_SPLITTER.split(t._1), String.class);
				t = extractHyphens(t._2, t._1, null, null, US);
				String _text = t._1;
				if (t._2 != null)
					positions = t._2;
				else
					positions = new byte[_text.length() - 1];
				byte[] autoHyphens = hyphenator.hyphenate(_text);
				for (int i = 0; i < autoHyphens.length; i++)
					positions[i] += autoHyphens[i];
				_text = insertHyphens(_text, positions, SHY, ZWSP, US);
				if (text.length == 1)
					return new String[]{_text};
				else {
					String[] rv = new String[text.length];
					int i = 0;
					for (String s : SEGMENT_SPLITTER.split(_text)) {
						while (unhyphenated[i].length() == 0)
							rv[i++] = "";
						rv[i++] = s; }
					while(i < text.length)
						rv[i++] = "";
					return rv; }}
			catch (Exception e) {
				throw new RuntimeException("Error during libhyphen hyphenation", e); }
		}
		
		@Override
		public String toString() {
			return toStringHelper(this).add("table", table).toString();
		}
	}
	
	private File resolveTable(URI table) {
		URL resolvedTable = isAbsoluteFile(table) ? asURL(table) : tableResolver.resolve(table);
		if (resolvedTable == null)
			throw new RuntimeException("Hyphenation table " + table + " could not be resolved");
		return asFile(resolvedTable);
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LibhyphenJnaImpl.class);
	
}