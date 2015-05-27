package org.daisy.pipeline.braille.pef.impl;

import java.util.HashMap;
import java.util.Map;

import com.google.common.base.Optional;

import org.daisy.braille.table.Table;
import org.daisy.braille.table.TableCatalog;

import static org.daisy.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.pef.TableProvider;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

@Component(
	name = "org.daisy.pipeline.braille.pef.impl.BrailleUtilsTableCatalog",
	service = { TableProvider.class }
)
public class BrailleUtilsTableCatalog implements TableProvider {
	
	// depend on spifly for now
	private TableCatalog catalog = TableCatalog.newInstance();
	
	/*@Reference(
		name = "TableCatalog",
		unbind = "-",
		service = TableCatalog.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)*/
	public void setTableCatalog(TableCatalog catalog) {
		this.catalog = catalog;
	}
	
	private final static Iterable<Table> empty = Optional.<Table>absent().asSet();
	
	public Iterable<Table> get(String query) {
		Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
		Optional<String> o;
		if ((o = q.remove("id")) != null)
			if (q.size() == 0)
				return Optional.<Table>fromNullable(catalog.get(o.get())).asSet();
		return empty;
	}
}
