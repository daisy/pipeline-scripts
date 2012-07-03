package org.daisy.pipeline.liblouis;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.Enumeration;

import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

import com.sun.jna.NativeLibrary;

public class Activator {

	private static File nativePath = null;

	public static File getNativePath() {
		return nativePath;
	}

	@SuppressWarnings("unchecked")
	public void activate(ComponentContext context) {
		nativePath = context.getBundleContext().getDataFile("native");
		if (!nativePath.exists()) {
			nativePath.mkdir();
			Bundle bundle = context.getBundleContext().getBundle();
			String directory = null;
			switch (OSUtils.getOSType()) {
				case MAC:
					directory = "/native/mac";
					break;
				case LINUX:
					directory = "/native/linux";
					break;
				default:
					throw new RuntimeException(
							"No liblouis binaries for platform " + OSUtils.getOSType().name());
			}
			if (bundle.getEntry(directory) == null) {
				throw new RuntimeException(directory + " doesn't exist" );
			}
			Enumeration<String> paths = bundle.getEntryPaths(directory);
			if (paths != null) {
				System.out.println("Unpacking liblouis binaries...");
				while (paths.hasMoreElements()) {
					URL tableURL = bundle.getEntry(paths.nextElement());
					String url = tableURL.toExternalForm();
					String fileName = url.substring(url.lastIndexOf('/')+1, url.length());
					File file = new File(nativePath.getAbsolutePath() + File.separator + fileName);
					try {
						unpack(tableURL, file);
						chmod775(file);
						System.out.println(fileName);
					} catch (Exception e) {
						throw new RuntimeException(
								"Exception occured during unpacking of file '" + fileName + "'", e);
					}
				}
			}
		}
		NativeLibrary.addSearchPath("louis", nativePath.getAbsolutePath());
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

	private static void chmod775(File file) throws Exception {
		Runtime.getRuntime().exec(new String[] { "chmod", "775", file.getAbsolutePath() }).waitFor();
	}
}
