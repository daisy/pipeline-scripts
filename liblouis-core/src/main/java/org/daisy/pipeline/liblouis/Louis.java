package org.daisy.pipeline.liblouis;

import java.util.HashMap;
import java.util.Map;

import org.liblouis.Translator;

public class Louis {

	private static final String TABLE_SET_ID = "org.daisy.pipeline.liblouis.DefaultLiblouisTableSet";

	static {
		Environment.setVariable("LOUIS_TABLEPATH",
				LiblouisTableRegistry.getLouisTablePath(TABLE_SET_ID), true);
	}

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
			return getTranslator(tables).translate(text).getBraille();
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}
}
