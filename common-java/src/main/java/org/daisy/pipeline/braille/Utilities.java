package org.daisy.pipeline.braille;

import com.google.common.base.Predicate;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.Locale;
import java.util.StringTokenizer;
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
	
	public static class Pair<T1,T2> {
		public final T1 _1;
		public final T2 _2;
		public Pair(T1 _1, T2 _2) {
			this._1 = _1;
			this._2 = _2;
		}
	}
	
	public static abstract class Predicates {
		
		public static <T> Predicate<T> matchesPattern(final String regex) {
			return new Predicate<T>() {
				private Pattern pattern = Pattern.compile(regex);
				public boolean apply(T object) {
					return pattern.matcher(object.toString()).matches(); }};
		}
		
		public static <T> Predicate<T> fileHasExtension(final String extension) {
			return Predicates.<T>matchesPattern(".*\\." + extension + "$");
		}
	}
	
	public static abstract class Iterators {
		
		public static <T1,T2> T1 fold(Iterator<T2> iterator, Function2<? super T1,? super T2,? extends T1> function, T1 seed) {
			T1 result = seed;
			while(iterator.hasNext()) result = function.apply(result, iterator.next());
			return result;
		}
		
		public static<T> T reduce(Iterator<T> iterator, Function2<? super T,? super T,? extends T> function) {
			T seed = iterator.next();
			return Iterators.<T,T>fold(iterator, function, seed);
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
		
		@SuppressWarnings("unchecked")
		public static String join(Iterator<? extends Object> strings, final String separator) {
			if (!strings.hasNext()) return "";
			String seed = strings.next().toString();
			return Iterators.<String,Object>fold(
				(Iterator<Object>)strings,
				new Function2<String,Object,String>() {
					public String apply(String s1, Object s2) {
						return s1 + separator + String.valueOf(s2); }},
				seed);
		}
		
		public static String join(Iterable<?> strings, final String separator) {
			return join(strings.iterator(), separator);
		}
		
		public static String join(Object[] strings, String separator) {
			return join(Arrays.asList(strings), separator);
		}
		
		public static String normalizeSpace(Object object) {
			return String.valueOf(object).replaceAll("\\s+", " ").trim();
		}
	}
	
	public static abstract class Files {
		
		public static boolean unpack(URL url, File file) {
			if (file.exists()) return false;
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
				logger.debug("Unpacking file {} ...", file.getName());
				return true; }
			catch (Exception e) {
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
		
		public static void chmod775(File file) {
			try {
				Runtime.getRuntime().exec(new String[] { "chmod", "775", file.getAbsolutePath() }).waitFor();
				logger.debug("Chmodding file {} ...", file.getName());}
			catch (Exception e) {
				throw new RuntimeException(
						"Exception occured during chmodding of file '" + file.getName() + "'", e); }
		}
		
		public static String fileName(URL url) {
			String urlString = url.toExternalForm();
			return urlString.substring(urlString.lastIndexOf('/')+1);
		}
		
		public static File fileFromURL(URL url) throws RuntimeException {
			try { return new File(url.toURI());}
			catch (URISyntaxException e) { throw new RuntimeException(e); }
		}
		
		public static URL composeURL(URL base, String fileName) throws RuntimeException {
			try {
				String b = base.toExternalForm();
				if (!b.endsWith("/")) b += "/";
				return new URL(b + fileName); }
			catch (MalformedURLException e) { throw new RuntimeException(e); }
		}
		
		public static Pair<URL,String> decomposeURL(URL url) throws RuntimeException {
			try {
				String u = url.toExternalForm();
				int i = u.lastIndexOf('/') + 1;
				return new Pair<URL,String>(new URL(u.substring(0, i)), u.substring(i)); }
			catch (MalformedURLException e) { throw new RuntimeException(e); }
		}
	}
	
	public static abstract class Locales {
		
		public static Locale parseLocale(String locale) {
			StringTokenizer parser = new StringTokenizer(locale, "-_");
			if (parser.hasMoreTokens()) {
				String lang = parser.nextToken();
				if (parser.hasMoreTokens()) {
					String country = parser.nextToken();
					if (parser.hasMoreTokens()) {
						String variant = parser.nextToken();
						return new Locale(lang, country, variant); }
					else
						return new Locale(lang, country); }
				else
					return new Locale(lang); }
			else
				throw new IllegalArgumentException("Locale '" + locale + "' could not be parsed");
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(Utilities.class);
}
