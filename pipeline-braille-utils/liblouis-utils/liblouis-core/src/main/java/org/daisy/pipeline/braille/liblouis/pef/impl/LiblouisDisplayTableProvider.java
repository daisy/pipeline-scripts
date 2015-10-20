package org.daisy.pipeline.braille.liblouis.pef.impl;

import java.net.URI;
import java.util.Map;
import java.util.Set;

import com.google.common.base.Function;
import com.google.common.base.Optional;
import static com.google.common.base.Predicates.notNull;
import com.google.common.collect.ImmutableSet;
import static com.google.common.collect.Iterables.filter;
import static com.google.common.collect.Iterables.transform;

import org.daisy.braille.api.factory.AbstractFactory;
import org.daisy.braille.api.table.BrailleConverter;
import org.daisy.braille.api.table.Table;

import static org.daisy.pipeline.braille.css.Query.serializeQuery;
import org.daisy.pipeline.braille.liblouis.impl.LiblouisTableJnaImplProvider;
import org.daisy.pipeline.braille.liblouis.impl.LiblouisTableJnaImplProvider.LiblouisTableJnaImpl;
import org.daisy.pipeline.braille.pef.AbstractTableProvider;
import org.daisy.pipeline.braille.pef.TableProvider;

import org.liblouis.Translator;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

@Component(
	name = "org.daisy.pipeline.braille.liblouis.pef.impl.LiblouisDisplayTableProvider",
	service = {
		TableProvider.class,
		org.daisy.braille.api.table.TableProvider.class
	}
)
public class LiblouisDisplayTableProvider extends AbstractTableProvider {
	
	private LiblouisTableJnaImplProvider tableProvider;
	
	@Reference(
		name = "LiblouisTableJnaImplProvider",
		unbind = "unbindLiblouisTableJnaImplProvider",
		service = LiblouisTableJnaImplProvider.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindLiblouisTableJnaImplProvider(LiblouisTableJnaImplProvider provider) {
		tableProvider = provider;
	}
	
	protected void unbindLiblouisTableJnaImplProvider(LiblouisTableJnaImplProvider provider) {
		tableProvider = null;
	}
	
	private static Set<String> supportedFeatures = ImmutableSet.of("liblouis-table", "locale");
	
	/**
	 * Recognized features:
	 *
	 * - id: Matches liblouis display tables by their fully qualified table identifier. Not
	 *     compatible with other features.
	 *
	 * - liblouis-table: A liblouis table is a URI that can be either a file name, a file path
	 *     relative to a registered tablepath, an absolute file URI, or a fully qualified table
	 *     identifier.
	 *
	 * - locale: Matches only liblouis display tables with that locale.
	 *
	 * All matches tables must consist of a single file that ends with ".dis".
	 */
	protected Iterable<Table> get(Map<String,Optional<String>> query) {
		for (String feature : query.keySet())
			if (!supportedFeatures.contains(feature))
				return empty;
		return filter(
			transform(
				tableProvider.get(serializeQuery(query)),
				new Function<LiblouisTableJnaImpl,Table>() {
					public Table apply(LiblouisTableJnaImpl table) {
						URI[] subTables = table.asURIs();
						if (subTables.length == 1)
							if (subTables[0].toString().endsWith(".dis"))
								return new LiblouisDisplayTable(table.getTranslator());
						return null; }}),
			notNull());
	}
	
	private final static Iterable<Table> empty = Optional.<Table>absent().asSet();
	
	@SuppressWarnings("serial")
	private static class LiblouisDisplayTable extends AbstractFactory implements Table {
		
		final Translator table;
		
		private LiblouisDisplayTable(Translator table) {
			super("", "", table.getTable());
			this.table = table;
		}
		
		public BrailleConverter newBrailleConverter() {
			return new LiblouisDisplayTableBrailleConverter(table);
		}
		
		public void setFeature(String key, Object value) {
			throw new IllegalArgumentException("Unknown feature: " + key);
		}
		
		public Object getFeature(String key) {
			throw new IllegalArgumentException("Unknown feature: " + key);
		}
		
		public Object getProperty(String key) {
			return null;
		}
	}
}
