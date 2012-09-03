package org.daisy.pipeline.liblouis.internal;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import org.daisy.pipeline.liblouis.LiblouisTableRegistry;
import org.daisy.pipeline.liblouis.Liblouisutdml;
import org.daisy.pipeline.liblouis.Utilities.Files;
import org.daisy.pipeline.liblouis.Utilities.Strings;
import org.daisy.pipeline.liblouis.Utilities.VoidFunction;

public class LiblouisutdmlRuntimeExecImpl implements Liblouisutdml {
	
	private File file2brl;
	private String tablePath = "";
	
	public LiblouisutdmlRuntimeExecImpl(Iterable<URL> nativeURLs, File unpackDirectory, LiblouisTableRegistry tableRegistry) {
		Iterator<URL> nativeURLsIterator = nativeURLs.iterator();
		try {
			URL file2brlURL = nativeURLsIterator.next();
			file2brl = new File(unpackDirectory.getAbsolutePath() + File.separator + Files.fileName(file2brlURL));
			if (!unpackDirectory.exists()) unpackDirectory.mkdirs();
			Files.unpack(file2brlURL, file2brl); }
		catch (NoSuchElementException e) {
			throw new IllegalArgumentException("Argument nativeURLs must not be empty"); }
		for (File file : Files.unpack(nativeURLsIterator, unpackDirectory)) {
			if (!file.getName().matches(".*\\.(dll|exe)$")) Files.chmod775(file); }
		tableRegistry.onLouisTablePathUpdate(new VoidFunction<String>() {
			public void apply(String tablePath) {
				LiblouisutdmlRuntimeExecImpl.this.tablePath = tablePath; }});
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

		List<String> command = new ArrayList<String>();
		
		command.add(file2brl.getAbsolutePath());
		command.add("-f");
		command.add(configPath.getAbsolutePath() + File.separator +
				(configFiles != null ? Strings.join(configFiles, ",") : ""));
		Map<String,String> settings = new HashMap<String,String>();
		if (semanticFiles != null)
			settings.put("semanticFiles", Strings.join(semanticFiles, ","));
		if (tables != null)
			settings.put("literaryTextTable", Strings.join(tables, ","));
		if (otherSettings != null)
			settings.putAll(otherSettings);
		for (String key : settings.keySet())
			command.add("-C" + key + "=" + settings.get(key));
		command.add(input.getAbsolutePath());
		command.add(output.getAbsolutePath());

		System.out.println(Strings.join(command, "\n\t"));

		try {
			
			ProcessBuilder builder = new ProcessBuilder(command);
			builder.environment().put("LOUIS_TABLEPATH", tablePath);
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
			e.printStackTrace();
			throw new RuntimeException("Liblouisutdml error", e); }
	}
}
