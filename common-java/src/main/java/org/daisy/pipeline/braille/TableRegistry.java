package org.daisy.pipeline.braille;

import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

import org.daisy.pipeline.braille.Utilities.Files;
import org.daisy.pipeline.braille.Utilities.Locales;
import org.daisy.pipeline.braille.Utilities.Pair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class TableRegistry<T extends TablePath> implements TableResolver, TableFinder {

	public void addTablePath(T tablePath) {
		if (tablePaths.containsKey(tablePath.getIdentifier())) {
			logger.error("Table registry already contains table path with identifier {}", tablePath.getIdentifier());
			throw new RuntimeException("Table registry already contains table path with identifier " + tablePath.getIdentifier()); }
		try {
			tableMappings.put(tablePath, readManifest(tablePath)); }
		catch (RuntimeException e) {
			logger.error("Table path could not be registered: {}", tablePath.getIdentifier());
			throw e; }
		tablePaths.put(tablePath.getIdentifier(), tablePath);
		resolverCache.clear();
		finderCache.clear();
		logger.debug("Adding table path to registry: {}", tablePath.getIdentifier());
	}

	public void removeTablePath(T tablePath) {
		tablePaths.remove(tablePath.getIdentifier());
		tableMappings.remove(tablePath);
		resolverCache.clear();
		finderCache.clear();
		logger.debug("Removing table path from registry: {}", tablePath.getIdentifier());
	}
	
	private final Map<URL,T> tablePaths = new HashMap<URL,T>();
	private final Map<T,Map<String,String>> tableMappings = new HashMap<T,Map<String,String>>();
	
	/*
	 * TableResolver
	 */
	
	public URL resolveTable(URL table) {
		URL resolved = resolverCache.get(table);
		if (resolved == null) {
			try {
				Pair<URL,String> components = Files.decomposeURL(table);
				TablePath path = tablePaths.get(components._1);
				if (path == null)
					throw new RuntimeException("No table path registered with identifier " + components._1);
				String name = components._2;
				if (!path.hasTable(name))
					throw new RuntimeException("Table path " + path + " has no table named " + name);
				resolved = Files.composeURL(path.getPath(), name);
				resolverCache.put(table, resolved); }
			catch (RuntimeException e) {
				logger.error("Cannot resolve table URL: {}", table);
				throw new RuntimeException("Cannot resolve table URL: " + table, e); }}
		return resolved;
	}
	
	private final Map<URL,URL> resolverCache = new HashMap<URL,URL>();
	
	/*
	 * TableFinder
	 */
	
	public URL find(String locale) {
		return find(Locales.parseLocale(locale));
	}

	/**
	 * Try to find a table based on the given locale.
	 * An automatic fallback mechanism is used: if nothing is found for
	 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
	 */
	public URL find(Locale locale) {
		if ("".equals(locale.toString()))
			return null;
		if (finderCache.containsKey(locale))
			return finderCache.get(locale);
		for (T path : tablePaths.values()) {
			if (!tableMappings.containsKey(path))
				tableMappings.put(path, readManifest(path)); }
		if (!"".equals(locale.getVariant())) {
			for (T path : tablePaths.values()) {
				Map<String,String> map = tableMappings.get(path);
				String key = locale.toString();
				if (map.containsKey(key)) {
					URL table = Files.composeURL(path.getIdentifier(), map.get(key));
					finderCache.put(locale, table);
					return table; }}}
		if (!"".equals(locale.getCountry())) {
			for (T path : tablePaths.values()) {
				Map<String,String> map = tableMappings.get(path);
				String key = locale.getLanguage() + "_" + locale.getCountry();
				if (map.containsKey(key)) {
					URL table = Files.composeURL(path.getIdentifier(), map.get(key));
					finderCache.put(locale, table);
					return table; }}}
		if (!"".equals(locale.getLanguage())) {
			for (T path : tablePaths.values()) {
				Map<String,String> map = tableMappings.get(path);
				String key = locale.getLanguage();
				if (map.containsKey(key)) {
					URL table = Files.composeURL(path.getIdentifier(), map.get(key));
					finderCache.put(locale, table);
					return table; }}}
		return null;
	}
	
	private final Map<Locale,URL> finderCache = new HashMap<Locale,URL>();

	private Map<String,String> readManifest(T tablePath) {
		Map<String,String> map = new HashMap<String,String>();
		URL manifest = tablePath.getManifest();
		if (manifest != null) {
			try {
				manifest.openConnection();
				InputStream reader = manifest.openStream();
				Properties properties = new Properties();
				properties.loadFromXML(reader);
				for (String key : properties.stringPropertyNames()) {
					String locale = Locales.parseLocale(key).toString();
					if (!map.containsKey(locale)) {
						String tableName = properties.getProperty(key);
						if (tablePath.hasTable(tableName))
							map.put(locale, tableName); }}
				reader.close(); }
			catch (Exception e) {
				logger.error("Could not read manifest for table path {}" + tablePath.getIdentifier());
				throw new RuntimeException("Could not read manifest for table path " + tablePath.getIdentifier(), e); }}
		return map;
	}
	
	private static final Logger logger = LoggerFactory.getLogger(TableRegistry.class);
}
