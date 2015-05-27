package org.daisy.pipeline.braille.pef;

import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.NoSuchElementException;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableList;

import static org.daisy.braille.css.Query.parseQuery;

import org.daisy.braille.table.Table;
import org.daisy.factory.FactoryProperties;

public abstract class AbstractTableProvider implements TableProvider, org.daisy.braille.table.TableProvider {
	
	protected abstract Iterable<Table> get(Map<String,Optional<String>> query);
	
	private final Map<String,Table> tablesFromId = new HashMap<String,Table>();
	
	public Collection<FactoryProperties> list() {
		return new ImmutableList.Builder<FactoryProperties>().addAll(tablesFromId.values()).build();
	}
	
	public Table newFactory(String identifier) {
		try {
			return get("(id:'" + identifier + "')").iterator().next(); }
		catch (NoSuchElementException e) {
			return null; }
	}
	
	public Iterable<Table> get(String query) {
		Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
		Optional<String> o;
		if ((o = q.remove("id")) != null) {
			if (q.size() == 0)
				return Optional.<Table>fromNullable(tablesFromId.get(o.get())).asSet();
			else
				return empty; }
		else
			return cache(get(q));
	}
	
	private final static Iterable<Table> empty = Optional.<Table>absent().asSet();
	
	private Iterable<Table> cache(final Iterable<Table> tables) {
		return new Iterable<Table>() {
			public Iterator<Table> iterator() {
				return new Iterator<Table>() {
					Iterator<Table> i = null;
					public boolean hasNext() {
						if (i == null) i = tables.iterator();
						return i.hasNext();
					}
					public Table next() {
						Table t;
						if (i == null) i = tables.iterator();
						t = i.next();
						tablesFromId.put(t.getIdentifier(), t);
						return t;
					}
					public void remove() {
						if (i == null) i = tables.iterator();
						i.remove();
					}
				};
			}
		};
	}
}
