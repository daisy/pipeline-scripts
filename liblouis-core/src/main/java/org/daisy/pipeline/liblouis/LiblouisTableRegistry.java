package org.daisy.pipeline.liblouis;

import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
import java.util.StringTokenizer;

public class LiblouisTableRegistry {

	private static final Map<String,LiblouisTableSet> tableSets = new HashMap<String,LiblouisTableSet>();

	public void addTableSet(LiblouisTableSet tableSet) {
		System.out.println("Adding table set to registry: " + tableSet.getIdentifier());
		tableSets.put(tableSet.getIdentifier(), tableSet);
		exportLouisTablePath();
	}

	public void removeTableSet(LiblouisTableSet tableSet) {
		System.out.println("Removing table set from registry: " + tableSet.getIdentifier());
		tableSets.remove(tableSet.getIdentifier());
		exportLouisTablePath();
	}

	private static void exportLouisTablePath() {
		Environment.setVariable("LOUIS_TABLEPATH", getLouisTablePath(), true);
	}

	private static String getLouisTablePath() {
		List<String> paths = new ArrayList<String>();
		for (LiblouisTableSet tableSet : tableSets.values()) {
			paths.add(tableSet.getPath().getAbsolutePath());
		}
		return StringUtils.join(paths, ",");
	}

	public static abstract class TableFinder {

		public static String find(String locale) {
			return find(parseLocale(locale));
		}

		/**
		 * Try to find a table based on the given locale.
		 * An automatic fallback mechanism is used: if nothing is found for
		 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
		 */
		public static String find(Locale locale) {
			if ("".equals(locale.toString())) {
				return null;
			}
			for (String id : tableSets.keySet()) {
				if (!tableMap.containsKey(id)) {
					tableMap.put(id, readManifest(tableSets.get(id)));
				}
			}
			if (!"".equals(locale.getVariant())) {
				for (String id : tableSets.keySet()) {
					Map<String,String> map = tableMap.get(id);
					if (map.containsKey(locale.toString())) {
						return map.get(locale.toString());
					}
				}
			}
			if (!"".equals(locale.getCountry())) {
				for (String id : tableSets.keySet()) {
					Map<String,String> map = tableMap.get(id);
					if (map.containsKey(locale.getLanguage() + "_" + locale.getCountry())) {
						return map.get(locale.getLanguage() + "_" + locale.getCountry());
					}
				}
			}
			if (!"".equals(locale.getLanguage())) {
				for (String id : tableSets.keySet()) {
					Map<String,String> map = tableMap.get(id);
					if (map.containsKey(locale.getLanguage())) {
						return map.get(locale.getLanguage());
					}
				}
			}
			return null;
		}

		private static final Map<String,Map<String,String>> tableMap
				= new HashMap<String,Map<String,String>>();

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
					System.out.println("Could not read manifest for table set " + tableSet.getIdentifier());
					e.printStackTrace();
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
}
