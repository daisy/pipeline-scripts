package org.daisy.pipeline.braille.tex;

import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import net.davidashen.text.Hyphenator;

import org.daisy.pipeline.braille.TableResolver;

public class TexHyphenator {
	
	private final TableResolver tableResolver;
	
	public TexHyphenator(TableResolver tableResolver) {
		this.tableResolver = tableResolver;
	}
	
	/**
	 * @param tables The fully qualified table URL.
	 * @param text The text to hyphenate.
	 */
	public String hyphenate(URL table, String text) {
		try {
			return getHyphenator(table).hyphenate(text); }
		catch (Exception e) {
			throw new RuntimeException("Error during TeX hyphenation", e); }
	}
	
	private Map<URL,Hyphenator> hyphenatorCache = new HashMap<URL,Hyphenator>();
	
	private Hyphenator getHyphenator(URL table) {
		try {
			Hyphenator hyphenator = hyphenatorCache.get(table);
			if (hyphenator == null) {
				hyphenator = new Hyphenator();
				InputStream stream = tableResolver.resolveTable(table).openStream();
				hyphenator.loadTable(stream);
				stream.close();
				hyphenatorCache.put(table, hyphenator); }
			return hyphenator; }
		catch (Exception e) {
			throw new RuntimeException(e); }
	}
}