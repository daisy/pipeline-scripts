package org.daisy.pipeline.braille.liblouis.pef;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.base.Function;
import com.google.common.base.Optional;
import com.google.common.base.Predicates;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Iterables;

import static org.daisy.braille.css.Query.serializeQuery;
import org.daisy.braille.table.AbstractTable;
import org.daisy.braille.table.BrailleConverter;
import org.daisy.braille.table.Table;
import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator;
import org.daisy.pipeline.braille.pef.AbstractTableProvider;
import org.daisy.pipeline.braille.pef.TableProvider;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

@Component(
	name = "org.daisy.pipeline.braille.liblouis.pef.LiblouisDisplayTableProvider",
	service = {
		TableProvider.class,
		org.daisy.braille.table.TableProvider.class
	}
)
public class LiblouisDisplayTableProvider extends AbstractTableProvider {
	
	@Reference(
		name = "LiblouisTranslatorProvider",
		unbind = "unbindLiblouisTranslatorProvider",
		service = LiblouisTranslator.Provider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	protected void bindLiblouisTranslatorProvider(LiblouisTranslator.Provider provider) {
		translatorProviders.add(provider);
	}
	
	protected void unbindLiblouisTranslatorProvider(LiblouisTranslator.Provider provider) {
		translatorProviders.remove(provider);
		translatorProvider.invalidateCache();
	}
	
	private List<LiblouisTranslator.Provider> translatorProviders = new ArrayList<LiblouisTranslator.Provider>();
	private CachedProvider<String,LiblouisTranslator> translatorProvider
	= CachedProvider.<String,LiblouisTranslator>newInstance(
		DispatchingProvider.<String,LiblouisTranslator>newInstance(translatorProviders));
	
	private static Set<String> supportedFeatures = ImmutableSet.<String>of("liblouis-table", "locale");
	
	protected Iterable<Table> get(Map<String,Optional<String>> query) {
		for (String feature : query.keySet())
			if (!supportedFeatures.contains(feature))
				return empty;
		return Iterables.<Table>filter(
			Iterables.<LiblouisTranslator,Table>transform(
				translatorProvider.get(serializeQuery(query)),
				new Function<LiblouisTranslator,Table>() {
					public Table apply(LiblouisTranslator table) {
						for (URI t : table.asLiblouisTable().asURIs())
							if (t.toString().endsWith(".dis"))
								return new LiblouisDisplayTable(table);
						return null; }}),
			Predicates.notNull());
	}
	
	private final static Iterable<Table> empty = Optional.<Table>absent().asSet();
	
	private static class LiblouisDisplayTable extends AbstractTable {

		private static final long serialVersionUID = 1L;
		
		final LiblouisTranslator table;
		
		private LiblouisDisplayTable(LiblouisTranslator table) {
			super("", "", table.asLiblouisTable().toString());
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
