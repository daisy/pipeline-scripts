package org.daisy.pipeline.braille.liblouis;

import java.net.URL;
import java.util.Map;

import org.daisy.pipeline.braille.BundledTablePath;
import org.daisy.pipeline.braille.Utilities.Files;
import org.osgi.service.component.ComponentContext;

import com.google.common.base.Predicate;
import com.google.common.base.Splitter;

import static org.daisy.pipeline.braille.Utilities.Predicates.matchesGlobPattern;
import static org.daisy.pipeline.braille.Utilities.Files.fileName;

public class LiblouisTablePath extends BundledTablePath {
	
	@Override
	protected void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		super.activate(context, properties);
		lazyUnpack(context);
	}
	
	/* A liblouis table name can be a comma separated list of file names */
	@Override
	protected boolean includes(String table) {
		try {
			URL firstTable = null;
			for(String t : Splitter.on(',').split(table)) {
				if (firstTable == null) {
					firstTable = Files.resolve(identifier, t);
					if (isLibhyphenTable.apply(fileName(firstTable)))
						return false; }
				else
					t = Files.relativize(identifier, Files.resolve(firstTable, t));
				if (!super.includes(t))
					return false; }
			return (firstTable != null); }
		catch (Exception e) {}
		return false;
	}
		
	private static final Predicate<String> isLibhyphenTable = matchesGlobPattern("hyph_*.dic");
	
}
