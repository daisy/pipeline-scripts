package org.daisy.pipeline.liblouis.internal;

import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.StringTokenizer;

import org.daisy.pipeline.liblouis.LiblouisTableFinder;
import org.daisy.pipeline.liblouis.LiblouisTableSet;

public class LiblouisTableFinderImpl implements LiblouisTableFinder {

	public String find(String locale) {
		return find(parseLocale(locale));
	}

	/**
	 * Try to find a table based on the given locale.
	 * An automatic fallback mechanism is used: if nothing is found for
	 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
	 */
	public String find(Locale locale) {
		if ("".equals(locale.toString())) {
			return null;
		}
		if (cache.containsKey(locale)) {
			return cache.get(locale);
		}
		for (LiblouisTableSet set : tableSets) {
			if (!tableMap.containsKey(set)) {
				tableMap.put(set, readManifest(set));
			}
		}
		if (!"".equals(locale.getVariant())) {
			for (LiblouisTableSet set : tableSets) {
				Map<String,String> map = tableMap.get(set);
				String key = locale.toString();
				if (map.containsKey(key)) {
					String table = map.get(key);
					cache.put(locale, table);
					return table;
				}
			}
		}
		if (!"".equals(locale.getCountry())) {
			for (LiblouisTableSet set : tableSets) {
				Map<String,String> map = tableMap.get(set);
				String key = locale.getLanguage() + "_" + locale.getCountry();
				if (map.containsKey(key)) {
					String table = map.get(key);
					cache.put(locale, table);
					return table;
				}
			}
		}
		if (!"".equals(locale.getLanguage())) {
			for (LiblouisTableSet set : tableSets) {
				Map<String,String> map = tableMap.get(set);
				String key = locale.getLanguage();
				if (map.containsKey(key)) {
					String table = map.get(key);
					cache.put(locale, table);
					return table;
				}
			}
		}
		return null;
	}

	public void addTableSet(LiblouisTableSet tableSet) {
		tableSets.add(tableSet);
		cache.clear();
	}
	
	public void removeTableSet(LiblouisTableSet tableSet) {
		tableSets.remove(tableSet);
		cache.clear();
	}
	
	private final Set<LiblouisTableSet> tableSets = new HashSet<LiblouisTableSet>();
	
	private final Map<LiblouisTableSet,Map<String,String>> tableMap
			= new HashMap<LiblouisTableSet,Map<String,String>>();

	private final Map<Locale,String> cache = new HashMap<Locale,String>();

	private static Map<String,String> readManifest(LiblouisTableSet tableSet) {
		Map<String,String> map = new HashMap<String,String>();
		URL manifest = tableSet.getManifest();
		if (manifest != null) {
			try {
				manifest.openConnection();
				InputStream reader = manifest.openStream();
				Properties properties = new Properties();
				properties.loadFromXML(reader);
				for (String key : properties.stringPropertyNames()) {
					String locale = parseLocale(key).toString();
					if (!map.containsKey(locale)) {
						map.put(locale, properties.getProperty(key));
					}
				}
				reader.close();
			} catch (Exception e) {
				throw new RuntimeException("Could not read manifest for table set " + tableSet.getIdentifier(), e);
			}
		}
		return map;
	}

	public static Locale parseLocale(String locale) {
		StringTokenizer parser = new StringTokenizer(locale, "-_");
		if (parser.hasMoreTokens()) {
			String lang = parser.nextToken();
			if (parser.hasMoreTokens()) {
				String country = parser.nextToken();
				if (parser.hasMoreTokens()) {
					String variant = parser.nextToken();
					return new Locale(lang, country, variant);
				} else {
					return new Locale(lang, country);
				}
			} else {
				return new Locale(lang);
			}
		} else {
			throw new IllegalArgumentException("Locale '" + locale + "' could not be parsed");
		}
	}
}
