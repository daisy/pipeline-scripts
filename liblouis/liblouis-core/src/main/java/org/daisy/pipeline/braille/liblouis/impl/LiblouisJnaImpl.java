package org.daisy.pipeline.braille.liblouis.impl;

import java.io.File;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import org.daisy.pipeline.braille.BundledNativePath;
import org.daisy.pipeline.braille.ResourceResolver;
import org.daisy.pipeline.braille.Utilities.Pair;
import org.daisy.pipeline.braille.liblouis.Liblouis;
import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;

import static org.daisy.pipeline.braille.Utilities.Files.asFile;
import static org.daisy.pipeline.braille.Utilities.Files.asURL;
import static org.daisy.pipeline.braille.Utilities.Files.isAbsoluteFile;
import static org.daisy.pipeline.braille.Utilities.Strings.extractHyphens;
import static org.daisy.pipeline.braille.Utilities.Strings.insertHyphens;

import org.liblouis.Louis;
import org.liblouis.TranslationResult;
import org.liblouis.Translator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisJnaImpl implements Liblouis {
	
	private final static char SOFT_HYPHEN = '\u00AD';
	
	private BundledNativePath nativePath;
	private ResourceResolver tableResolver;
	
	protected void activate() {
		logger.debug("Loading liblouis service");
	}
	
	protected void deactivate() {
		logger.debug("Unloading liblouis service");
	}
	
	protected void bindLibrary(BundledNativePath nativePath) {
		if (this.nativePath == null) {
			URL libraryPath = nativePath.lookup("liblouis");
			if (libraryPath != null) {
				Louis.setLibraryPath(asFile(libraryPath));
				this.nativePath = nativePath;
				logger.debug("Registering liblouis library: " + libraryPath);
				logger.debug("liblouis version: {}", Louis.getLibrary().lou_version()); }}
	}
	
	protected void unbindLibrary(BundledNativePath nativePath) {
		if (nativePath.equals(this.nativePath))
			this.nativePath = null;
	}
	
	protected void bindTableResolver(LiblouisTableResolver tableResolver) {
		this.tableResolver = tableResolver;
	}
	
	protected void unbindTableResolver(LiblouisTableResolver path) {
		this.tableResolver = null;
	}
	
	/**
	 * {@inheritDoc}
	 */
	public String translate(String table, String text, byte[] typeform, boolean hyphenate) {
		try {
			Translator translator = getTranslator(table);
			boolean[] hyphens = null;
			if (text.contains(String.valueOf(SOFT_HYPHEN))) {
				Pair<String,boolean[]> input = extractHyphens(text, SOFT_HYPHEN);
				text = input._1;
				hyphens = input._2; }
			TranslationResult result = translator.translate(text, typeform, hyphens, hyphenate);
			if (hyphenate || hyphens != null)
				return insertHyphens(result.getBraille(), result.getHyphenPositions(), SOFT_HYPHEN);
			else
				return result.getBraille(); }
		catch (Exception e) {
			throw new RuntimeException("Error during liblouis translation", e); }
	}
	
	/**
	 * {@inheritDoc}
	 */
	public String hyphenate(String table, String text) {
		try {
			Translator translator = getTranslator(table);
			return insertHyphens(text, translator.hyphenate(text), SOFT_HYPHEN); }
		catch (Exception e) {
			throw new RuntimeException("Error during liblouis hyphenation", e); }
	}
	
	private Map<String,Translator> translatorCache = new HashMap<String,Translator>();

	private Translator getTranslator(String table) {
		try {
			Translator translator = translatorCache.get(table);
			if (translator == null) {
				translator = new Translator(resolveTable(table).getCanonicalPath());
				translatorCache.put(table, translator); }
			return translator; }
		catch (Exception e) {
			throw new RuntimeException(e); }
	}
	
	private File resolveTable(String table) {
		URL resolvedTable = isAbsoluteFile(table) ? asURL(table) : tableResolver.resolve(table);
		if (resolvedTable == null)
			throw new RuntimeException("Liblouis table " + table + " could not be resolved");
		return asFile(resolvedTable);
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisJnaImpl.class);
	
}
