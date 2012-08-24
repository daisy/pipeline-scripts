package org.daisy.pipeline.liblouis.internal;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.Collection;

public class LiblouisClassLoader extends JarClassLoader {
	
	public LiblouisClassLoader(Collection<URL> jarURLs, Collection<URL> nativeURLs, File unpackDirectory) {
		
		super(jarURLs);
		
		try {
			
			String liblouisPath = null;
			String liblouisutdmlPath = null;
			
			for (URL url : nativeURLs) {
				String urlString = url.toExternalForm();
				String fileName = urlString.substring(urlString.lastIndexOf('/')+1, urlString.length());
				File file = new File(unpackDirectory.getAbsolutePath() + File.separator + fileName);
				if (!file.exists()) {
					System.out.println("Unpacking " + fileName + " ...");
					try {
						unpack(url, file);
						if (!fileName.endsWith(".dll")) chmod775(file);
					} catch (Exception e) {
						throw new RuntimeException(
								"Exception occured during unpacking of file '" + fileName + "'", e);
					}
				}
				if (fileName.startsWith("liblouis.")) {
					liblouisPath = file.getAbsolutePath();
				} else if (fileName.startsWith("liblouisutdml.")) {
					liblouisutdmlPath = file.getAbsolutePath();
				}
			}
			
			Method loadLibrary = loadClass("org.liblouis.liblouisutdml")
					.getMethod("loadLibrary", String.class, String.class);
			loadLibrary.invoke(null, liblouisPath, liblouisutdmlPath);
			
			Method addSearchPath = loadClass("com.sun.jna.NativeLibrary")
					.getMethod("addSearchPath", String.class, String.class);
			addSearchPath.invoke(null, "louis", unpackDirectory.getAbsolutePath());
			
			System.out.println("Loaded liblouis native libraries");
			
		} catch (Exception e) {
			throw new RuntimeException("Failed to load liblouis native libraries", e);
		}
	}
	
	public void finalize() {
		System.out.println("Unloaded liblouis native libraries");
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
