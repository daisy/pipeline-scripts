package org.daisy.pipeline.liblouis.internal;

import java.io.File;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.daisy.pipeline.liblouis.LiblouisTableRegistry;
import org.daisy.pipeline.liblouis.Liblouisutdml;
import org.daisy.pipeline.liblouis.Utilities.Files;
import org.daisy.pipeline.liblouis.Utilities.Strings;

public class LiblouisutdmlJniImpl implements Liblouisutdml {

	private final Iterable<URL> jarURLs;
	private final File nativeDirectory;
	private final LiblouisTableRegistry tableRegistry;
	private Object liblouisutdml;
	private Method setWriteablePath;
	private Method translateFile;
	private boolean loaded = false;
	
	public LiblouisutdmlJniImpl(Iterable<URL> jarURLs, Iterable<URL> nativeURLs, File unpackDirectory, LiblouisTableRegistry tableRegistry) {
		this.jarURLs = jarURLs;
		Iterator<URL> nativeURLsIterator = nativeURLs.iterator();
		if (!nativeURLsIterator.hasNext())
			throw new IllegalArgumentException("Argument nativeURLs must not be empty");
		for (File file : Files.unpack(nativeURLsIterator, unpackDirectory))
			if (!file.getName().endsWith(".dll")) Files.chmod775(file);
		nativeDirectory = unpackDirectory;
		this.tableRegistry = tableRegistry;
	}
	
	public void load() {
		if (loaded) return;
		try {
			ClassLoader classLoader = new LiblouisutdmlJniClassLoader(jarURLs, nativeDirectory);
			Class<?> liblouisutdmlClass = classLoader.loadClass("org.liblouis.liblouisutdml");
			liblouisutdml = liblouisutdmlClass.getMethod("getInstance").invoke(null);
			setWriteablePath = liblouisutdmlClass.getMethod("setWriteablePath", String.class);
			translateFile = liblouisutdmlClass.getMethod("translateFile", String.class,
					String.class, String.class, String.class, String.class, int.class); }
		catch (Exception e) {
			throw new RuntimeException("Liblouisutdml instance could not be loaded", e); }
		loaded = true;
	}
	
	public void unload() {
		if (!loaded) return;
		liblouisutdml = null;
		setWriteablePath = null;
		translateFile = null;
		System.gc();
		loaded = false;
	}
	
	public void translateFile(
			List<String> configFiles,
			List<String> semanticFiles,
			String table,
			Map<String,String> otherSettings,
			File input,
			File output,
			File configPath,
			File tempDir) {

		if (!loaded) load();
		
		try {
			
			String configFileList = configPath.getAbsolutePath() + File.separator +
					(configFiles != null ? Strings.join(configFiles, ",") : "");
			String inputFileName = input.getAbsolutePath();
			String outputFileName = output.getAbsolutePath();
	
			Map<String,String> settings = new HashMap<String,String>();
			if (semanticFiles != null)
				settings.put("semanticFiles", Strings.join(semanticFiles, ","));
			settings.put("literaryTextTable", tableRegistry.resolveTableURL(table));
			if (otherSettings != null)
				settings.putAll(otherSettings);
			List<String> settingsList = new ArrayList<String>();
			for (String key : settings.keySet())
				settingsList.add(key + " " + settings.get(key));
	
			System.out.println("translateFile");
			System.out.println("	configFiles: " + configFileList);
			System.out.println("	inputFile: " + inputFileName);
			System.out.println("	outputFile: " + outputFileName);
			System.out.println("	settings: " + Strings.join(settingsList, " "));

			setWriteablePath.invoke(liblouisutdml, tempDir.getAbsolutePath());
			translateFile.invoke(liblouisutdml, configFileList, inputFileName, outputFileName,
					null,Strings.join(settingsList, "\n"), 0); }
		catch (Exception e) {
			e.printStackTrace();
			throw new RuntimeException("Liblouisutdml error", e); }
	}
}
