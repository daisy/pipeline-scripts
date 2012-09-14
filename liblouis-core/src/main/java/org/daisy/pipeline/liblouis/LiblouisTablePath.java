package org.daisy.pipeline.liblouis;

import org.daisy.pipeline.braille.UnpackedTablePath;
import org.daisy.pipeline.braille.Utilities.Predicates;

import com.google.common.base.Splitter;

public class LiblouisTablePath extends UnpackedTablePath {
	
	public LiblouisTablePath() {
		tableNameFilter = Predicates.fileHasExtension("(cti|ctb|utb|uti|dis)");
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
