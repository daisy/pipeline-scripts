package org.daisy.pipeline.liblouis.internal;

import java.io.File;
import java.util.List;
import java.util.Map;

import org.daisy.pipeline.liblouis.Liblouisutdml;

public class LiblouisutdmlRuntimeExecImpl implements Liblouisutdml {
	
	public void translateFile(
			List<String> configFiles,
			List<String> semanticFiles,
			List<String> tables,
			Map<String,String> otherSettings,
			File input,
			File output,
			File configPath,
			File tempDir) {
		
		throw new UnsupportedOperationException("Not implemented yet");
	}
}
