package org.daisy.pipeline.braille.pef.impl;

import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.NoSuchElementException;

import com.google.common.base.Optional;

import org.daisy.braille.api.embosser.EmbosserWriter;
import org.daisy.braille.api.embosser.FileFormat;
import org.daisy.braille.api.embosser.LineBreaks;
import org.daisy.braille.api.embosser.StandardLineBreaks;
import org.daisy.braille.api.factory.FactoryProperties;
import org.daisy.braille.api.table.BrailleConverter;
import org.daisy.braille.api.table.Table;
import org.daisy.braille.api.table.TableFilter;

import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import org.daisy.pipeline.braille.common.Provider.util.MemoizingProvider;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.Feature;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.pef.FileFormatProvider;
import org.daisy.pipeline.braille.pef.impl.BRFWriter;
import org.daisy.pipeline.braille.pef.impl.BRFWriter.Padding;
import org.daisy.pipeline.braille.pef.impl.BRFWriter.PageBreaks;
import org.daisy.pipeline.braille.pef.TableProvider;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

public class ConfigurableFileFormat implements FileFormat {
	
	private static final String DEFAULT_TABLE = "org.daisy.braille.impl.table.DefaultTableProvider.TableType.EN_US";
	private static final LineBreaks DEFAULT_LINE_BREAKS = new StandardLineBreaks(StandardLineBreaks.Type.DEFAULT);
	private static final PageBreaks DEFAULT_PAGE_BREAKS = new PageBreaks() {
		public String getString() {
			return "\u000c";
		}
	};
	private static final Padding DEFAULT_PADDING = Padding.NONE;
	private static final String DEFAULT_FILE_EXTENSION = ".brf";
	
	private final org.daisy.pipeline.braille.common.Provider<Query,Table> tableProvider;
	private Table table;
	private LineBreaks lineBreaks;
	private PageBreaks pageBreaks;
	private Padding padding;
	private String fileExtension;
	
	private ConfigurableFileFormat(org.daisy.pipeline.braille.common.Provider<Query,Table> tableProvider) {
		this.tableProvider = tableProvider;
		lineBreaks = DEFAULT_LINE_BREAKS;
		pageBreaks = DEFAULT_PAGE_BREAKS;
		padding = DEFAULT_PADDING;
		fileExtension = DEFAULT_FILE_EXTENSION;
	}
	
	public String getIdentifier() {
		return ConfigurableFileFormat.class.toString();
	}
	
	public String getDisplayName() {
		return getIdentifier();
	}
	
	public String getDescription() {
		return "";
	}
	
	public String getFileExtension() {
		return fileExtension;
	}
	
	public boolean supports8dot() {
		return false;
	}
	
	public boolean supportsDuplex() {
		return false;
	}
	
	private final TableFilter tableFilter = new TableFilter() {
		public boolean accept(FactoryProperties object) {
			return true;
		}
	};
	
	public TableFilter getTableFilter() {
		return tableFilter;
	}
	
	public boolean supportsTable(Table table) {
		return tableFilter.accept(table);
	}
	
	public void setFeature(String key, final Object value) {
		if ("table".equals(key)) {
			if (value != null) {
				Table t; {
					t = null;
					if (value instanceof Table)
						t = (Table)value;
					else if (value instanceof String)
						try {
							t = tableProvider.get(mutableQuery().add("id", (String)value)).iterator().next(); }
						catch (NoSuchElementException e) {}}
				if (t != null && tableFilter.accept(t)) {
					table = t;
					return; }}
			throw new IllegalArgumentException("Unsupported value for table: " + value);
		} else if ("locale".equals(key)) {
			if (value != null) {
				String locale; {
					locale = null;
					if (value instanceof Locale)
						locale = ((Locale)value).toLanguageTag();
					else if (value instanceof String)
						locale = (String)locale; }
					if (locale != null) {
						try {
							Table t = tableProvider.get(mutableQuery().add("locale", locale)).iterator().next();
							if (tableFilter.accept(t)) {
								table = t;
								return; }}
						catch (NoSuchElementException e) {}}}
			throw new IllegalArgumentException("Unsupported value for table: " + value);
		} else if ("line-breaks".equals(key)) {
			if (value != null) {
				if (value instanceof LineBreaks) {
					lineBreaks = (LineBreaks)value;
					return; }
				else if (value instanceof String) {
					lineBreaks = new StandardLineBreaks(StandardLineBreaks.Type.valueOf(((String)value).toUpperCase()));
					return; }}
			throw new IllegalArgumentException("Unsupported value for line-breaks: " + value);
		} else if ("page-breaks".equals(key)) {
			if (value != null) {
				if (value instanceof PageBreaks) {
					pageBreaks = (PageBreaks)value;
					return; }
				else if (value instanceof String) {
					pageBreaks = new PageBreaks() {
						public String getString() {
							return (String)value; }};
					return; }}
			throw new IllegalArgumentException("Unsupported value for page-breaks: " + value);
		} else if ("pad".equals(key)) {
			if (value != null) {
				if (value instanceof Padding) {
					padding = (Padding)value;
					return; }
				else if (value instanceof String) {
					padding = Padding.valueOf(((String)value).toUpperCase());
					return; }}
			throw new IllegalArgumentException("Unsupported value for pad: " + value);
		} else if ("file-extension".equals(key)) {
			if (value != null) {
				if (value instanceof String) {
					fileExtension = (String)value;
					return; }}
		} else
			throw new IllegalArgumentException("Unsupported feature: " + key);
	}
	
	public Object getFeature(String key) {
		if ("table".equals(key))
			return table;
		else if ("line-breaks".equals(key))
			return lineBreaks;
		else if ("page-breaks".equals(key))
			return pageBreaks;
		else if ("pad".equals(key))
			return padding;
		else if ("file-extension".equals(key))
			return fileExtension;
		else
			throw new IllegalArgumentException("Unsupported feature: " + key);
	}
	
	public EmbosserWriter newEmbosserWriter(final OutputStream os) {
		if (table == null)
			throw new RuntimeException("table not set");
		final BrailleConverter brailleConverter = table.newBrailleConverter();
		return new BRFWriter() {
			public LineBreaks getLinebreakStyle() {
				return lineBreaks;
			}
			public PageBreaks getPagebreakStyle() {
				return pageBreaks;
			}
			public Padding getPaddingStyle() {
				return padding;
			}
			public BrailleConverter getTable() {
				return brailleConverter;
			}
			protected void add(byte b) throws IOException {
				os.write(b);
			}
			protected void addAll(byte[] b) throws IOException {
				os.write(b);
			}
		};
	}
	
	public Object getProperty(String key) {
		throw new UnsupportedOperationException();
	}
	
	@Component(
		name = "org.daisy.pipeline.braille.pef.impl.ConfigurableFileFormat$Provider",
		service = { FileFormatProvider.class }
	)
	public static class Provider implements FileFormatProvider {
		
		public Iterable<FileFormat> get(Query query) {
			MutableQuery q = mutableQuery(query);
			FileFormat format = new ConfigurableFileFormat(tableProvider);
			for (Feature f : q)
				try {
					format.setFeature(f.getKey(), f.getValue().or(f.getKey())); }
				catch (Exception e) {
					return empty; }
			if (format.getFeature("table") == null)
				try {
					format.setFeature("table", DEFAULT_TABLE); }
				catch (Exception e) {
					return empty; }
			return Collections.singleton(format);
		}
		
		private List<TableProvider> tableProviders = new ArrayList<TableProvider>();
		private MemoizingProvider<Query,Table> tableProvider = memoize(dispatch(tableProviders));
	
		@Reference(
			name = "TableProvider",
			unbind = "removeTableProvider",
			service = TableProvider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void addTableProvider(TableProvider provider) {
			tableProviders.add(provider);
		}
		
		protected void removeTableProvider(TableProvider provider) {
			tableProviders.remove(provider);
			this.tableProvider.invalidateCache();
		}
	}
	
	private final static Iterable<FileFormat> empty = Optional.<FileFormat>absent().asSet();
	
}
