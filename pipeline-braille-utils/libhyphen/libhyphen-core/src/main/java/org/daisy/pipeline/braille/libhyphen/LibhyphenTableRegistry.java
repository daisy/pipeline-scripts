package org.daisy.pipeline.braille.libhyphen;

import static org.daisy.pipeline.braille.Utilities.Files.asFile;
import static org.daisy.pipeline.braille.Utilities.Files.asURL;
import static org.daisy.pipeline.braille.Utilities.Files.fileName;
import static org.daisy.pipeline.braille.Utilities.Predicates.matchesGlobPattern;

import java.io.File;
import java.net.URL;

import org.daisy.pipeline.braille.ResourcePath;
import org.daisy.pipeline.braille.TableRegistry;
import org.daisy.pipeline.braille.Utilities.Files;

import com.google.common.base.Predicate;

public class LibhyphenTableRegistry extends TableRegistry<LibhyphenTablePath> implements LibhyphenTableLookup, LibhyphenTableResolver {
	
	@Override
	public URL resolve(String resource) {
		URL resolved = super.resolve(resource);
		if (resolved == null)
			resolved = fileSystem.resolve(resource);
		return resolved;
	}
	
	private final ResourcePath fileSystem = new LibhyphenFileSystem();
	
	private static class LibhyphenFileSystem implements ResourcePath {

		private static final URL identifier = asURL("file:");
		
		private static final Predicate<String> isLibhyphenTable = matchesGlobPattern("hyph_*.dic");
		
		public URL getIdentifier() {
			return identifier;
		}
		
		public URL resolve(String resource) {
			try {
				URL url = Files.resolve(identifier, resource);
				File table = asFile(url);
				if (table.exists() && isLibhyphenTable.apply(fileName(table)))
					return url; }
			catch (Exception e) {}
			return null;
		}
	}
}