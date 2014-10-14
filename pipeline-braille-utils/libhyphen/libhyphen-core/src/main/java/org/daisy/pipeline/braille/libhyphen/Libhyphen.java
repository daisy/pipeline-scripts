package org.daisy.pipeline.braille.libhyphen;

import java.io.File;
import java.net.URI;
import java.net.URL;

import ch.sbs.jhyphen.Hyphen;
import ch.sbs.jhyphen.Hyphenator;

import org.daisy.pipeline.braille.common.BundledNativePath;
import org.daisy.pipeline.braille.common.Cached;
import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.ResourceResolver;
import static org.daisy.pipeline.braille.common.util.Files.asFile;
import static org.daisy.pipeline.braille.common.util.Files.isAbsoluteFile;
import static org.daisy.pipeline.braille.common.util.URLs.asURL;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Libhyphen implements Provider<URI,LibhyphenTranslator> {
	
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
			URI libraryPath = nativePath.get("libhyphen");
			if (libraryPath != null) {
				Hyphen.setLibraryPath(asFile(nativePath.resolve(libraryPath)));
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
	
	private Cached<URI,LibhyphenTranslator> translators = new Cached<URI,LibhyphenTranslator>() {
		public LibhyphenTranslator delegate(URI table) {
			try {
				return new LibhyphenTranslatorImpl(new Hyphenator(resolveTable(table))); }
			catch (Exception e) {
				throw new RuntimeException(e); }
		}
	};
	
	/**
	 * @param table Can be a file name or path relative to a registered table path,
	 *     an absolute file, or a fully qualified table URL.
	 */
	public LibhyphenTranslator get(URI table) {
		return translators.get(table);
	}
	
	private static class LibhyphenTranslatorImpl implements LibhyphenTranslator {
		
		private Hyphenator hyphenator;
		
		private LibhyphenTranslatorImpl(Hyphenator hyphenator) {
			this.hyphenator = hyphenator;
		}
		
		public String hyphenate(String text) {
			try {
				return hyphenator.hyphenate(text, SHY, ZWSP); }
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
