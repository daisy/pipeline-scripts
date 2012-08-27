package org.daisy.pipeline.liblouis;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

public abstract class Utilities {

	public static interface Predicate<T> {
		boolean test(T object);
	}
	
	public static abstract class Predicates {
		
		public static <T> Predicate<T> matchesPattern(final String regex) {
			return new Predicate<T>() {
				private Pattern pattern = Pattern.compile(regex);
				public boolean test(T object) {
					return pattern.matcher(object.toString()).matches();
				}
			};
		}
		
		public static <T> Predicate<T> not(final Predicate<T> predicate) {
			return new Predicate<T>() {
				public boolean test(T object) {
					return !predicate.test(object);
				}
			};
		}
	}
	
	public static abstract class Collections {
		public static <T> Collection<T> filter(Collection<T> collection, Predicate<T> predicate) {
			Collection<T> result = new ArrayList<T>();
			for (T t: collection) {
				if (predicate.test(t)) result.add(t);
			}
			return result;
		}
	}

	public static abstract class OS {
		public static boolean isWindows() {
			return System.getProperty("os.name").toLowerCase().startsWith("windows");
		}
	}
	
	public static abstract class Strings {
		
		public static String join(List<String> strings, String separator) {
			String joinedString = "";
			Iterator<String> iterator = strings.iterator();
			if(iterator.hasNext()) {
				joinedString += iterator.next();
			}
			while(iterator.hasNext()) {
				joinedString += separator;
				joinedString += iterator.next();
			}
			return joinedString;
		}

		public static String join(String[] strings, String separator) {
			return join(Arrays.asList(strings), separator);
		}
	}
	
	public static abstract class Files {
		
		public static boolean unpack(URL url, File file) {
			if (file.exists()) return false;
			System.out.println("Unpacking " + file.getName() + " ...");
			try {
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
				return true;
			} catch (Exception e) {
				throw new RuntimeException(
						"Exception occured during unpacking of file '" + file.getName() + "'", e);
			}
		}
		
		public static Collection<File> unpack(Collection<URL> urls, File directory) {
			if (!directory.exists()) directory.mkdirs();
			Collection<File> files = new ArrayList<File>();
			for (URL url : urls) {
				String urlString = url.toExternalForm();
				String fileName = urlString.substring(urlString.lastIndexOf('/')+1, urlString.length());
				File file = new File(directory.getAbsolutePath() + File.separator + fileName);
				if (unpack(url, file)) files.add(file);
			}
			return files;
		}

		public static void chmod775(File file) {
			try {
				Runtime.getRuntime().exec(new String[] { "chmod", "775", file.getAbsolutePath() }).waitFor();
			} catch (Exception e) {
				throw new RuntimeException(
						"Exception occured during chmodding of file '" + file.getName() + "'", e);
			}
		}
	}
}
