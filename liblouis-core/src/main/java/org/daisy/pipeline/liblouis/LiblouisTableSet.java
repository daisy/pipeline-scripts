package org.daisy.pipeline.liblouis;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.Enumeration;
import java.util.Map;

import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

public class LiblouisTableSet {

	private static final String IDENTIFIER = "identifier";
	private static final String DIRECTORY = "directory";
	private static final String MANIFEST = "manifest";

	private String identifier = null;
	private File path = null;
	private URL manifest = null;

	public String getIdentifier() {
		return identifier;
	}

	public File getPath() {
		return path;
	}

	public URL getManifest() {
		return manifest;
	}

	@SuppressWarnings("unchecked")
	public void activate(ComponentContext context, Map<?, ?> properties) {
		if (properties.get(IDENTIFIER) == null
				|| properties.get(IDENTIFIER).toString().isEmpty()) {
			throw new IllegalArgumentException(IDENTIFIER + " property must not be empty");
		}
		if (properties.get(DIRECTORY) == null
				|| properties.get(DIRECTORY).toString().isEmpty()) {
			throw new IllegalArgumentException(DIRECTORY + " property must not be empty");
		}
		identifier = properties.get(IDENTIFIER).toString();
		String directory = properties.get(DIRECTORY).toString();
		path = context.getBundleContext().getDataFile("tables");
		Bundle bundle = context.getBundleContext().getBundle();
		if (!path.exists()) {
			path.mkdir();
			if (bundle.getEntry(directory) == null) {
				throw new IllegalArgumentException("Table directory at location " + directory + " could not be found");
			}
			Enumeration<String> tablePaths = bundle.getEntryPaths(directory);
			if (tablePaths != null) {
				System.out.println("Unpacking liblouis tables...");
				while (tablePaths.hasMoreElements()) {
					URL tableURL = bundle.getEntry(tablePaths.nextElement());
					String url = tableURL.toExternalForm();
					String fileName = url.substring(url.lastIndexOf('/')+1, url.length());
					File file = new File(path.getAbsolutePath() + File.separator + fileName);
					try {
						unpack(tableURL, file);
						System.out.println(fileName);
					} catch (Exception e) {
						System.out.println("Exception occured during unpacking of file '" + fileName + "'");
						e.printStackTrace();
					}
				}
			}
		}
		if (properties.get(MANIFEST) != null) {
			String manifestPath = properties.get(MANIFEST).toString();
			manifest = bundle.getEntry(manifestPath);
			if (manifest == null) {
				throw new IllegalArgumentException("Manifest at location " + manifestPath + " could not be found");
			}
		}
	}

	private static void unpack(URL url, File file) throws Exception {
		file.createNewFile();
		FileOutputStream writer = new FileOutputStream(file);
		url.openConnection();
		InputStream reader = url.openStream();
		byte[] buffer = new byte[153600];
		int bytesRead = 0;
		while ((bytesRead = reader.read(buffer)) > 0) {
			writer.write(buffer, 0, bytesRead);
			buffer = new byte[153600];
		}
		writer.close();
		reader.close();
	}
}
