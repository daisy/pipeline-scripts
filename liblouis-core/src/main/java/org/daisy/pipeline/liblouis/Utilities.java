package org.daisy.pipeline.liblouis;

import com.google.common.base.Predicate;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class Utilities {
	
    public static interface VoidFunction<T> {
		public void apply(T object);
	}

    public static interface Function2<T1,T2,T3> {
		public T3 apply(T1 object1, T2 object2);
	}
	
	public static abstract class Predicates {
		public static <T> Predicate<T> matchesPattern(final String regex) {
			return new Predicate<T>() {
				private Pattern pattern = Pattern.compile(regex);
				public boolean apply(T object) {
					return pattern.matcher(object.toString()).matches(); }};
		}
	}
	
	public static abstract class Iterators {
		public static <T> T reduce(Iterator<T> iterator, Function2<? super T,? super T,T> function) {
			T result = null;
			if(iterator.hasNext()) result = iterator.next();
			while(iterator.hasNext()) result = function.apply(result, iterator.next());
			return result;
		}
	}

	public static abstract class OS {
		
		public static enum Family { LINUX, MAC, WINDOWS }
		
		public static Family getFamily() {
			String name = System.getProperty("os.name").toLowerCase();
			if (name.startsWith("windows"))
				return Family.WINDOWS;
			else if (name.startsWith("mac"))
				return Family.MAC;
			else
				return Family.LINUX;
		}
		
		public static boolean isWindows() {
			return getFamily() == Family.WINDOWS;
		}
		
		public static boolean isMac() {
			return getFamily() == Family.MAC;
		}
		
		public static String getArch() {
			return System.getProperty("os.arch").toLowerCase();
		}
	}
	
	public static abstract class Strings {
		
		public static String join(Iterator<String> strings, final String separator) {
			return Iterators.<String>reduce(
				strings,
				new Function2<String,String,String>() {
					public String apply(String s1, String s2) {
						return s1 + separator + s2; }});
		}
		
		public static String join(Iterable<String> strings, final String separator) {
			return join(strings.iterator(), separator);
		}
		
		public static String join(String[] strings, String separator) {
			return join(Arrays.asList(strings), separator);
		}
	}
	
	public static abstract class Files {
		
		public static boolean unpack(URL url, File file) {
			if (file.exists()) return false;
			logger.debug("Unpacking file {} ...", file.getName());
			try {
				file.createNewFile();
				FileOutputStream writer = new FileOutputStream(file);
				url.openConnection();
				InputStream reader = url.openStream();
				byte[] buffer = new byte[153600];
				int bytesRead = 0;
				while ((bytesRead = reader.read(buffer)) > 0) {
					writer.write(buffer, 0, bytesRead);
					buffer = new byte[153600]; }
				writer.close();
				reader.close();
				return true; }
			catch (Exception e) {
				logger.error("Exception occured during unpacking of file {}", file.getName());
				throw new RuntimeException(
						"Exception occured during unpacking of file '" + file.getName() + "'", e); }
		}
		
		public static Iterable<File> unpack(Iterator<URL> urls, File directory) {
			if (!directory.exists()) directory.mkdirs();
			Collection<File> files = new ArrayList<File>();
			while(urls.hasNext()) {
				URL url = urls.next();
				File file = new File(directory.getAbsolutePath() + File.separator + fileName(url));
				if (unpack(url, file)) files.add(file); }
			return files;
		}

		public static String fileName(URL url) {
			String urlString = url.toExternalForm();
			return urlString.substring(urlString.lastIndexOf('/')+1);
		}

		public static void chmod775(File file) {
			try {
				Runtime.getRuntime().exec(new String[] { "chmod", "775", file.getAbsolutePath() }).waitFor(); }
			catch (Exception e) {
				logger.error("Exception occured during chmodding of file {}", file.getName());
				throw new RuntimeException(
						"Exception occured during chmodding of file '" + file.getName() + "'", e); }
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(Utilities.class);
}
