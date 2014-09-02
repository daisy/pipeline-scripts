package org.daisy.pipeline.braille.liblouis.impl;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import org.daisy.pipeline.braille.BundledNativePath;
import org.daisy.pipeline.braille.Utilities.Pair;
import org.daisy.pipeline.braille.liblouis.Liblouis;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator;
import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;

import static org.daisy.pipeline.braille.liblouis.LiblouisTablePath.serializeTableList;
import static org.daisy.pipeline.braille.liblouis.LiblouisTablePath.tokenizeTableList;
import static org.daisy.pipeline.braille.Utilities.Files.asFile;
import static org.daisy.pipeline.braille.Utilities.Strings.extractHyphens;
import static org.daisy.pipeline.braille.Utilities.Strings.insertHyphens;
import static org.daisy.pipeline.braille.Utilities.Strings.join;

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
		try {
			if (LIBLOUIS_EXTERNAL)
				logger.info("Using external liblouis");
			else if (this.nativePath == null)
				throw new RuntimeException("No liblouis library registered");
			logger.debug("liblouis version: {}", Louis.getLibrary().lou_version());
			if (tableResolver == null)
				throw new RuntimeException("No liblouis table resolver bound");
			final LiblouisTableResolver tableResolver = this.tableResolver;
			_tableResolver = new TableResolver() {
				public File[] invoke(String tableList, File base) {
					logger.debug("Resolving " + tableList + (base != null ? " against base " + base : ""));
					File[] resolved = tableResolver.resolveTableList(tokenizeTableList(tableList), base);
					if (resolved != null)
						logger.debug("Resolved to " + join(resolved, ","));
					else
						logger.error("Table could not be resolved");
						return resolved; }};
			Louis.getLibrary().lou_registerTableResolver(_tableResolver); }
		catch (Throwable e) {
			logger.error("liblouis service could not be loaded", e);
			throw e; }
	}
	
	protected void deactivate() {
		logger.debug("Unloading liblouis service");
	}
	
	protected void bindLibrary(BundledNativePath nativePath) {
		if (!LIBLOUIS_EXTERNAL && this.nativePath == null) {
			URL libraryPath = nativePath.resolve(nativePath.lookup("liblouis"));
			if (libraryPath != null) {
				Louis.setLibraryPath(asFile(libraryPath));
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
	
	private Map<String,LiblouisTranslator> translatorCache = new HashMap<String,LiblouisTranslator>();
	
	public LiblouisTranslator get(URI[] table) {
		String tableString = serializeTableList(table);
		LiblouisTranslator translator = translatorCache.get(tableString);
		if (translator == null) {
			try {
				translator = new LiblouisTranslatorJnaImpl(new Translator(tableString));
				translatorCache.put(tableString, translator); }
			catch (CompilationException e) {
				throw new RuntimeException(e); }}
		return translator;
	}
	
	private static class LiblouisTranslatorJnaImpl implements LiblouisTranslator {
		
		private Translator translator;
		
		private LiblouisTranslatorJnaImpl(Translator translator) {
			this.translator = translator;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public String translate(String text, boolean hyphenated, byte[] typeform) {
			try {
				byte[] hyphens = null;
				if (hyphenated) {
					Pair<String,byte[]> input = extractHyphens(text, SHY, ZWSP);
					text = input._1;
					hyphens = input._2; }
				TranslationResult result = translator.translate(text, hyphens, typeform);
				return insertHyphens(result.getBraille(), result.getHyphenPositions(), SHY, ZWSP); }
			catch (TranslationException e) {
				throw new RuntimeException(e); }
		}
		
		/**
		 * {@inheritDoc}
		 */
		public String hyphenate(String text) {
			try {
				return insertHyphens(text, translator.hyphenate(text), SHY, ZWSP); }
			catch (TranslationException e) {
				throw new RuntimeException(e); }
		}
		
		public String display(String braille) {
			try {
				return translator.display(braille); }
			catch (TranslationException e) {
				throw new RuntimeException(e); }
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisJnaImpl.class);
	
}
