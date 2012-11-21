package org.daisy.pipeline.braille.liblouis;

import org.daisy.pipeline.braille.UnpackedTablePath;

import com.google.common.base.Splitter;

public class LiblouisTablePath extends UnpackedTablePath {
	
	public LiblouisTablePath() {
		super();
	}
	
	/* A liblouis table name can be a comma separated list of file names */
	@Override
	public boolean hasTable(String tableName) {
		if ("".equals(tableName))
			return false;
		for(String t : Splitter.on(',').split(tableName))
			if (!tableNames.contains(t)) return false;
		return true;
	}
}
