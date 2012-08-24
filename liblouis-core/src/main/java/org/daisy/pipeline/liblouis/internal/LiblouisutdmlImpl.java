package org.daisy.pipeline.liblouis.internal;

import java.io.File;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.daisy.pipeline.liblouis.Liblouisutdml;
import org.daisy.pipeline.liblouis.Utilities.StringUtils;

public class LiblouisutdmlImpl implements Liblouisutdml {

	private Object liblouisutdml;
	private Method setWriteablePath;
	private Method translateFile;
	
	public LiblouisutdmlImpl(ClassLoader classLoader) {
		try {
			Class<?> liblouisutdmlClass = classLoader.loadClass("org.liblouis.liblouisutdml");
			liblouisutdml = liblouisutdmlClass.getMethod("getInstance").invoke(null);
			setWriteablePath = liblouisutdmlClass.getMethod("setWriteablePath", String.class);
			translateFile = liblouisutdmlClass.getMethod("translateFile", String.class, String.class,
					String.class, String.class, String.class, int.class);
		} catch (Exception e) {
			throw new RuntimeException("Could not create Liblouisutdml instance", e);
		}
	}
	
	public void translateFile(
			List<String> configFiles,
			List<String> semanticFiles,
			List<String> tables,
			Map<String,String> otherSettings,
			File input,
			File output,
			File configPath,
			File tempDir) {

		String configFileList = configPath.getAbsolutePath() + File.separator +
				(configFiles != null ? StringUtils.join(configFiles, ",") : "");
		String inputFileName = input.getAbsolutePath();
		String outputFileName = output.getAbsolutePath();

		Map<String,String> settings = new HashMap<String,String>();
		if (semanticFiles != null) {
			settings.put("semanticFiles", StringUtils.join(semanticFiles, ","));
		}
		if (tables != null) {
			settings.put("literaryTextTable", StringUtils.join(tables, ","));
		}
		if (otherSettings != null) {
			settings.putAll(otherSettings);
		}
		List<String> settingsList = new ArrayList<String>();
		for (String key : settings.keySet()) {
			settingsList.add(key + " " + settings.get(key));
		}

		System.out.println("translateFile");
		System.out.println("	configFiles: " + configFileList);
		System.out.println("	inputFile: " + inputFileName);
		System.out.println("	outputFile: " + outputFileName);
		System.out.println("	settings: " + StringUtils.join(settingsList, " "));

		try {
			setWriteablePath.invoke(liblouisutdml, tempDir.getAbsolutePath());
			translateFile.invoke(liblouisutdml, configFileList, inputFileName, outputFileName, null, StringUtils.join(settingsList, "\n"), 0);
		} catch (Exception e) {
			e.printStackTrace();
			throw new RuntimeException("Liblouisutdml error", e);
		}
	}
}
