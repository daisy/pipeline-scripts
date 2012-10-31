package org.daisy.pipeline.braille.liblouis.internal;

import java.io.File;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.daisy.pipeline.braille.liblouis.Liblouis;
import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;

import static org.daisy.pipeline.braille.Utilities.Files.chmod775;
import static org.daisy.pipeline.braille.Utilities.Files.fileFromURL;
import static org.daisy.pipeline.braille.Utilities.Files.unpack;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisJnaImpl implements Liblouis {

	private final Iterable<URL> jarURLs;
	private final File nativeDirectory;
	private final LiblouisTableResolver tableResolver;
	private Constructor<?> Translator;
	private Method translate;
	private Method translateWithTypeform;
	private Method getBraille;
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
				translate = TranslatorClass.getMethod("translate", String.class);
				translateWithTypeform = TranslatorClass.getMethod("translate", String.class, byte[].class);
				getBraille = TranslationResultClass.getMethod("getBraille");
				logger.debug("Loading liblouis service: version {}", TranslatorClass.getMethod("version").invoke(null)); }
			catch (Exception e) {
				throw new RuntimeException("Could not load liblouis service", e); }
			loaded = true; }
		return this;
	}
	
	public void unload() {
		if (!loaded) return;
		Translator = null;
		translate = null;
		getBraille = null;
		translatorCache.clear();
		System.gc();
		loaded = false;
	}
	
	/**
	 * {@inheritDoc}
	 */
	public String translate(URL table, String text) {
		if (!loaded) load();
		try {
			Object translator = getTranslator(
					fileFromURL(tableResolver.resolveTable(table)).getCanonicalPath());
			return (String)getBraille.invoke(translate.invoke(translator, text)); }
		catch (InvocationTargetException e) {
			throw new RuntimeException(e.getCause()); }
		catch (Exception e) {
			throw new RuntimeException("Error during liblouis translation", e); }
	}
	
	/**
	 * {@inheritDoc}
	 */
	public String translate(URL table, String text, byte[] typeform) {
		if (!loaded) load();
		try {
			Object translator = getTranslator(
					fileFromURL(tableResolver.resolveTable(table)).getCanonicalPath());
			return (String)getBraille.invoke(translateWithTypeform.invoke(translator, text, typeform)); }
		catch (InvocationTargetException e) {
			throw new RuntimeException(e.getCause()); }
		catch (Exception e) {
			throw new RuntimeException("Error during liblouis translation", e); }
	}
	
	private Map<String,Object> translatorCache = new HashMap<String,Object>();

	private Object getTranslator(String tables) {
		try {
			Object translator = translatorCache.get(tables);
			if (translator == null) {
				translator = Translator.newInstance(tables);
				translatorCache.put(tables, translator); }
			return translator; }
		catch (Exception e) {
			throw new RuntimeException(e); }
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisJnaImpl.class);

}
