package org.daisy.pipeline.braille.liblouis;

import java.net.URI;

import com.google.common.base.Splitter;
import com.google.common.collect.Iterables;

import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;

public class LiblouisTable {
	
	private final URI[] table;
	
	public LiblouisTable(URI[] table) {
		this.table = table;
	}
	public LiblouisTable(String table) {
		this(tokenizeTable(table));
	}
	
	public URI[] asURIs() {
		return table;
	}
	
	@Override
	public String toString() {
		return serializeTable(table);
	}
	
	public static URI[] tokenizeTable(String table) {
		return Iterables.toArray(
			Iterables.<String,URI>transform(
				Splitter.on(',').split(table),
				asURI),
			URI.class);
	}
	
	public static String serializeTable(URI[] table) {
		return join(table, ",");
	}
}
