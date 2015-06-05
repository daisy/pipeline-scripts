package org.daisy.pipeline.braille.tex.impl;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.net.URI;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

import com.google.common.base.Function;
import com.google.common.base.Optional;
import com.google.common.base.Predicates;
import com.google.common.collect.Iterables;

import net.davidashen.text.Utf8TexParser.TexParserException;

import static org.daisy.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.TextTransform;
import static org.daisy.pipeline.braille.common.util.Files.isAbsoluteFile;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import static org.daisy.pipeline.braille.common.util.URIs.resolve;
import static org.daisy.pipeline.braille.common.util.URLs.asURL;
import org.daisy.pipeline.braille.tex.TexHyphenator;
import org.daisy.pipeline.braille.tex.TexHyphenatorTableRegistry;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Deactivate;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.tex.impl.TexHyphenatorDotifyImpl",
	service = {
		TexHyphenator.Provider.class,
		TextTransform.Provider.class,
		Hyphenator.Provider.class
	}
)
public class TexHyphenatorDotifyImpl implements TexHyphenator.Provider {
	
	private TexHyphenatorTableRegistry tableRegistry;
	
	@Activate
	protected void activate() {
		logger.debug("Loading TeX hyphenation service (Dotify impl)");
	}
	
	@Deactivate
	protected void deactivate() {
		logger.debug("Unloading TeX hyphenation service (Dotify impl)");
	}
	
	@Reference(
		name = "TexHyphenatorTableRegistry",
		unbind = "unbindTableRegistry",
		service = TexHyphenatorTableRegistry.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindTableRegistry(TexHyphenatorTableRegistry registry) {
		tableRegistry = registry;
		logger.debug("Registering Tex hyphenation table registry: " + registry);
	}
	
	protected void unbindTableRegistry(TexHyphenatorTableRegistry registry) {
		tableRegistry = null;
	}
	
	/**
	 * Recognized features:
	 *
	 * - hyphenator: Will only match if the value is `tex' or `texhyph'.
	 *
	 * - table: A tex table is a URI that is be either a file name, a file path relative to a
	 *     registered tablepath, an absolute file URI, or a fully qualified table identifier. A URI
	 *     can either point to a LaTeX pattern file (".tex") or a Java properties file (".xml" or
	 *     ".properties") that Dotify uses as the format for storing hyphenator configurations. The
	 *     `table' feature is not compatible with `locale'.
	 *
	 * - locale: Matches only hyphenators with that locale.
	 *
	 * No other features are allowed.
	 */
	public Iterable<TexHyphenator> get(String query) {
		return provider.get(query);
	}
	
	private TexHyphenator get(URI table) {
		try {
			URL resolved = resolveTable(table);
			Properties properties = new Properties();
			URI base = null;
			if (table.toString().endsWith(".tex")) {
				properties.setProperty(TexHyphenatorImpl.PATTERN_PATH_KEY, asURI(resolved).toASCIIString());
				properties.setProperty(TexHyphenatorImpl.MODE_KEY, TexHyphenatorImpl.BYTE_MODE); }
			else if (table.toString().endsWith(".properties")) {
				base = asURI(resolved);
				InputStream stream = resolved.openStream();
				properties.load(stream);
				stream.close(); }
			else if (table.toString().endsWith(".xml")) {
				base = asURI(resolved);
				InputStream stream = resolved.openStream();
				properties.loadFromXML(stream);
				stream.close(); }
			else
				return null;
			try {
				return new TexHyphenatorImpl(properties, base); }
			catch (Exception e) {
				logger.warn("Could not create a hyphenator for properties " + properties, e); }}
		catch (Exception e) {
			logger.warn("Could not create a hyphenator for table", e); }
		return null;
	}
	
	private URL resolveTable(URI table) {
		URL resolvedTable = isAbsoluteFile(table) ? asURL(table) : tableRegistry.resolve(table);
		if (resolvedTable == null)
			throw new RuntimeException("Hyphenation table " + table + " could not be resolved");
		return resolvedTable;
	}
	
	private final static Iterable<TexHyphenator> empty = Optional.<TexHyphenator>absent().asSet();
	
	private CachedProvider<String,TexHyphenator> provider
	= new CachedProvider<String,TexHyphenator>() {
		public Iterable<TexHyphenator> delegate(String query) {
			Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.remove("hyphenator")) != null)
				if (!"texhyph".equals(o.get()) && !"tex".equals(o.get()))
					return empty;
			if ((o = q.remove("table")) != null) {
				if (q.size() > 0) {
					logger.warn("A query with both 'table' and '" + q.keySet().iterator().next() + "' never matches anything");
					return empty; }
				return Optional.<TexHyphenator>fromNullable(
					TexHyphenatorDotifyImpl.this.get(asURI(o.get()))).asSet(); }
			Locale locale;
			if ((o = q.remove("locale")) != null)
				locale = parseLocale(o.get());
			else
				locale = parseLocale("und");
			if (!q.isEmpty()) {
				logger.warn("A query with '" + q.keySet().iterator().next() + "' never matches anything");
				return empty; }
			if (tableRegistry != null) {
				return Iterables.<TexHyphenator>filter(
					Iterables.<URI,TexHyphenator>transform(
						tableRegistry.get(locale),
						new Function<URI,TexHyphenator>() {
							public TexHyphenator apply(URI table) {
								return TexHyphenatorDotifyImpl.this.get(table); }}),
					Predicates.notNull()); }
			return empty; }};
	
	/*
	 * Code originally taken from org.daisy.dotify.impl.hyphenator.latex.HyphenationConfig
	 */
	private class TexHyphenatorImpl implements TexHyphenator {
		
		private final static String LEFT_HYPHEN_MIN_KEY = "beginLimit";
		private final static String RIGHT_HYPHEN_MIN_KEY = "endLimit";
		private final static String ENCODING_KEY = "encoding";
		private final static String PATTERN_PATH_KEY = "patternPath";
		private final static String MODE_KEY = "mode";
		private final static String BYTE_MODE = "byte";
		private final static String CHARACTER_MODE = "character";
		
		private final URI table;
		private final net.davidashen.text.Hyphenator hyphenator;
		private final int beginLimit;
		private final int endLimit;
		
		private TexHyphenatorImpl(Properties props, URI base) throws IOException, TexParserException {
			String patternPath = props.getProperty(PATTERN_PATH_KEY);
			if (patternPath == null)
				throw new RuntimeException("Required property named '" + PATTERN_PATH_KEY + "' missing.");
			table = base == null ? asURI(patternPath) : resolve(base, patternPath);
			hyphenator = new net.davidashen.text.Hyphenator();
			String leftHyphenMinStr = props.getProperty(LEFT_HYPHEN_MIN_KEY);
			if (leftHyphenMinStr != null)
				beginLimit = Integer.parseInt(leftHyphenMinStr);
			else
				beginLimit = 1;
			String rightHyphenMinStr = props.getProperty(RIGHT_HYPHEN_MIN_KEY);
			if (rightHyphenMinStr != null)
				endLimit = Integer.parseInt(rightHyphenMinStr);
			else
				endLimit = 1;
			String encoding = props.getProperty(ENCODING_KEY);
			String modeStr = props.getProperty(MODE_KEY);
			if (modeStr == null)
				throw new RuntimeException("Required property named '" + MODE_KEY + "' missing.");
			else if (modeStr.equals(BYTE_MODE)) {
				if (encoding != null)
					logger.warn("Configuration problem: Encoding has no effect in byte mode.");
				hyphenator.loadTable(asURL(table).openStream()); }
			else if (modeStr.equals(CHARACTER_MODE)) {
				if (encoding == null)
					logger.warn("Configuration problem: Encoding should be set in character mode.");
				hyphenator.loadTable(new InputStreamReader(asURL(table).openStream(), Charset.forName(encoding))); }
			else
				throw new RuntimeException("Unrecognized mode. Allowed values are " + BYTE_MODE + " and " + CHARACTER_MODE);
		}
		
		public URI asTexHyphenatorTable() {
			return table;
		}
		
		public String transform(String text) {
			try {
				return hyphenator.hyphenate(text, beginLimit, endLimit); }
			catch (Exception e) {
				throw new RuntimeException("Error during TeX hyphenation", e); }
		}
		
		public String[] transform(String[] text) {
			throw new UnsupportedOperationException();
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(TexHyphenatorDotifyImpl.class);
	
}
