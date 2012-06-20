package org.liblouis;

import java.util.Arrays;
import java.util.Iterator;
import java.util.List;

public class StringUtils {

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
