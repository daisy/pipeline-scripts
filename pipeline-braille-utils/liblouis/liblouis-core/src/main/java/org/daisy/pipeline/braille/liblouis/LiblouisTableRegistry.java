package org.daisy.pipeline.braille.liblouis;

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
import com.google.common.base.Splitter;

public class LiblouisTableRegistry extends TableRegistry<LiblouisTablePath> implements LiblouisTableLookup, LiblouisTableResolver {
	
	@Override
	public URL resolve(String resource) {
		URL resolved = super.resolve(resource);
		if (resolved == null)
			resolved = fileSystem.resolve(resource);
		return resolved;
	}
	
	private final ResourcePath fileSystem = new LiblouisFileSystem();
	
	private static class LiblouisFileSystem implements ResourcePath {

		private static final URL identifier = asURL("file:");
		
		private static final Predicate<String> isLiblouisTable = matchesGlobPattern("*.{dis,ctb,cti,ctu,dic}");
		private static final Predicate<String> isLibhyphenTable = matchesGlobPattern("hyph_*.dic");
		
		public URL getIdentifier() {
			return identifier;
		}
		
		/* A liblouis table name can be a comma separated list of file names */
		public URL resolve(String resource) {
			try {
				URL firstTable = null;
				File table = null;
				for(String t : Splitter.on(',').split(resource)) {
					if (table == null) {
						firstTable = Files.resolve(identifier, t);
						table = asFile(firstTable);
						if (isLibhyphenTable.apply(fileName(table)))
							return null; }
					else
						table = asFile(Files.resolve(firstTable, t));
					if (!(table.exists() && isLiblouisTable.apply(fileName(table))))
						return null; }
				if (firstTable != null)
					return Files.resolve(identifier, resource); }
			catch (Exception e) {}
			return null;
		}
	}
}
