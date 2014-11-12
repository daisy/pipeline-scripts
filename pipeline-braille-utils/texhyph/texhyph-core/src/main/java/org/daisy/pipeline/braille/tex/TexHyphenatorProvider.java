package org.daisy.pipeline.braille.tex;

import java.io.InputStream;
import java.io.IOException;
import java.net.URI;
import java.net.URL;
import java.util.Locale;
import java.util.Map;

import com.google.common.base.Function;
import com.google.common.base.Optional;
import com.google.common.base.Predicates;
import com.google.common.collect.Iterables;

import net.davidashen.text.Hyphenator;

import static org.daisy.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.Provider.CachedProvider;
import org.daisy.pipeline.braille.common.ResourceResolver;
import org.daisy.pipeline.braille.common.TextTransform;
import static org.daisy.pipeline.braille.common.util.Files.isAbsoluteFile;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
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
	name = "org.daisy.pipeline.braille.tex.TexHyphenatorProvider",
	service = {
		TexHyphenatorProvider.class,
		TextTransform.Provider.class,
		
	}
)
public class TexHyphenatorProvider implements TextTransform.Provider<TexHyphenator>,
                                              org.daisy.pipeline.braille.common.Hyphenator.Provider<TexHyphenator> {
	
	private ResourceResolver tableResolver;
	private TexHyphenatorTableProvider tableProvider;
	
	@Activate
	protected void activate() {
		logger.debug("Loading TeX hyphenation service");
	}
	
	@Deactivate
	protected void deactivate() {
		logger.debug("Unloading TeX hyphenation service");
	}
	
	@Reference(
		name = "TexHyphenatorTableResolver",
		unbind = "unbindTableResolver",
		service = TexHyphenatorTableResolver.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindTableResolver(TexHyphenatorTableResolver resolver) {
		tableResolver = resolver;
		logger.debug("Registering Tex hyphenation table resolver: " + resolver);
	}
	
	protected void unbindTableResolver(TexHyphenatorTableResolver resolver) {
		tableResolver = null;
	}
	
	@Reference(
		name = "TexHyphenatorTableProvider",
		unbind = "unbindTableProvider",
		service = TexHyphenatorTableProvider.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindTableProvider(TexHyphenatorTableProvider provider) {
		tableProvider = provider;
		logger.debug("Registering Tex hyphenation table provider: " + provider);
	}
	
	protected void unbindTableProvider(TexHyphenatorTableProvider provider) {
		tableProvider = null;
	}
	
	private TexHyphenator get(URI table) {
		try { return new TexHyphenatorImpl(table); }
		catch (Exception e) {
			logger.warn("Could not create hyphenator for table " + table, e); }
		return null;
	}
	
	private final static Iterable<TexHyphenator> empty = Optional.<TexHyphenator>absent().asSet();
	
	private CachedProvider<String,TexHyphenator> provider
		= new CachedProvider<String,TexHyphenator>() {
			public Iterable<TexHyphenator> delegate(String query) {
				Map<String,Optional<String>> q = parseQuery(query);
				if (q.containsKey("hyphenator"))
					if (!"texhyph".equals(q.get("hyphenator").get()) && !"tex".equals(q.get("hyphenator").get()))
						return empty;
				if (q.containsKey("table")) {
					return Optional.<TexHyphenator>fromNullable(
						TexHyphenatorProvider.this.get(asURI(q.get("table").get()))).asSet(); }
				Locale locale;
				if (q.containsKey("locale"))
					locale = parseLocale(q.get("locale").get());
				else
					locale = parseLocale("und");
				if (tableProvider != null) {
					return Iterables.<TexHyphenator>filter(
						Iterables.<URI,TexHyphenator>transform(
							tableProvider.get(locale),
							new Function<URI,TexHyphenator>() {
								public TexHyphenator apply(URI table) {
									return TexHyphenatorProvider.this.get(table); }}),
						Predicates.notNull()); }
				return empty; }};
	
	public Iterable<TexHyphenator> get(String query) {
		return provider.get(query);
	}
		
	private class TexHyphenatorImpl extends TexHyphenator {
		
		private final URI table;
		private final Hyphenator hyphenator;
		
		/**
		 * @param table Can be a file name or path relative to a registered
		 * table path, an absolute file, or a fully qualified table URL.
		 */
		private TexHyphenatorImpl(URI table) throws IOException {
			this.table = table;
			hyphenator = new Hyphenator();
			InputStream stream = resolveTable(table).openStream();
			hyphenator.loadTable(stream);
			stream.close();
		}
		
		public URI asTexHyphenatorTable() {
			return table;
		}
		
		public String hyphenate(String text) {
			try { return hyphenator.hyphenate(text); }
			catch (Exception e) {
				throw new RuntimeException("Error during TeX hyphenation", e); }
		}
		
		public String[] hyphenate(String[] text) {
			throw new UnsupportedOperationException();
		}
	}
	
	private URL resolveTable(URI table) {
		URL resolvedTable = isAbsoluteFile(table) ? asURL(table) : tableResolver.resolve(table);
		if (resolvedTable == null)
			throw new RuntimeException("Hyphenation table " + table + " could not be resolved");
		return resolvedTable;
	}
	
	private static final Logger logger = LoggerFactory.getLogger(TexHyphenator.class);
	
}
