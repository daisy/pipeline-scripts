package org.daisy.pipeline.liblouis.internal;

import java.io.File;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.daisy.pipeline.liblouis.Liblouis;
import org.daisy.pipeline.liblouis.Utilities.Files;

public class LiblouisJnaImpl implements Liblouis {

	private final Collection<URL> jarURLs;
	private final File nativeDirectory;
	private Constructor<?> Translator;
	private Method translate;
	private Method getBraille;
	private boolean loaded = false;
	
	public LiblouisJnaImpl(Collection<URL> jarURLs, Collection<URL> nativeURLs, File unpackDirectory) {
		this.jarURLs = jarURLs;
		for (File file : Files.unpack(nativeURLs, unpackDirectory))
			if (!file.getName().endsWith(".dll")) Files.chmod775(file);
		nativeDirectory = unpackDirectory;
	}
	
	public void load() {
		if (loaded) return;
		try {
			ClassLoader classLoader = new LiblouisJnaClassLoader(jarURLs, nativeDirectory);
			Class<?> TranslatorClass = classLoader.loadClass("org.liblouis.Translator");
			Class<?> TranslationResultClass = classLoader.loadClass("org.liblouis.TranslationResult");
			Translator = TranslatorClass.getConstructor(String.class);
			translate = TranslatorClass.getMethod("translate", String.class);
			getBraille = TranslationResultClass.getMethod("getBraille");
		} catch (Exception e) {
			throw new RuntimeException("Liblouis instance could not be loaded", e);
		}
		loaded = true;
	}
	
	public void unload() {
		if (!loaded) return;
		Translator = null;
		translate = null;
		getBraille = null;
		translatorMap.clear();
		System.gc(); // ? Doesn't always work immediately, sometimes needs a second garbage collection
		loaded = false;
	}
	
	public String translate(String tables, String text) {
		if (!loaded) load();
		try {
			tables = "unicode.dis," + tables + ",braille-patterns.cti";
			text = squeeze(text);
			return (String)getBraille.invoke(translate.invoke(getTranslator(tables), text));
		} catch (InvocationTargetException e) {
			throw new RuntimeException(e.getCause());
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}
	
	private Map<String,Object> translatorMap = new HashMap<String,Object>();

	private Object getTranslator(String tables) {
		try {
			Object translator = translatorMap.get(tables);
			if (translator == null) {
				translator = Translator.newInstance(tables);
				translatorMap.put(tables, translator);
			}
			return translator;
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private static String squeeze(final String in) {
		return in.replaceAll("(?:\\p{Z}|\\s)+", " ");
	}
}
