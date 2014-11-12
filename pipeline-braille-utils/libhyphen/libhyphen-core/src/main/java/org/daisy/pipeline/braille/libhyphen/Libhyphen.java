package org.daisy.pipeline.braille.libhyphen;

import java.io.File;
import java.io.FileNotFoundException;
import java.net.URI;
import java.net.URL;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

import ch.sbs.jhyphen.Hyphen;
import ch.sbs.jhyphen.Hyphenator;

import com.google.common.base.Function;
import com.google.common.base.Optional;
import com.google.common.base.Predicates;
import com.google.common.base.Splitter;
import com.google.common.collect.Iterables;

import static org.daisy.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.BundledNativePath;
import org.daisy.pipeline.braille.common.Provider.CachedProvider;
import org.daisy.pipeline.braille.common.ResourceResolver;
import org.daisy.pipeline.braille.common.TextTransform;
import static org.daisy.pipeline.braille.common.util.Files.asFile;
import static org.daisy.pipeline.braille.common.util.Files.isAbsoluteFile;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Strings.extractHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.insertHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import org.daisy.pipeline.braille.common.util.Tuple2;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import static org.daisy.pipeline.braille.common.util.URLs.asURL;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Deactivate;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.libhyphen.Libhyphen",
	service = {
		Libhyphen.class,
		TextTransform.Provider.class,
		org.daisy.pipeline.braille.common.Hyphenator.Provider.class
	}
)
public class Libhyphen implements TextTransform.Provider<LibhyphenHyphenator>,
                                  org.daisy.pipeline.braille.common.Hyphenator.Provider<LibhyphenHyphenator> {
	
	private final static char SHY = '\u00AD';
	private final static char ZWSP = '\u200B';
	
	private BundledNativePath nativePath;
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
		name = "LiblouisLibrary",
		unbind = "unbindLibrary",
		service = BundledNativePath.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.STATIC
	)
	protected void bindLibrary(BundledNativePath path) {
		if (nativePath == null) {
			URI libraryPath = Iterables.<URI>getFirst(path.get("libhyphen"), null);
			if (libraryPath != null) {
				Hyphen.setLibraryPath(asFile(path.resolve(libraryPath)));
				nativePath = path;
				logger.debug("Registering libhyphen library: " + libraryPath); }}
	}
	
	protected void unbindLibrary(BundledNativePath path) {
		if (path.equals(nativePath))
			nativePath = null;
	}
	
	@Reference(
		name = "LibhyphenTableResolver",
		unbind = "unbindTableResolver",
		service = LibhyphenTableResolver.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindTableResolver(LibhyphenTableResolver resolver) {
		tableResolver = resolver;
		logger.debug("Registering libhyphen table resolver: " + resolver);
	}
	
	protected void unbindTableResolver(LibhyphenTableResolver resolver) {
		tableResolver = null;
	}
	
	@Reference(
		name = "LibhyphenTableProvider",
		unbind = "unbindTableProvider",
		service = LibhyphenTableProvider.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindTableProvider(LibhyphenTableProvider provider) {
		tableProvider = provider;
		logger.debug("Registering libhyphen table provider: " + provider);
	}
	
	protected void unbindTableProvider(LibhyphenTableProvider provider) {
		tableProvider = null;
	}
	
	private LibhyphenHyphenator get(URI table) {
		try { return new LibhyphenHyphenatorImpl(table); }
		catch (Exception e) {
			logger.warn("Could not create hyphenator for table " + table, e); }
		return null;
	}
	
	private final static Iterable<LibhyphenHyphenator> empty = Optional.<LibhyphenHyphenator>absent().asSet();
	
	private CachedProvider<String,LibhyphenHyphenator> provider
		= new CachedProvider<String,LibhyphenHyphenator>() {
			public Iterable<LibhyphenHyphenator> delegate(String query) {
				Map<String,Optional<String>> q = parseQuery(query);
				if (q.containsKey("hyphenator"))
					if (!"hyphen".equals(q.get("hyphenator").get()))
						return empty;
				if (q.containsKey("table")) {
					return Optional.<LibhyphenHyphenator>fromNullable(
						Libhyphen.this.get(asURI(q.get("table").get()))).asSet(); }
				Locale locale;
				if (q.containsKey("locale"))
					locale = parseLocale(q.get("locale").get());
				else
					locale = parseLocale("und");
				if (tableProvider != null) {
					return Iterables.<LibhyphenHyphenator>filter(
						Iterables.<URI,LibhyphenHyphenator>transform(
							tableProvider.get(locale),
							new Function<URI,LibhyphenHyphenator>() {
								public LibhyphenHyphenator apply(URI table) {
									return Libhyphen.this.get(table); }}),
						Predicates.notNull()); }
				return empty; }};
	
	public Iterable<LibhyphenHyphenator> get(String query) {
		return provider.get(query);
	}
	
	private final static char US = '\u001F';
	private final static Pattern SHY_ZWSP = Pattern.compile(String.format("$[%c%c]*^", SHY, ZWSP));
	private final static Splitter SEGMENT_SPLITTER = Splitter.on(US);
	
	private class LibhyphenHyphenatorImpl extends LibhyphenHyphenator {
		
		private final URI table;
		private final Hyphenator hyphenator;
		
		/**
		 * A Hyphen table can be a file name or path relative to a registered
		 * table path, an absolute file, or a fully qualified table URL.
		 */
		private LibhyphenHyphenatorImpl(URI table) throws FileNotFoundException {
			this.table = table;
			hyphenator = new Hyphenator(resolveTable(table));
		}
		
		public URI asLibhyphenTable() {
			return table;
		}
		
		public String hyphenate(String text) {
			return hyphenate(new String[]{text})[0];
		}
		
		public String[] hyphenate(String[] text) {
			try {
				// This byte array is used not only to track the hyphen
				// positions but also the segment boundaries.
				byte[] positions;
				Tuple2<String,byte[]> t = extractHyphens(join(text, US), SHY, ZWSP);
				String[] unhyphenated = Iterables.<String>toArray(SEGMENT_SPLITTER.split(t._1), String.class);
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
	}
	
	private File resolveTable(URI table) {
		URL resolvedTable = isAbsoluteFile(table) ? asURL(table) : tableResolver.resolve(table);
		if (resolvedTable == null)
			throw new RuntimeException("Hyphenation table " + table + " could not be resolved");
		return asFile(resolvedTable);
	}
	
	private static final Logger logger = LoggerFactory.getLogger(Libhyphen.class);
	
}
