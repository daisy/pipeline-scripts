package org.daisy.pipeline.braille.liblouis.impl;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.daisy.pipeline.braille.Utilities.Files.asFile;
import static org.daisy.pipeline.braille.Utilities.Strings.join;

import org.daisy.pipeline.braille.BundledNativePath;
import org.daisy.pipeline.braille.ResourceResolver;
import org.daisy.pipeline.braille.Utilities.VoidFunction;
import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;
import org.daisy.pipeline.braille.liblouis.Liblouisutdml;
import org.daisy.pipeline.braille.liblouis.LiblouisutdmlConfigResolver;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisutdmlProcessBuilderImpl implements Liblouisutdml {
	
	private File file2brl;
	private BundledNativePath nativePath;
	private ResourceResolver tableResolver;
	private ResourceResolver configResolver;
	
	protected void activate() {
		logger.debug("Loading liblouisutdml service");
	}
	
	protected void deactivate() {
		logger.debug("Unloading liblouisutdml service");
	}
	
	protected void bindExecutable(BundledNativePath nativePath) {
		if (this.nativePath == null) {
			URL executablePath = nativePath.lookup("file2brl");
			if (executablePath != null) {
				file2brl = asFile(nativePath.resolve(executablePath));
				this.nativePath = nativePath;
				logger.debug("Registering file2brl executable: " + executablePath); }}
	}
	
	protected void unbindExecutable(BundledNativePath nativePath) {
		if (nativePath.equals(this.nativePath)) {
			this.nativePath = null;
			file2brl = null; }
	}
	
	protected void bindTableResolver(LiblouisTableResolver tableResolver) {
		this.tableResolver = tableResolver;
	}
	
	protected void unbindTableResolver(LiblouisTableResolver path) {
		this.tableResolver = null;
	}
	
	protected void bindConfigResolver(LiblouisutdmlConfigResolver configResolver) {
		this.configResolver = configResolver;
	}
	
	protected void unbindTableResolver(LiblouisutdmlConfigResolver path) {
		this.configResolver = null;
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
			URL configPath,
			File tempDir) {
		
		try {
			
			File configPathFile = null;
			if (configPath == null)
				configPathFile = tempDir;
			else {
				URL resolvedConfigPath = configResolver.resolve(configPath);
				if (resolvedConfigPath == null)
					throw new RuntimeException("Liblouisutdml config path " + configPath + " could not be resolved");
				configPathFile = asFile(resolvedConfigPath); }
			
			if (!Arrays.asList(configPathFile.list()).contains("liblouisutdml.ini"))
				throw new RuntimeException("liblouisutdml.ini must be placed in " + configPathFile);
			if (configFiles != null)
				configFiles.remove("liblouisutdml.ini");
			
			List<String> command = new ArrayList<String>();
			
			command.add(file2brl.getAbsolutePath());
			command.add("-f");
			command.add(configPathFile.getAbsolutePath() + File.separator +
					(configFiles != null ? join(configFiles, ",") : ""));
			Map<String,String> settings = new HashMap<String,String>();
			if (semanticFiles != null && semanticFiles.size() > 0)
				settings.put("semanticFiles", join(semanticFiles, ","));
			if (table != null) {
				URL resolvedTable = tableResolver.resolve(table);
				if (resolvedTable == null)
					throw new RuntimeException("Liblouis table " + table + " could not be resolved");
				String tablePath = "\"" + asFile(resolvedTable).getCanonicalPath() + "\"";
				settings.put("literaryTextTable", tablePath);
				settings.put("editTable", tablePath); }
			if (otherSettings != null)
				settings.putAll(otherSettings);
			for (String key : settings.keySet())
				command.add("-C" + key + "=" + settings.get(key));
			command.add(input.getAbsolutePath());
			command.add(output.getAbsolutePath());
			
			logger.debug("\n" + join(command, "\n\t"));
			
			ProcessBuilder builder = new ProcessBuilder(command);
			builder.directory(tempDir);
			
			// Hack to make sure tables on configPath are found
			if (!configPathFile.equals(tempDir))
				builder.environment().put("LOUIS_TABLEPATH", configPathFile.getCanonicalPath());
			
			Process process = builder.start();
			
			new StreamReaderThread(
					process.getErrorStream(),
					new VoidFunction<List<String>>() {
						public void apply(List<String> error) {
							logger.debug("\nstderr:\n\t" + join(error, "\n\t")); }}).start();
			
			int exitValue = process.waitFor();
			logger.debug("\nexit value: " + exitValue);
			if (exitValue != 0)
				throw new RuntimeException("liblouisutdml exited with value " + exitValue); }
			
		catch (Exception e) {
			throw new RuntimeException("Error during liblouisutdml conversion", e); }
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisutdmlProcessBuilderImpl.class);
	
	private static class StreamReaderThread extends Thread {
		
		private InputStream stream;
		private VoidFunction<List<String>> callback;
		
		public StreamReaderThread(InputStream stream, VoidFunction<List<String>> callback) {
			this.stream = stream;
			this.callback = callback;
		}
		
		@Override
		public void run() {
			try {
				BufferedReader reader = new BufferedReader(new InputStreamReader(stream));
				List<String> result = new ArrayList<String>();
				String line = null;
				while ((line = reader.readLine()) != null) result.add(line);
				if (callback != null)
					callback.apply(result); }
			catch (IOException e) {
				throw new RuntimeException(e); }
		}
	}
}
