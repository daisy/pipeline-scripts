package org.liblouis;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Liblouisxml {

	/**
	 * @param configFiles (or null): array of filenames
	 * @param semanticFiles (or null): array of filenames
	 * @param tables (or null): array of filenames
	 * @param otherSettings (or null): key/value pairs
	 * @param input: an existing file
	 * @param output: path to the output file
	 * @param configPath (or null): - a directory that must contain canonical.cfg (liblouisutdml.ini)
	 *                                  & all files listed in configFiles and semanticFiles
	 * 								- can be relative to tempDir
	 * 								- if configPath is null, . (tempDir) is used
	 * @param tablePath: LOUIS_TABLEPATH
	 * @param tempDir
	 * @throws Exception
	 */

	public static void xml2brl(
			List<String> configFiles,
			List<String> semanticFiles,
			List<String> tables,
			Map<String,String> otherSettings,
			File input,
			File output,
			File configPath,
			String tablePath,
			File tempDir) throws Exception {

        List<String> command = new ArrayList<String>();

        //command.add(Activator.getNativePath() + File.separator + "xml2brl");
        command.add(Activator.getNativePath() + File.separator + "file2brl"
        				+ (OSUtils.isWindows() ? ".exe" : ""));
        command.add("-f");
        command.add((configPath != null ? configPath.getAbsolutePath() : ".") + File.separator +
        		(configFiles != null ? StringUtils.join(configFiles, ",") : ""));

        Map<String,String> settings = new HashMap<String,String>();
        if (semanticFiles != null) {
			settings.put("semanticFiles", StringUtils.join(semanticFiles, ","));
		}
		if (tables != null) {
			settings.put("literaryTextTable", StringUtils.join(tables, ","));
		}
		if (otherSettings!= null && !otherSettings.isEmpty()) {
			settings.putAll(otherSettings);
		}

        for (String key : settings.keySet()) {
        	command.add("-C" + key + "=" + settings.get(key));
        }

        command.add(input.getAbsolutePath());
        command.add(output.getAbsolutePath());

        ProcessBuilder builder = new ProcessBuilder(command);
        builder.environment().put("LOUIS_TABLEPATH", tablePath);
        builder.directory(tempDir);
        Process process = builder.start();

        if (process.waitFor() != 0) {
            BufferedReader stderr = new BufferedReader(new InputStreamReader(process.getErrorStream()));
            String error = "";
            String line = null;
            while ((line = stderr.readLine()) != null) {
                error += line + "\n";
            }
            stderr.close();
            if (!error.isEmpty()) {
                throw new RuntimeException("Liblouisxml error:\n" + error);
            } else {
            	throw new RuntimeException("Liblouisxml abnormal termination");
            }
        }
	}
}
