package org.daisy.pipeline.braille.liblouis.internal;

import java.io.File;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.daisy.pipeline.braille.Utilities.Pair;
import org.daisy.pipeline.braille.liblouis.Liblouis;
import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;

import static org.daisy.pipeline.braille.Utilities.Files.chmod775;
import static org.daisy.pipeline.braille.Utilities.Files.fileFromURL;
import static org.daisy.pipeline.braille.Utilities.Files.unpack;
import static org.daisy.pipeline.braille.Utilities.Strings.extractHyphens;
import static org.daisy.pipeline.braille.Utilities.Strings.insertHyphens;

import org.liblouis.Louis;
import org.liblouis.TranslationResult;
import org.liblouis.Translator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisJnaImpl implements Liblouis {

	private final static char SOFT_HYPHEN = '\u00AD';
	
	private final LiblouisTableResolver tableResolver;
	
	public LiblouisJnaImpl(Iterable<URL> nativeURLs, File unpackDirectory, LiblouisTableResolver tableResolver) {
		Iterator<URL> nativeURLsIterator = nativeURLs.iterator();
		if (!nativeURLsIterator.hasNext())
			throw new IllegalArgumentException("Argument nativeURLs must not be empty");
		File file = unpack(nativeURLsIterator, unpackDirectory).iterator().next();
		if (!file.getName().endsWith(".dll")) chmod775(file);
		Louis.setLibraryPath(file);
		logger.debug("Loading liblouis service: version {} ({})", Louis.getLibrary().lou_version(), file);
		this.tableResolver = tableResolver;
	}
	
	/**
	 * {@inheritDoc}
	 */
	public String translate(URL table, String text, byte[] typeform, boolean hyphenate) {
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
	public String hyphenate(URL table, String text) {
		try {
			Translator translator = getTranslator(table);
			return insertHyphens(text, translator.hyphenate(text), SOFT_HYPHEN); }
		catch (Exception e) {
			throw new RuntimeException("Error during liblouis hyphenation", e); }
	}
	
	private Map<URL,Translator> translatorCache = new HashMap<URL,Translator>();

	private Translator getTranslator(URL table) {
		try {
			Translator translator = translatorCache.get(table);
			if (translator == null) {
				translator = new Translator(
						fileFromURL(tableResolver.resolveTable(table)).getCanonicalPath());
				translatorCache.put(table, translator); }
			return translator; }
		catch (Exception e) {
			throw new RuntimeException(e); }
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisJnaImpl.class);

}
