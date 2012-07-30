package org.daisy.pipeline.liblouis;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.liblouis.liblouisutdml;

public class Liblouisutdml {

	private static final liblouisutdml INSTANCE = liblouisutdml.getInstance();

	/**
	 * @param configFiles: array of file names (or null)
	 * @param semanticFiles: array of file names (or null)
	 * @param tables: array of file names (or null)
	 * @param otherSettings: key/value pairs (or null)
	 * @param input: the input file
	 * @param output: path to the output file
	 * @param configPath: directory that must contain liblouisutdml.ini & all files listed in configFiles and semanticFiles
	 * @param tempDir: directory where liblouisutdml can store temporary files
	 */
	public static void translateFile(
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
			INSTANCE.setWriteablePath(tempDir.getAbsolutePath());
			INSTANCE.translateFile(configFileList, inputFileName, outputFileName, null, StringUtils.join(settingsList, "\n"), 0);
		} catch (Exception e) {
			e.printStackTrace();
			throw new RuntimeException("Liblouisutdml error");
		}
	}
}
