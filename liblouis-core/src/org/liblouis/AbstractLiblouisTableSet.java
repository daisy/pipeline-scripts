package org.liblouis;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.Enumeration;

import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

public abstract class AbstractLiblouisTableSet implements LiblouisTableSet {

	private File path = null;

	@Override
	public File getPath() {
		return path;
	}

	@Override
	public File[] listTables() {
		return getPath().listFiles();
	}

	public void start(ComponentContext context) {
		path = context.getBundleContext().getDataFile("tables");
		if (!path.exists()) {
			path.mkdir();
			Bundle bundle = context.getBundleContext().getBundle();
			if (bundle.getEntry("/tables") != null) {
				Enumeration<String> tablePaths = bundle.getEntryPaths("/tables");
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
