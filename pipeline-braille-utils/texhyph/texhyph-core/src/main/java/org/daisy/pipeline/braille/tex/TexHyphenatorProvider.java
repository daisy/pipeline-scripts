package org.daisy.pipeline.braille.tex;

import java.io.InputStream;
import java.net.URI;
import java.net.URL;

import net.davidashen.text.Hyphenator;

import org.daisy.pipeline.braille.common.Cached;
import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.ResourceResolver;
import static org.daisy.pipeline.braille.common.util.Files.isAbsoluteFile;
import static org.daisy.pipeline.braille.common.util.URLs.asURL;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TexHyphenatorProvider implements Provider<URI,TexHyphenator> {
	
	private ResourceResolver tableResolver;
	
	protected void activate() {
		logger.debug("Loading TeX hyphenation service");
	}
	
	protected void deactivate() {
		logger.debug("Unloading TeX hyphenation service");
	}
	
	protected void bindTableResolver(TexHyphenatorTableResolver tableResolver) {
		this.tableResolver = tableResolver;
	}
	
	protected void unbindTableResolver(TexHyphenatorTableResolver path) {
		this.tableResolver = null;
	}
	
	private Cached<URI,TexHyphenator> hyphenators = new Cached<URI,TexHyphenator>() {
		public TexHyphenator delegate(URI table) {
			try {
				Hyphenator hyphenator = new Hyphenator();
				InputStream stream = resolveTable(table).openStream();
				hyphenator.loadTable(stream);
				stream.close();
				return new TexHyphenatorImpl(hyphenator); }
			catch (Exception e) {
				throw new RuntimeException(e); }
		}
	};
	
	/**
	 * @param table Can be a file name or path relative to a registered table path,
	 *     an absolute file, or a fully qualified table URL.
	 */
	public TexHyphenator get(URI table) {
		return hyphenators.get(table);
	}
	
	private static class TexHyphenatorImpl implements TexHyphenator {
		
		private Hyphenator hyphenator;
		
		private TexHyphenatorImpl(Hyphenator hyphenator) {
			this.hyphenator = hyphenator;
		}
		
		public String hyphenate(String text) {
			try {
				return hyphenator.hyphenate(text); }
			catch (Exception e) {
				throw new RuntimeException("Error during TeX hyphenation", e); }
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
