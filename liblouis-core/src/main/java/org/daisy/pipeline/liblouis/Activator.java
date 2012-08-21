package org.daisy.pipeline.liblouis;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.net.URL;
import java.util.Enumeration;

import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

import com.sun.jna.NativeLibrary;
import com.sun.jna.Platform;

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
			switch(Platform.getOSType()) {
				case Platform.MAC:
					if (Platform.is64Bit()) {
						directory = "/native/darwin-x86_64";
					} else {
						directory = "/native/darwin-i386";
					}
					break;
				case Platform.LINUX:
					directory = "/native/linux";
					break;
				case Platform.WINDOWS:
					if (Platform.is64Bit()) {
						directory = "/native/windows-x86_64";
					} else {
						directory = "/native/windows-i386";
					}
					break;
				default:
					throw new RuntimeException("No liblouis binaries for this platform");
			}
			if (bundle.getEntry(directory) == null) {
				throw new RuntimeException(directory + " doesn't exist" );
			}
			Enumeration<String> paths = bundle.getEntryPaths(directory);
			if (paths != null) {
				System.out.println("Unpacking liblouis binaries...");
				while (paths.hasMoreElements()) {
					URL binaryURL = bundle.getEntry(paths.nextElement());
					String url = binaryURL.toExternalForm();
					String fileName = url.substring(url.lastIndexOf('/')+1, url.length());
					File file = new File(nativePath.getAbsolutePath() + File.separator + fileName);
					try {
						unpack(binaryURL, file);
						if (Platform.getOSType() != Platform.WINDOWS) {
							chmod775(file);
						}
						System.out.println(fileName);
					} catch (Exception e) {
						throw new RuntimeException(
								"Exception occured during unpacking of file '" + fileName + "'", e);
					}
				}
			}
		}

		try {

			switch(Platform.getOSType()) {
				case Platform.MAC:
					System.load(nativePath.getAbsolutePath() + "/liblouisutdml.dylib");
					break;
				case Platform.LINUX:
					System.load(nativePath.getAbsolutePath() + "/liblouisutdml.so.6");
					break;
				case Platform.WINDOWS:
					// Hack to set java.library.path programmatically
					System.setProperty("java.library.path", nativePath.getAbsolutePath());
					Field fieldSysPath = ClassLoader.class.getDeclaredField("sys_paths");
					fieldSysPath.setAccessible(true);
					fieldSysPath.set(null, null);
					System.load(nativePath.getAbsolutePath() + "/liblouis.dll");
					System.load(nativePath.getAbsolutePath() + "/liblouisutdml.dll");
					break;
				default:
					throw new RuntimeException("No liblouis binaries for this platform");
			}
			
			NativeLibrary.addSearchPath("louis", nativePath.getAbsolutePath());

		} catch (UnsatisfiedLinkError e) {
			e.printStackTrace();
		} catch (NoSuchFieldException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
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

	private static void chmod775(File file) throws Exception {
		Runtime.getRuntime().exec(new String[] { "chmod", "775", file.getAbsolutePath() }).waitFor();
	}
}
