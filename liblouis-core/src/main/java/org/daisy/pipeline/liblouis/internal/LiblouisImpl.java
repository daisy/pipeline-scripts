package org.daisy.pipeline.liblouis.internal;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

import org.daisy.pipeline.liblouis.Liblouis;

public class LiblouisImpl implements Liblouis {

	private Constructor<?> Translator;
	private Method translate;
	private Method getBraille;
	
	public LiblouisImpl(ClassLoader classLoader) {
		try {
			Class<?> TranslatorClass = classLoader.loadClass("org.liblouis.Translator");
			Class<?> TranslationResultClass = classLoader.loadClass("org.liblouis.TranslationResult");
			Translator = TranslatorClass.getConstructor(String.class);
			translate = TranslatorClass.getMethod("translate", String.class);
			getBraille = TranslationResultClass.getMethod("getBraille");
		} catch (Exception e) {
			throw new RuntimeException("Could not create Liblouis instance", e);
		}
	}
	
	public String translate(String tables, String text) {
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
