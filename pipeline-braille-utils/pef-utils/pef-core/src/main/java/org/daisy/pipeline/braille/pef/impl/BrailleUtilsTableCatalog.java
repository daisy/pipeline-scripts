package org.daisy.pipeline.braille.pef.impl;

import com.google.common.base.Optional;

import org.daisy.braille.api.table.Table;
import org.daisy.braille.api.table.TableCatalogService;

import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
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
	
	private TableCatalogService catalog;
	
	@Reference(
		name = "TableCatalog",
		unbind = "-",
		service = TableCatalogService.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	public void setTableCatalog(TableCatalogService catalog) {
		this.catalog = catalog;
	}
	
	private final static Iterable<Table> empty = Optional.<Table>absent().asSet();
	
	public Iterable<Table> get(Query query) {
		MutableQuery q = mutableQuery(query);
		if (q.containsKey("id")) {
			String id = q.removeOnly("id").getValue().get();
			if (q.isEmpty())
				return Optional.fromNullable(catalog.newTable(id)).asSet(); }
		return empty;
	}
}
