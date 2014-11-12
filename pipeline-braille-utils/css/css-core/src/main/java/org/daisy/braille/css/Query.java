package org.daisy.braille.css;

import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;

public abstract class Query {
		
	private static final String IDENT_RE = "(?:\\p{L}|_)(?:\\p{L}|_|-)*";
	private static final String STRING_RE = "'[^']*'|\"[^\"]*\"";
	private static final String INTEGER_RE = "0|-?[1-9][0-9]*";
	private static final Pattern VALUE_RE = Pattern.compile(
		"(?<ident>" + IDENT_RE + ")|(?<string>" + STRING_RE + ")|(?<integer>" + INTEGER_RE + ")"
		);
	private static final Pattern FEATURE_RE = Pattern.compile(
		"\\(\\s*(?<key>" + IDENT_RE+ ")(?:\\s*\\:\\s*(?<value>" + VALUE_RE.pattern() + "))?\\s*\\)"
		);
	private static final Pattern FEATURES_RE = Pattern.compile(
		"\\s*(?:" + FEATURE_RE.pattern() + "\\s*)*"
		);
		
	public static Map<String,Optional<String>> parseQuery(String query) {
		if (FEATURES_RE.matcher(query).matches()) {
			ImmutableMap.Builder<String,Optional<String>> b
				= ImmutableMap.<String,Optional<String>>builder();
			Matcher m = FEATURE_RE.matcher(query);
			while(m.find()) {
				String key = m.group("key");
				String value = m.group("value");
				if (value != null) {
					Matcher m2 = VALUE_RE.matcher(value);
					if (!m2.matches())
						throw new RuntimeException("Coding error");
					String ident = m2.group("ident");
					String string = m2.group("string");
					String integer = m2.group("integer");
					if (ident != null)
						value = ident;
					else if (string != null && !string.equals(""))
						value = string.substring(1,string.length()-1);
					else if (integer != null && !integer.equals(""))
						value = integer;
					else
						throw new RuntimeException("Coding error"); }
				b.put(key, Optional.<String>fromNullable(value)); }
			return b.build(); }
		throw new RuntimeException("Could not parse query: " + query);
	}
}
