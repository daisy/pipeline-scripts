package org.daisy.pipeline.braille.tex;

import org.daisy.pipeline.braille.BundledTablePath;

import static org.daisy.pipeline.braille.Utilities.Predicates.fileHasExtension;

public class TexHyphenatorTablePath extends BundledTablePath {
	
	public TexHyphenatorTablePath() {
		tableNameFilter = fileHasExtension("tex");
	}
}
