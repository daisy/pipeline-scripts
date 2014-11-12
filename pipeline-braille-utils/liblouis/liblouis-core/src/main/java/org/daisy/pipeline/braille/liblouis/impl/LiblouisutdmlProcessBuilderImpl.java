package org.daisy.pipeline.braille.liblouis.impl;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.common.base.Function;
import com.google.common.collect.Iterables;

import org.daisy.pipeline.braille.common.BundledNativePath;
import org.daisy.pipeline.braille.common.ResourceResolver;
import static org.daisy.pipeline.braille.common.util.Files.asFile;
import static org.daisy.pipeline.braille.common.util.Files.isAbsoluteFile;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.common.util.URLs.asURL;

import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;
import org.daisy.pipeline.braille.liblouis.Liblouisutdml;
import org.daisy.pipeline.braille.liblouis.LiblouisutdmlConfigResolver;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisutdmlProcessBuilderImpl implements Liblouisutdml {
	
	private final static boolean LIBLOUISUTDML_EXTERNAL =
		Boolean.getBoolean("org.daisy.pipeline.liblouisutdml.external");
	
	private File file2brl;
	private BundledNativePath nativePath;
	private LiblouisTableResolver tableResolver;
	private ResourceResolver configResolver;
	
	protected void activate() {
		logger.debug("Loading liblouisutdml service");
		if (file2brl == null)
			file2brl = new File("/usr/local/bin/file2brl");
	}
	
	protected void deactivate() {
		logger.debug("Unloading liblouisutdml service");
	}
	
	protected void bindExecutable(BundledNativePath nativePath) {
		if (!LIBLOUISUTDML_EXTERNAL && this.nativePath == null) {
			URI executablePath = Iterables.<URI>getFirst(nativePath.get("file2brl"), null);
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
	
	protected void unbindConfigResolver(LiblouisutdmlConfigResolver path) {
		this.configResolver = null;
	}
	
	/**
	 * {@inheritDoc}
	 */
	public void translateFile(
			List<String> configFiles,
			List<String> semanticFiles,
			URI[] table,
			Map<String,String> otherSettings,
			File input,
			File output,
			URI configPath,
			File tempDir) {
		
		try {
			
			File configPathFile = (configPath != null) ? resolveConfigPath(configPath) : tempDir;
			
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
				String tablePath = "\"" + resolveTable(table) + "\"";
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
					new Function<List<String>,Void>() {
						public Void apply(List<String> error) {
							logger.debug("\nstderr:\n\t" + join(error, "\n\t"));
							return null; }}).start();
			
			int exitValue = process.waitFor();
			logger.debug("\nexit value: " + exitValue);
			if (exitValue != 0)
				throw new RuntimeException("liblouisutdml exited with value " + exitValue); }
			
		catch (Exception e) {
			logger.error("Error during liblouisutdml conversion", e);
			throw new RuntimeException("Error during liblouisutdml conversion", e); }
	}
	
	private String resolveTable(URI[] table) throws IOException {
		File[] resolved = tableResolver.resolveTableList(table, null);
		if (resolved == null)
			throw new RuntimeException("Liblouis table " + table + " could not be resolved");
		String[] files = new String[resolved.length];
		for (int i = 0; i < resolved.length; i++)
			files[i] = resolved[i].getCanonicalPath();
		return join(files, ",");
	}
	
	private File resolveConfigPath(URI configPath) {
		URL resolvedConfigPath = isAbsoluteFile(configPath) ? asURL(configPath) : configResolver.resolve(configPath);
		if (resolvedConfigPath == null)
			throw new RuntimeException("Liblouisutdml config path " + configPath + " could not be resolved");
		return asFile(resolvedConfigPath);
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisutdmlProcessBuilderImpl.class);
	
	private static class StreamReaderThread extends Thread {
		
		private InputStream stream;
		private Function<List<String>,Void> callback;
		
		public StreamReaderThread(InputStream stream, Function<List<String>,Void> callback) {
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
