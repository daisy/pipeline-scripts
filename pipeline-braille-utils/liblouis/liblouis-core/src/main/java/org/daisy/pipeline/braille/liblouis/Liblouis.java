package org.daisy.pipeline.braille.liblouis;

import java.net.URI;

public interface Liblouis {
	
	/**
	 * Get a LiblouisTranslator for the specified liblouis table. A liblouis
	 * table is a list of URIs that can be either a file name, a file path
	 * relative to a registered tablepath, an absolute file URI, or a fully
	 * qualified table identifier. The tablepath that contains the first
	 * `sub-table' in the list will be used as a `base' for resolving the
	 * subsequent sub-tables.
	 * @throws RuntimeException if a LiblouisTranslator can not be provided
	 * for the specified liblouis table.
	 */
	public LiblouisTranslator get(URI[] table);
	
}
