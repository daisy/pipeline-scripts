package org.daisy.pipeline.liblouis.internal;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import org.daisy.pipeline.liblouis.LiblouisTableRegistry;
import org.daisy.pipeline.liblouis.Liblouisutdml;
import org.daisy.pipeline.liblouis.Utilities.Files;
import org.daisy.pipeline.liblouis.Utilities.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisutdmlProcessBuilderImpl implements Liblouisutdml {
	
	private final File file2brl;
	private final LiblouisTableRegistry tableRegistry;
	
	public LiblouisutdmlProcessBuilderImpl(Iterable<URL> nativeURLs, File unpackDirectory, LiblouisTableRegistry tableRegistry) {
		try {
			file2brl = new File(unpackDirectory.getAbsolutePath() + File.separator
					+ Files.fileName(nativeURLs.iterator().next())); }
		catch (NoSuchElementException e) {
			throw new IllegalArgumentException("Argument nativeURLs must not be empty"); }
		for (File file : Files.unpack(nativeURLs.iterator(), unpackDirectory)) {
			if (!file.getName().matches(".*\\.(dll|exe)$")) Files.chmod775(file); }
		this.tableRegistry = tableRegistry;
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

		try {
			
			List<String> command = new ArrayList<String>();
			
			command.add(file2brl.getAbsolutePath());
			command.add("-f");
			command.add(configPath.getAbsolutePath() + File.separator +
					(configFiles != null ? Strings.join(configFiles, ",") : ""));
			Map<String,String> settings = new HashMap<String,String>();
			if (semanticFiles != null)
				settings.put("semanticFiles", Strings.join(semanticFiles, ","));
			settings.put("literaryTextTable", tableRegistry.resolveTableURL(table));
			if (otherSettings != null)
				settings.putAll(otherSettings);
			for (String key : settings.keySet())
				command.add("-C" + key + "=" + settings.get(key));
			command.add(input.getAbsolutePath());
			command.add(output.getAbsolutePath());
	
			logger.debug("liblouisutdml conversion:\n" + Strings.join(command, "\n\t"));
			
			ProcessBuilder builder = new ProcessBuilder(command);
			builder.directory(tempDir);
			Process process = builder.start();
		
			if (process.waitFor() != 0) {
				BufferedReader stderr = new BufferedReader(new InputStreamReader(process.getErrorStream()));
				List<String> error = new ArrayList<String>();
				for (String line = stderr.readLine(); line != null; line = stderr.readLine())
					error.add(line);
				stderr.close();
				if (!error.isEmpty())
					throw new RuntimeException(Strings.join(error, "\n"));
				else
					throw new RuntimeException("What happened?"); }}
			
		catch (Exception e) {
			logger.error("Error during liblouisutdml conversion");
			throw new RuntimeException("Liblouisutdml error", e); }
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisutdmlProcessBuilderImpl.class);
}
