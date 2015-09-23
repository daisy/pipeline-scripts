package org.daisy.pipeline.braille.liblouis.impl;

import java.util.HashMap;
import java.util.Map;

import com.google.common.base.Function;
import com.google.common.base.Optional;
import com.google.common.base.Splitter;
import static com.google.common.collect.Iterables.toArray;
import static com.google.common.collect.Iterables.transform;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import static org.daisy.pipeline.braille.css.Query.serializeQuery;

import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.TextTransform;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.util.Locales;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Strings.extractHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.insertHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.common.util.Tuple2;

import org.daisy.pipeline.braille.liblouis.LiblouisHyphenator;
import org.daisy.pipeline.braille.liblouis.LiblouisTable;

import org.liblouis.TranslationException;
import org.liblouis.Translator;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.liblouis.impl.LiblouisHyphenatorJnaImpl",
	service = {
		LiblouisHyphenator.Provider.class,
		TextTransform.Provider.class,
		Hyphenator.Provider.class
	}
)
public class LiblouisHyphenatorJnaImpl implements LiblouisHyphenator.Provider {
	
	private LiblouisJnaImpl tableProvider;
	
	@Reference(
		name = "LiblouisJnaImpl",
		unbind = "unbindLiblouisJnaImpl",
		service = LiblouisJnaImpl.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindLiblouisJnaImpl(LiblouisJnaImpl provider) {
		tableProvider = provider;
		logger.debug("Registering Liblouis JNA translator provider: " + provider);
	}
	
	protected void unbindLiblouisJnaImpl(LiblouisJnaImpl provider) {
		tableProvider = null;
	}
	
	public Transform.Provider<LiblouisHyphenator> withContext(Logger context) {
		return this;
	}
	
	/**
	 * Recognized features:
	 *
	 * - hyphenator: Will only match if the value is `liblouis'
	 *
	 * - table or liblouis-table: A liblouis table is a list of URIs that can be either a file name,
	 *     a file path relative to a registered tablepath, an absolute file URI, or a fully
	 *     qualified table identifier. The tablepath that contains the first `sub-table' in the list
	 *     will be used as the base for resolving the subsequent sub-tables. This feature is not
	 *     compatible with other features except `hyphenator' and `locale'.
	 *
	 * - locale: Matches only hyphenators with that locale.
	 *
	 * Other features are passed on to lou_findTable.
	 */
	public Iterable<LiblouisHyphenator> get(String query) {
		return provider.get(query);
	}
	
	private final static Iterable<LiblouisHyphenator> empty = Optional.<LiblouisHyphenator>absent().asSet();
	
	private Provider.MemoizingProvider<String,LiblouisHyphenator> provider
	= new Provider.MemoizingProvider<String,LiblouisHyphenator>() {
		public Iterable<LiblouisHyphenator> _get(String query) {
			final Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.remove("hyphenator")) != null)
				if (!"liblouis".equals(o.get()))
					return empty;
			String table = null;
			if ((o = q.remove("liblouis-table")) != null)
				table = o.get();
			if ((o = q.remove("table")) != null)
				if (table != null) {
					logger.warn("A query with both 'table' and 'liblouis-table' never matches anything");
					return empty; }
				else
					table = o.get();
			String v = null;
			v = null;
			if ((o = q.remove("locale")) != null)
				v = o.get();
			final String locale = v;
			if (table != null && q.size() > 0) {
				logger.warn("A query with both 'table' or 'liblouis-table' and '"
				            + q.keySet().iterator().next() + "' never matches anything");
				return empty; }
			if (table != null)
				q.put("table", Optional.of(table));
			if (locale != null)
				q.put("locale", Optional.of(Locales.toString(parseLocale(locale), '_')));
			Iterable<LiblouisJnaImpl.Table> tables = tableProvider.get(serializeQuery(q));
			return transform(
				tables,
				new Function<LiblouisJnaImpl.Table,LiblouisHyphenator>() {
					public LiblouisHyphenator apply(LiblouisJnaImpl.Table table) {
						return new LiblouisHyphenatorImpl(table.getTranslator()); }});
		}
	};
	
	private static class LiblouisHyphenatorImpl extends AbstractTransform implements LiblouisHyphenator {
		
		private final LiblouisTable table;
		private final Translator translator;
		
		private LiblouisHyphenatorImpl(Translator translator) {
			this.table = new LiblouisTable(translator.getTable());
			this.translator = translator;
		}
		
		public LiblouisTable asLiblouisTable() {
			return table;
		}
		
		private final static char SHY = '\u00AD';
		private final static char ZWSP = '\u200B';
		private final static char US = '\u001F';
		private final static Splitter SEGMENT_SPLITTER = Splitter.on(US);
		
		public String transform(String text) {
			return insertHyphens(text, doHyphenate(text), SHY, ZWSP);
		}
		
		public String[] transform(String text[]) {
			// This byte array is used not only to track the hyphen
			// positions but also the segment boundaries.
			byte[] positions;
			Tuple2<String,byte[]> t = extractHyphens(join(text, US), SHY, ZWSP);
			String[] unhyphenated = toArray(SEGMENT_SPLITTER.split(t._1), String.class);
			t = extractHyphens(t._2, t._1, null, null, US);
			String _text = t._1;
			if (t._2 != null)
				positions = t._2;
			else
				positions = new byte[_text.length() - 1];
			byte[] autoHyphens = doHyphenate(_text);
			for (int i = 0; i < autoHyphens.length; i++)
				positions[i] += autoHyphens[i];
			_text = insertHyphens(_text, positions, SHY, ZWSP, US);
			if (text.length == 1)
				return new String[]{_text};
			else {
				String[] rv = new String[text.length];
				int i = 0;
				for (String s : SEGMENT_SPLITTER.split(_text)) {
					while (unhyphenated[i].length() == 0)
						rv[i++] = "";
					rv[i++] = s; }
				while(i < text.length)
					rv[i++] = "";
				return rv; }
		}
		
		private byte[] doHyphenate(String text) {
			try { return translator.hyphenate(text); }
			catch (TranslationException e) {
				throw new RuntimeException(e); }
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisHyphenatorJnaImpl.class);
	
}
