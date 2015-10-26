package org.daisy.pipeline.braille.pef.impl;

import java.net.URI;
import java.util.HashMap;
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
		if ((o = query.get("locale")) != null) {
			String identifier = tablesFromLocale.get(o.get());
			if (identifier != null) {
				query.put("id", Optional.of(identifier));
				tables = super.get(serializeQuery(query)); }}
		return tables;
	}
	
	private final static Iterable<Table> empty = Optional.<Table>absent().asSet();
}
