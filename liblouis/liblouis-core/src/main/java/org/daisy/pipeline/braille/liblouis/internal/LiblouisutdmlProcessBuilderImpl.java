package org.daisy.pipeline.braille.liblouis.internal;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import static org.daisy.pipeline.braille.Utilities.Files.chmod775;
import static org.daisy.pipeline.braille.Utilities.Files.fileFromURL;
import static org.daisy.pipeline.braille.Utilities.Files.fileName;
import static org.daisy.pipeline.braille.Utilities.Files.unpack;
import static org.daisy.pipeline.braille.Utilities.Strings.join;

import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;
import org.daisy.pipeline.braille.liblouis.Liblouisutdml;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisutdmlProcessBuilderImpl implements Liblouisutdml {
	
	private final File file2brl;
	private final LiblouisTableResolver tableResolver;
	
	public LiblouisutdmlProcessBuilderImpl(Iterable<URL> nativeURLs, File unpackDirectory, LiblouisTableResolver tableResolver) {
		try {
			file2brl = new File(unpackDirectory.getAbsolutePath() + File.separator
					+ fileName(nativeURLs.iterator().next())); }
		catch (NoSuchElementException e) {
			throw new IllegalArgumentException("Argument nativeURLs must not be empty"); }
		for (File file : unpack(nativeURLs.iterator(), unpackDirectory)) {
			if (!file.getName().matches(".*\\.(dll|exe)$")) chmod775(file); }
		this.tableResolver = tableResolver;
	}
	
	/**
	 * {@inheritDoc}
	 */
	public void translateFile(
			List<String> configFiles,
			List<String> semanticFiles,
			URL table,
			Map<String,String> otherSettings,
			File input,
			File output,
			File configPath,
			File tempDir) {

		try {
			
			if (configPath == null)
				configPath = tempDir;
			if (!Arrays.asList(configPath.list()).contains("liblouisutdml.ini"))
				throw new RuntimeException("liblouisutdml.ini must be on the configPath");
			if (configFiles != null)
				configFiles.remove("liblouisutdml.ini");
			
			List<String> command = new ArrayList<String>();
			
			command.add(file2brl.getAbsolutePath());
			command.add("-f");
			command.add(configPath.getAbsolutePath() + File.separator +
					(configFiles != null ? join(configFiles, ",") : ""));
			Map<String,String> settings = new HashMap<String,String>();
			if (semanticFiles != null)
				settings.put("semanticFiles", join(semanticFiles, ","));
			String tablePath = fileFromURL(tableResolver.resolveTable(table)).getCanonicalPath();
			settings.put("literaryTextTable", tablePath);
			settings.put("editTable", tablePath);
			if (otherSettings != null)
				settings.putAll(otherSettings);
			for (String key : settings.keySet())
				command.add("-C" + key + "=" + settings.get(key));
			command.add(input.getAbsolutePath());
			command.add(output.getAbsolutePath());
	
			logger.debug("liblouisutdml conversion:\n" + join(command, "\n\t"));
			
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
					throw new RuntimeException(join(error, "\n"));
				else
					throw new RuntimeException("What happened?"); }}
			
		catch (Exception e) {
			throw new RuntimeException("Error during liblouisutdml conversion", e); }
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisutdmlProcessBuilderImpl.class);
}
