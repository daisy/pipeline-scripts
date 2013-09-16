package org.daisy.pipeline.braille.tex;

import static org.daisy.pipeline.braille.Utilities.Files.asURL;
import static org.daisy.pipeline.braille.Utilities.Files.isAbsoluteFile;

import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import net.davidashen.text.Hyphenator;

import org.daisy.pipeline.braille.ResourceResolver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TexHyphenator {
	
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
	
	/**
	 * @param table Can be a file name or path relative to a registered table path, or a fully qualified table URL.
	 * @param text The text to hyphenate.
	 */
	public String hyphenate(String table, String text) {
		try {
			return getHyphenator(table).hyphenate(text); }
		catch (Exception e) {
			throw new RuntimeException("Error during TeX hyphenation", e); }
	}
	
	private Map<String,Hyphenator> hyphenatorCache = new HashMap<String,Hyphenator>();
	
	private Hyphenator getHyphenator(String table) {
		try {
			Hyphenator hyphenator = hyphenatorCache.get(table);
			if (hyphenator == null) {
				hyphenator = new Hyphenator();
				InputStream stream = resolveTable(table).openStream();
				hyphenator.loadTable(stream);
				stream.close();
				hyphenatorCache.put(table, hyphenator); }
			return hyphenator; }
		catch (Exception e) {
			throw new RuntimeException(e); }
	}
	
	private URL resolveTable(String table) {
		URL resolvedTable = isAbsoluteFile(table) ? asURL(table) : tableResolver.resolve(table);
		if (resolvedTable == null)
			throw new RuntimeException("Hyphenation table " + table + " could not be resolved");
		return resolvedTable;
	}
	
	private static final Logger logger = LoggerFactory.getLogger(TexHyphenator.class);
}
