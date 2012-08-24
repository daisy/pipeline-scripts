package org.daisy.pipeline.liblouis;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

public abstract class Utilities {

public static abstract class FunctionalUtils {
		
		public static interface Predicate<T> {
			boolean test(T object);
		}
		
		public static <T> Collection<T> filter(Collection<T> collection, Predicate<T> predicate) {
			Collection<T> result = new ArrayList<T>();
			for (T t: collection) {
				if (predicate.test(t)) result.add(t);
			}
			return result;
		}
		
		public static <T> Predicate<T> not(final Predicate<T> predicate) {
			return new Predicate<T>() {
				public boolean test(T object) {
					return !predicate.test(object);
				}
			};
		}
	}

	public static abstract class OSUtils {
		public static boolean isWindows() {
			return System.getProperty("os.name").toLowerCase().startsWith("windows");
		}
	}
	
	public static abstract class StringUtils {
		
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
}
