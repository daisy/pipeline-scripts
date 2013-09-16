package org.daisy.pipeline.braille.libhyphen;

import java.io.File;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import ch.sbs.jhyphen.Hyphen;
import ch.sbs.jhyphen.Hyphenator;

import org.daisy.pipeline.braille.BundledNativePath;
import org.daisy.pipeline.braille.ResourceResolver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.daisy.pipeline.braille.Utilities.Files.asFile;
import static org.daisy.pipeline.braille.Utilities.Files.asURL;
import static org.daisy.pipeline.braille.Utilities.Files.isAbsoluteFile;

public class Libhyphen {
	
	private final static char SHY = '\u00AD';
	private final static char ZWSP = '\u200B';
	
	private BundledNativePath nativePath;
	private ResourceResolver tableResolver;
	
	protected void activate() {
		logger.debug("Loading libhyphen service");
	}
	
	protected void deactivate() {
		logger.debug("Unloading libhyphen service");
	}
	
	protected void bindLibrary(BundledNativePath nativePath) {
		if (this.nativePath == null) {
			URL libraryPath = nativePath.lookup("libhyphen");
			if (libraryPath != null) {
				Hyphen.setLibraryPath(asFile(libraryPath));
				this.nativePath = nativePath;
				logger.debug("Registering libhyphen library: " + libraryPath); }}
	}
	
	protected void unbindLibrary(BundledNativePath nativePath) {
		if (nativePath.equals(this.nativePath))
			this.nativePath = null;
	}
	
	protected void bindTableResolver(LibhyphenTableResolver tableResolver) {
		this.tableResolver = tableResolver;
	}
	
	protected void unbindTableResolver(LibhyphenTableResolver path) {
		this.tableResolver = null;
	}
	
	/**
	 * @param table Can be a file name or path relative to a registered table path,
	 *     an absolute file, or a fully qualified table URL.
	 * @param text The text to be hyphenated.
	 */
	public String hyphenate(String table, String text) {
		try {
			return getHyphenator(table).hyphenate(text, SHY, ZWSP); }
		catch (Exception e) {
			throw new RuntimeException("Error during libhyphen hyphenation", e); }
	}
	
	private Map<String,Hyphenator> hyphenatorCache = new HashMap<String,Hyphenator>();
	
	private Hyphenator getHyphenator(String table) {
		try {
			Hyphenator hyphenator = hyphenatorCache.get(table);
			if (hyphenator == null) {
				hyphenator = new Hyphenator(resolveTable(table));
				hyphenatorCache.put(table, hyphenator); }
			return hyphenator; }
		catch (Exception e) {
			throw new RuntimeException(e); }
	}
	
	private File resolveTable(String table) {
		URL resolvedTable = isAbsoluteFile(table) ? asURL(table) : tableResolver.resolve(table);
		if (resolvedTable == null)
			throw new RuntimeException("Hyphenation table " + table + " could not be resolved");
		return asFile(resolvedTable);
	}
	
	private static final Logger logger = LoggerFactory.getLogger(Libhyphen.class);
}
