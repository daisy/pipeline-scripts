package org.daisy.pipeline.braille.liblouis.impl;

import java.io.File;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;

import org.daisy.pipeline.braille.BundledNativePath;
import org.daisy.pipeline.braille.Utilities.Pair;
import org.daisy.pipeline.braille.liblouis.Liblouis;
import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;

import static org.daisy.pipeline.braille.liblouis.LiblouisTablePath.tokenizeTableList;
import static org.daisy.pipeline.braille.Utilities.Files.asFile;
import static org.daisy.pipeline.braille.Utilities.Strings.extractHyphens;
import static org.daisy.pipeline.braille.Utilities.Strings.insertHyphens;

import org.liblouis.Louis;
import org.liblouis.CompilationException;
import org.liblouis.TableResolver;
import org.liblouis.TranslationException;
import org.liblouis.TranslationResult;
import org.liblouis.Translator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisJnaImpl implements Liblouis {
	
	private final static char SHY = '\u00AD';
	private final static char ZWSP = '\u200B';
	private final static boolean LIBLOUIS_EXTERNAL = Boolean.getBoolean("org.daisy.pipeline.liblouis.external");
	
	private BundledNativePath nativePath;
	private LiblouisTableResolver tableResolver;
	
	// Hold a reference to avoid garbage collection
	private TableResolver _tableResolver;
	
	protected void activate() {
		logger.debug("Loading liblouis service");
		logger.debug("liblouis version: {}", Louis.getLibrary().lou_version());
		final LiblouisTableResolver tableResolver = this.tableResolver;
		_tableResolver = new TableResolver() {
			public File[] invoke(String tableList, File base) {
				logger.debug("Resolving " + tableList);
				return tableResolver.resolveTableList(tokenizeTableList(tableList), base); }};
		Louis.getLibrary().lou_registerTableResolver(_tableResolver);
	}
	
	protected void deactivate() {
		logger.debug("Unloading liblouis service");
	}
	
	protected void bindLibrary(BundledNativePath nativePath) {
		if (!LIBLOUIS_EXTERNAL && this.nativePath == null) {
			URI libraryPath = nativePath.lookup("liblouis");
			if (libraryPath != null) {
				Louis.setLibraryPath(asFile(nativePath.resolve(libraryPath)));
				this.nativePath = nativePath;
				logger.debug("Registering liblouis library: " + libraryPath); }}
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
	public String translate(String table, String text, boolean hyphenated, byte[] typeform) {
		try {
			Translator translator = compile(table);
			byte[] hyphens = null;
			if (hyphenated) {
				Pair<String,byte[]> input = extractHyphens(text, SHY, ZWSP);
				text = input._1;
				hyphens = input._2; }
			TranslationResult result = translator.translate(text, hyphens, typeform);
			return insertHyphens(result.getBraille(), result.getHyphenPositions(), SHY, ZWSP); }
		catch (TranslationException e) {
			throw new RuntimeException(e); }
		catch (CompilationException e) {
			throw new RuntimeException(e); }
	}
	
	/**
	 * {@inheritDoc}
	 */
	public String hyphenate(String table, String text) {
		try {
			Translator translator = compile(table);
			return insertHyphens(text, translator.hyphenate(text), SHY, ZWSP); }
		catch (TranslationException e) {
			throw new RuntimeException(e); }
		catch (CompilationException e) {
			throw new RuntimeException(e); }
	}
	
	private Map<String,Translator> translatorCache = new HashMap<String,Translator>();

	private Translator compile(String table) throws CompilationException {
		Translator translator = translatorCache.get(table);
		if (translator == null) {
			translator = new Translator(table);
			translatorCache.put(table, translator); }
		return translator;
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisJnaImpl.class);
	
}
