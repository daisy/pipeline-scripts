package org.daisy.pipeline.braille.liblouis.impl;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.util.Map;

import com.google.common.base.Optional;

import static org.daisy.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.BundledNativePath;
import org.daisy.pipeline.braille.common.Cached;
import static org.daisy.pipeline.braille.common.util.Files.asFile;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import org.daisy.pipeline.braille.common.util.Pair;
import static org.daisy.pipeline.braille.common.util.Strings.extractHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.insertHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.join;

import org.daisy.pipeline.braille.liblouis.Liblouis;
import static org.daisy.pipeline.braille.liblouis.LiblouisTablePath.serializeTableList;
import static org.daisy.pipeline.braille.liblouis.LiblouisTablePath.tokenizeTableList;
import org.daisy.pipeline.braille.liblouis.LiblouisTableProvider;
import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator;

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
	private LiblouisTableProvider tableProvider;
	
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
			URL libraryPath = nativePath.resolve(nativePath.get("liblouis"));
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
	
	protected void unbindTableResolver(LiblouisTableResolver tableResolver) {
		this.tableResolver = null;
	}
	
	protected void bindTableProvider(LiblouisTableProvider tableProvider) {
		this.tableProvider = tableProvider;
	}
	
	protected void unbindTableProvider(LiblouisTableProvider tableProvider) {
		this.tableProvider = null;
	}
	
	private Cached<URI[],LiblouisTranslator> translators = new Cached<URI[],LiblouisTranslator>() {
		public LiblouisTranslator delegate(URI[] table) {
			if (tableResolver.resolveTableList(table, null) == null)
				return null;
			try {
				return new LiblouisTranslatorJnaImpl(new Translator(serializeTableList(table))); }
			catch (CompilationException e) {
				throw new RuntimeException(e); }
		}
	};
	
	public LiblouisTranslator get(URI[] table) {
		return translators.get(table);
	}
	
	public LiblouisTranslator get(String query) {
		try {
			Map<String,Optional<String>> q = parseQuery(query);
			if (q.containsKey("table"))
				return get(tokenizeTableList(q.get("table").get()));
			if (tableProvider != null && q.containsKey("locale")) {
				URI[] table = tableProvider.get(parseLocale(q.get("locale").get()));
				if (table != null)
					return get(table); }}
		catch (Exception e) {}
		return null;
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
		
		public String translate(String text) {
			return translate(text, false, null);
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
