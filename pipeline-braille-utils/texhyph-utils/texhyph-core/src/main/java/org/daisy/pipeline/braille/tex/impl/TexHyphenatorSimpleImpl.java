package org.daisy.pipeline.braille.tex.impl;

import java.io.InputStream;
import java.io.IOException;
import java.net.URI;
import java.net.URL;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import com.google.common.base.Function;
import com.google.common.base.Optional;
import com.google.common.base.Predicates;
import com.google.common.collect.Iterables;

import static org.daisy.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.TextTransform;
import static org.daisy.pipeline.braille.common.util.Files.isAbsoluteFile;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
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
	name = "org.daisy.pipeline.braille.tex.impl.TexHyphenatorSimpleImpl",
	service = {
		TexHyphenator.Provider.class,
		TextTransform.Provider.class,
		Hyphenator.Provider.class
	}
)
public class TexHyphenatorSimpleImpl implements TexHyphenator.Provider {
	
	private TexHyphenatorTableRegistry tableRegistry;
	
	@Activate
	protected void activate() {
		logger.debug("Loading TeX hyphenation service");
	}
	
	@Deactivate
	protected void deactivate() {
		logger.debug("Unloading TeX hyphenation service");
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
	 * - table: A tex table is a URI that is either a file name, a file path relative to a
	 *     registered tablepath, an absolute file URI, or a fully qualified table identifier. Only
	 *     URIs that point to LaTeX pattern files (ending with ".tex") are matched. The `table'
	 *     feature is not compatible with `locale'.
	 *
	 * - locale: Matches only hyphenators with that locale.
	 *
	 * No other features are allowed.
	 */
	public Iterable<TexHyphenator> get(String query) {
		return provider.get(query);
	}
	
	private TexHyphenator get(URI table) {
		if (table.toString().endsWith(".tex")) {
			try { return new TexHyphenatorImpl(table); }
			catch (Exception e) {
				logger.warn("Could not create hyphenator for table " + table, e); }}
		return null;
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
					TexHyphenatorSimpleImpl.this.get(asURI(o.get()))).asSet(); }
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
								return TexHyphenatorSimpleImpl.this.get(table); }}),
					Predicates.notNull()); }
			return empty; }};
	
	private class TexHyphenatorImpl implements TexHyphenator {
		
		private final URI table;
		private final net.davidashen.text.Hyphenator hyphenator;
		
		private TexHyphenatorImpl(URI table) throws IOException {
			this.table = table;
			hyphenator = new net.davidashen.text.Hyphenator();
			InputStream stream = resolveTable(table).openStream();
			hyphenator.loadTable(stream);
			stream.close();
		}
		
		public URI asTexHyphenatorTable() {
			return table;
		}
		
		public String transform(String text) {
			try { return hyphenator.hyphenate(text); }
			catch (Exception e) {
				throw new RuntimeException("Error during TeX hyphenation", e); }
		}
		
		public String[] transform(String[] text) {
			throw new UnsupportedOperationException();
		}
	}
	
	private URL resolveTable(URI table) {
		URL resolvedTable = isAbsoluteFile(table) ? asURL(table) : tableRegistry.resolve(table);
		if (resolvedTable == null)
			throw new RuntimeException("Hyphenation table " + table + " could not be resolved");
		return resolvedTable;
	}
	
	private static final Logger logger = LoggerFactory.getLogger(TexHyphenatorSimpleImpl.class);
	
}
