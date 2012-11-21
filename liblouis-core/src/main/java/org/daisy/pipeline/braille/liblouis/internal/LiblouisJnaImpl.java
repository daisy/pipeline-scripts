package org.daisy.pipeline.braille.liblouis.internal;

import java.io.File;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisJnaImpl implements Liblouis {

	private final static char SOFT_HYPHEN = '\u00AD';
	
	private final Iterable<URL> jarURLs;
	private final File nativeDirectory;
	private final LiblouisTableResolver tableResolver;
	private Constructor<?> Translator;
	private Method translate;
	private Method hyphenate;
	private Method getBraille;
	private Method getHyphenPositions;
	private boolean loaded = false;
	
	public LiblouisJnaImpl(Iterable<URL> jarURLs, Iterable<URL> nativeURLs, File unpackDirectory, LiblouisTableResolver tableResolver) {
		this.jarURLs = jarURLs;
		Iterator<URL> nativeURLsIterator = nativeURLs.iterator();
		if (!nativeURLsIterator.hasNext())
			throw new IllegalArgumentException("Argument nativeURLs must not be empty");
		for (File file : unpack(nativeURLsIterator, unpackDirectory))
			if (!file.getName().endsWith(".dll")) chmod775(file);
		nativeDirectory = unpackDirectory;
		this.tableResolver = tableResolver;
	}
	
	public LiblouisJnaImpl load() {
		if (!loaded) {
			try {
				ClassLoader classLoader = new LiblouisJnaClassLoader(jarURLs, nativeDirectory);
				Class<?> TranslatorClass = classLoader.loadClass("org.liblouis.Translator");
				Class<?> TranslationResultClass = classLoader.loadClass("org.liblouis.TranslationResult");
				Translator = TranslatorClass.getConstructor(String.class);
				translate = TranslatorClass.getMethod("translate", String.class, byte[].class, boolean[].class, boolean.class);
				hyphenate = TranslatorClass.getMethod("hyphenate", String.class);
				getBraille = TranslationResultClass.getMethod("getBraille");
				getHyphenPositions = TranslationResultClass.getMethod("getHyphenPositions");
				//logger.debug("Loading liblouis service: version {}", ...);
				}
			catch (Exception e) {
				throw new RuntimeException("Could not load liblouis service", e); }
			loaded = true; }
		return this;
	}
	
	public void unload() {
		if (!loaded) return;
		Translator = null;
		translate = null;
		hyphenate = null;
		getBraille = null;
		getHyphenPositions = null;
		translatorCache.clear();
		System.gc();
		loaded = false;
	}
	/**
	 * {@inheritDoc}
	 */
	public String translate(URL table, String text, byte[] typeform, boolean hyphenate) {
		if (!loaded) load();
		try {
			Object translator = getTranslator(table);
			boolean[] hyphens = null;
			if (text.contains(String.valueOf(SOFT_HYPHEN))) {
				Pair<String,boolean[]> input = extractHyphens(text, SOFT_HYPHEN);
				text = input._1;
				hyphens = input._2; }
			Object result = translate.invoke(translator, text, typeform, hyphens, hyphenate);
			if (hyphenate || hyphens != null)
				return insertHyphens((String)getBraille.invoke(result),
						(boolean[])getHyphenPositions.invoke(result),
						SOFT_HYPHEN);
			else
				return (String)getBraille.invoke(result); }
		catch (InvocationTargetException e) {
			throw new RuntimeException(e.getCause()); }
		catch (Exception e) {
			throw new RuntimeException("Error during liblouis translation", e); }
	}
	
	/**
	 * {@inheritDoc}
	 */
	public String hyphenate(URL table, String text) {
		if (!loaded) load();
		try {
			Object translator = getTranslator(table);
			return insertHyphens(text,
					(boolean[])getHyphenPositions.invoke(hyphenate.invoke(translator, text)),
					SOFT_HYPHEN); }
		catch (InvocationTargetException e) {
			throw new RuntimeException(e.getCause()); }
		catch (Exception e) {
			throw new RuntimeException("Error during liblouis translation", e); }
	}
	
	private Map<URL,Object> translatorCache = new HashMap<URL,Object>();

	private Object getTranslator(URL table) {
		try {
			Object translator = translatorCache.get(table);
			if (translator == null) {
				translator = Translator.newInstance(
						fileFromURL(tableResolver.resolveTable(table)).getCanonicalPath());
				translatorCache.put(table, translator); }
			return translator; }
		catch (Exception e) {
			throw new RuntimeException(e); }
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisJnaImpl.class);

}
