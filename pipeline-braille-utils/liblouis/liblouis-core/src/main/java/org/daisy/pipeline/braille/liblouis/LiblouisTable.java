package org.daisy.pipeline.braille.liblouis;

import java.net.URI;

import com.google.common.base.Splitter;
import com.google.common.collect.Iterables;

import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;

public class LiblouisTable {
	
	private final URI[] tableList;
	
	public LiblouisTable(URI[] tableList) {
		this.tableList = tableList;
	}
	public LiblouisTable(String tableList) {
		this(tokenizeTableList(tableList));
	}
	
	public URI[] asURIs() {
		return tableList;
	}
	
	@Override
	public String toString() {
		return serializeTableList(tableList);
	}
	
	public static URI[] tokenizeTableList(String tableList) {
		return Iterables.toArray(
			Iterables.<String,URI>transform(
				Splitter.on(',').split(tableList),
				asURI),
			URI.class);
	}
	
	public static String serializeTableList(URI[] tableList) {
		return join(tableList, ",");
	}
}
