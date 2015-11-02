package org.daisy.pipeline.braille.pef.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableSet;
import org.daisy.braille.api.table.Table;

import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import static org.daisy.pipeline.braille.css.Query.serializeQuery;
import org.daisy.pipeline.braille.pef.AbstractTableProvider;
import org.daisy.pipeline.braille.pef.TableProvider;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

@Component(
	name = "org.daisy.pipeline.braille.pef.impl.LocaleTableProvider",
	service = {
		TableProvider.class,
		org.daisy.braille.api.table.TableProvider.class
	}
)
public class LocaleTableProvider extends AbstractTableProvider {
	
	private static Set<String> supportedFeatures = ImmutableSet.of("locale");
	private static Map<String,String> tablesFromLocale = new HashMap<String,String>();
	
	public LocaleTableProvider() {
		tablesFromLocale.put("en", "org.daisy.braille.impl.table.DefaultTableProvider.TableType.EN_US");
		tablesFromLocale.put("nl", "com_braillo.BrailloTableProvider.TableType.BRAILLO_6DOT_031_01");
	}

	/**
	 * Recognized features:
	 *
	 * - locale: A locale that is mapped to a specific table
	 *     that is a sane default for that locale.
	 */
	protected Iterable<Table> get(Map<String,Optional<String>> query) {
		Iterable<Table> tables = empty;
		Optional<String> o;
		if ((o = query.remove("locale")) != null) {
			String identifier = tablesFromLocale.get(o.get());
			if (identifier != null) {
				query.put("id", Optional.of(identifier));
				tables = backingProvider.get(serializeQuery(query)); }}
		return tables;
	}
	
	private final static Iterable<Table> empty = Optional.<Table>absent().asSet();
	
	@Reference(
		name = "TableProvider",
		unbind = "unbindTableProvider",
		service = TableProvider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	protected void bindTableProvider(TableProvider provider) {
		if (provider != this)
			otherProviders.add(provider);
	}
		
	protected void unbindTableProvider(TableProvider provider) {
		if (provider != this) {
			otherProviders.remove(provider);
			backingProvider.invalidateCache(); }
	}
		
	private List<TableProvider> otherProviders = new ArrayList<TableProvider>();
	private Provider.MemoizingProvider<String,Table> backingProvider
	= memoize(dispatch(otherProviders));
	
}
