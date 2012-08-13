package org.daisy.pipeline.liblouis;

import java.util.HashMap;
import java.util.Map;

import org.liblouis.Translator;

public class Liblouis {

	private static Map<String,Translator> translatorMap = new HashMap<String,Translator>();

	private static Translator getTranslator(String tables) {

		Translator translator = translatorMap.get(tables);
		if (translator == null) {
			translator = new Translator(tables);
			translatorMap.put(tables, translator);
		}
		return translator;
	}

	public static String translate(String tables, String text) {
		try {
			tables = "unicode.dis," + tables + ",braille-patterns.cti";
			text = squeeze(text);
			return getTranslator(tables).translate(text).getBraille();
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	public static String squeeze(final String in) {
		return in.replaceAll("(?:\\p{Z}|\\s)+", " ");
	}
}
