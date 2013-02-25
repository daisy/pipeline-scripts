package org.daisy.pipeline.braille.libhyphen;

import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import ch.sbs.jhyphen.Hyphenator;

import org.daisy.pipeline.braille.ResourceResolver;
import static org.daisy.pipeline.braille.Utilities.Files.asFile;

public class Libhyphen {
	
	private static final char SOFT_HYPHEN = '\u00AD';
	
	private final ResourceResolver tableResolver;
	
	public Libhyphen(ResourceResolver tableResolver) {
		this.tableResolver = tableResolver;
	}
	
	/**
	 * @param tables The fully qualified table URL.
	 * @param text The text to hyphenate.
	 */
	public String hyphenate(URL table, String text) {
		try {
			return getHyphenator(table).hyphenate(text, SOFT_HYPHEN); }
		catch (Exception e) {
			throw new RuntimeException("Error during libhyphen hyphenation", e); }
	}
	
	private Map<URL,Hyphenator> hyphenatorCache = new HashMap<URL,Hyphenator>();
	
	private Hyphenator getHyphenator(URL table) {
		try {
			Hyphenator hyphenator = hyphenatorCache.get(table);
			if (hyphenator == null) {
				URL resolvedTable = tableResolver.resolve(table);
				if (resolvedTable == null)
					throw new RuntimeException("Hyphenation table " + table + " could not be resolved");
				hyphenator = new Hyphenator(asFile(resolvedTable));
				hyphenatorCache.put(table, hyphenator); }
			return hyphenator; }
		catch (Exception e) {
			throw new RuntimeException(e); }
	}
}
