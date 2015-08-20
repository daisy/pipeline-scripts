package org.daisy.pipeline.braille.liblouis.impl;

import java.net.URI;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.common.base.Function;
import static com.google.common.base.Objects.toStringHelper;
import com.google.common.base.Optional;
import com.google.common.base.Splitter;
import com.google.common.collect.ImmutableMap;
import static com.google.common.collect.Iterables.concat;
import static com.google.common.collect.Iterables.toArray;
import static com.google.common.collect.Iterables.transform;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import static org.daisy.pipeline.braille.css.Query.serializeQuery;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.Transform.AbstractTransform;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.memoize;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.dispatch;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.logCreate;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.logSelect;
import org.daisy.pipeline.braille.common.TextTransform;
import org.daisy.pipeline.braille.common.util.Locales;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Strings.extractHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.insertHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.common.util.Tuple2;
import org.daisy.pipeline.braille.common.WithSideEffect;

import org.daisy.pipeline.braille.liblouis.LiblouisTable;
import static org.daisy.pipeline.braille.liblouis.LiblouisTable.tokenizeTable;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator.Typeform;

import org.liblouis.TranslationException;
import org.liblouis.TranslationResult;
import org.liblouis.Translator;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.liblouis.impl.LiblouisTranslatorJnaImpl",
	service = {
		LiblouisTranslator.Provider.class,
		BrailleTranslator.Provider.class,
		TextTransform.Provider.class
	}
)
public class LiblouisTranslatorJnaImpl implements LiblouisTranslator.Provider {
	
	private final static char SHY = '\u00AD';
	private final static char ZWSP = '\u200B';
	
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
	
	@Reference(
		name = "HyphenatorProvider",
		unbind = "unbindHyphenatorProvider",
		service = Hyphenator.Provider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	@SuppressWarnings(
		"unchecked" // safe cast to Transform.Provider<Hyphenator>
	)
	protected void bindHyphenatorProvider(Hyphenator.Provider<?> provider) {
		if (provider instanceof LiblouisHyphenatorJnaImpl)
			return;
		hyphenatorProviders.add((Transform.Provider<Hyphenator>)provider);
		hyphenatorProvider.invalidateCache();
		logger.debug("Adding Hyphenator provider: " + provider);
	}
	
	protected void unbindHyphenatorProvider(Hyphenator.Provider<?> provider) {
		if (provider instanceof LiblouisHyphenatorJnaImpl)
			return;
		hyphenatorProviders.remove(provider);
		hyphenatorProvider.invalidateCache();
		logger.debug("Removing Hyphenator provider: " + provider);
	}
	
	private List<Transform.Provider<Hyphenator>> hyphenatorProviders
	= new ArrayList<Transform.Provider<Hyphenator>>();
	
	private Provider.MemoizingProvider<String,Hyphenator> hyphenatorProvider
	= memoize(dispatch(hyphenatorProviders));
	
	/**
	 * Recognized features:
	 *
	 * - translator: Will only match if the value is `liblouis'
	 *
	 * - hyphenator: A value `none' will disable hyphenation. `liblouis' will match only liblouis
	 *     translators that support hyphenation out-of-the-box. `auto' is the default and will match
	 *     any liblouis translator, whether it supports hyphenation out-of-the-box, with the help of
	 *     an external hyphenator, or not at all. A value not equal to `none', `liblouis' or `auto'
	 *     will match every liblouis translator that uses an external hyphenator that matches this
	 *     feature.
	 *
	 * - table or liblouis-table: A liblouis table is a list of URIs that can be either a file name,
	 *     a file path relative to a registered tablepath, an absolute file URI, or a fully
	 *     qualified table identifier. The tablepath that contains the first `sub-table' in the list
	 *     will be used as the base for resolving the subsequent sub-tables. This feature is not
	 *     compatible with other features except `translator', `hyphenator' and `locale'.
	 *
	 * - locale: Matches only liblouis translators with that locale.
	 *
	 * Other features are passed on to lou_findTable.
	 *
	 * A translator will only use external hyphenators with the same locale as the translator itself.
	 */
	public Iterable<LiblouisTranslator> get(String query) {
		return impl.get(query);
	}
	
	public Transform.Provider<LiblouisTranslator> withContext(Logger context) {
		return impl.withContext(context);
	}
	
	private Transform.Provider.MemoizingProvider<LiblouisTranslator> impl = new ProviderImpl(null);
	
	private final static Iterable<WithSideEffect<LiblouisTranslator,Logger>> empty
		= Optional.<WithSideEffect<LiblouisTranslator,Logger>>absent().asSet();
	
	private class ProviderImpl extends AbstractProvider<LiblouisTranslator> {
		
		private ProviderImpl(Logger context) {
			super(context);
		}
		
		protected Transform.Provider.MemoizingProvider<LiblouisTranslator> _withContext(Logger context) {
			return new ProviderImpl(context);
		}
		
		protected final Iterable<WithSideEffect<LiblouisTranslator,Logger>> __get(String query) {
			final Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.remove("translator")) != null)
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
			if ((o = q.remove("hyphenator")) != null)
				v = o.get();
			else
				v = "auto";
			final String hyphenator = v;
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
			q.put("unicode", Optional.<String>absent());
			q.put("white-space", Optional.<String>absent());
			Iterable<Translator> tables = tableProvider.get(serializeQuery(q));
			return concat(
				transform(
					tables,
					new Function<Translator,Iterable<WithSideEffect<LiblouisTranslator,Logger>>>() {
						public Iterable<WithSideEffect<LiblouisTranslator,Logger>> apply(final Translator table) {
							Iterable<WithSideEffect<LiblouisTranslator,Logger>> translators = empty;
							if (!"none".equals(hyphenator)) {
								if ("liblouis".equals(hyphenator) || "auto".equals(hyphenator))
									for (URI t : tokenizeTable(table.getTable()))
										if (t.toString().endsWith(".dic")) {
											translators = Optional.of(
												logCreate((LiblouisTranslator)new LiblouisTranslatorHyphenatorImpl(table))
											).asSet();
											break; }
								if (!"liblouis".equals("hyphenator")) {
									ImmutableMap.Builder<String,Optional<String>> hyphenatorQuery
										= new ImmutableMap.Builder<String,Optional<String>>();
									if (!"auto".equals(hyphenator))
										hyphenatorQuery.put("hyphenator", Optional.of(hyphenator));
									if (locale != null)
										hyphenatorQuery.put("locale", Optional.of(locale));
									String hyphenatorQueryString = serializeQuery(hyphenatorQuery.build());
									Iterable<WithSideEffect<Hyphenator,Logger>> hyphenators
										= logSelect(hyphenatorQueryString, hyphenatorProvider.get(hyphenatorQueryString));
									translators = concat(
										translators,
										transform(
											hyphenators,
											new WithSideEffect.Function<Hyphenator,LiblouisTranslator,Logger>() {
												public LiblouisTranslator _apply(Hyphenator hyphenator) {
													return applyWithSideEffect(
														logCreate(
															(LiblouisTranslator)new LiblouisTranslatorImpl(table, hyphenator))); }}));
										}}
							if ("none".equals(hyphenator) || "auto".equals(hyphenator))
								translators = concat(
									translators,
									Optional.of(
										logCreate((LiblouisTranslator)new LiblouisTranslatorImpl(table))
									).asSet());
							return translators;
						}
					}
				)
			);
		}
	}
	
	private static class LiblouisTranslatorImpl extends AbstractTransform implements LiblouisTranslator {
		
		private final LiblouisTable table;
		protected final Translator translator;
		private final Hyphenator hyphenator;
		
		private LiblouisTranslatorImpl(Translator translator) {
			this(translator, null);
		}
		
		private LiblouisTranslatorImpl(Translator translator, Hyphenator hyphenator) {
			this.table = new LiblouisTable(translator.getTable());
			this.translator = translator;
			this.hyphenator = hyphenator;
		}
		
		public LiblouisTable asLiblouisTable() {
			return table;
		}
		
		public boolean isHyphenating() {
			return hyphenator != null;
		}
		
		public String transform(String text) {
			return transform(new String[]{text})[0];
		}
		
		public String[] transform(String[] text) {
			return transform(text, new byte[]{Typeform.PLAIN});
		}
		
		public String transform(String text, String cssStyle) {
			return transform(new String[]{text}, new String[]{cssStyle})[0];
		}
		
		public String[] transform(String[] text, String[] cssStyle) {
			byte[] typeform = new byte[cssStyle.length];
			boolean[] hyphenate = new boolean[cssStyle.length];
			boolean[] preserveLines = new boolean[cssStyle.length];
			boolean[] preserveSpace = new boolean[cssStyle.length];
			for (int i = 0; i < cssStyle.length; i++) {
				Map<String,String> style = new HashMap<String,String>(CSS_PARSER.split(cssStyle[i]));
				String val = style.remove("text-transform");
				typeform[i] = Typeform.PLAIN;
				if (val != null) {
					text[i] = textFromTextTransform(text[i], val);
					typeform[i] |= typeformFromTextTransform(val);
				}
				val = style.remove("hyphens");
				hyphenate[i] = false;
				if (val != null)
					if ("auto".equals(val))
						hyphenate[i] = true;
				val = style.remove("white-space");
				preserveLines[i] = preserveSpace[i] = false;
				if (val != null)
					if ("pre-wrap".equals(val))
						preserveLines[i] = preserveSpace[i] = true;
					else if ("pre-line".equals(val))
						preserveLines[i] = true;
				typeform[i] |= typeformFromInlineCSS(style); }
			return transform(text, typeform, hyphenate, preserveLines, preserveSpace);
		}
		
		public String transform(String text, byte typeform) {
			return transform(new String[]{text}, new byte[]{typeform})[0];
		}
		
		public String[] transform(String[] text, byte[] typeform) {
			boolean[] hyphenate = new boolean[text.length];
			boolean[] preserveLines = new boolean[text.length];
			boolean[] preserveSpace = new boolean[text.length];
			for (int i = 0; i < hyphenate.length; i++)
				hyphenate[i] = preserveLines[i] = preserveSpace[i] = false;
			return transform(text, typeform, hyphenate, preserveLines, preserveSpace);
		}
		
		protected final static char US = '\u001F';
		protected final static Splitter SEGMENT_SPLITTER = Splitter.on(US);
		private final static Pattern ON_NBSP_SPLITTER = Pattern.compile("[\\xAD\\u200B]*\\xA0[\\xAD\\u200B\\xA0]*");
		private final static Pattern ON_SPACE_SPLITTER = Pattern.compile("[\\xAD\\u200B]*[\\x20\t\\n\\r\\u2800\\xA0][\\xAD\\u200B\\x20\t\\n\\r\\u2800\\xA0]*");
		private final static Pattern LINE_SPLITTER = Pattern.compile("[\\xAD\\u200B]*[\\n\\r][\\xAD\\u200B\\n\\r]*");
		
		private String[] transform(String[] text, byte[] typeform, boolean[] hyphenate,
		                           boolean[] preserveLines, boolean[] preserveSpace) {
			
			// text with some segments split up into white space segments that need to be preserved
			// in the output and other segments
			String[] textWithWs;
			// boolean array for tracking which (non-empty white space) segments in textWithWs need
			// to be preserved
			boolean[] pre;
			// mapping from index in textWithWs to index in text
			int[] textWithWsMapping; {
				List<String> l1 = new ArrayList<String>();
				List<Boolean> l2 = new ArrayList<Boolean>();
				List<Integer> l3 = new ArrayList<Integer>();
				for (int i = 0; i < text.length; i++) {
					String t = text[i];
					if (t.isEmpty()) {
						l1.add(t);
						l2.add(false);
						l3.add(i); }
					else {
						Pattern ws;
						if (preserveSpace[i])
							ws = ON_SPACE_SPLITTER;
						else if (preserveLines[i])
							ws = LINE_SPLITTER;
						else
							ws = ON_NBSP_SPLITTER;
						boolean p = false;
						for (String s : splitInclDelimiter(t, ws)) {
							if (!s.isEmpty()) {
								l1.add(s);
								l2.add(p);
								l3.add(i); }
							p = !p; }}}
				int len = l1.size();
				textWithWs = new String[len];
				pre = new boolean[len];
				textWithWsMapping = new int[len];
				for (int i = 0; i < len; i++) {
					textWithWs[i] = l1.get(i);
					pre[i] = l2.get(i);
					textWithWsMapping[i] = l3.get(i); }
			}
			
			// textWithWs segments joined together with hyphens removed and sequences of preserved
			// white space replaced with a nbsp
			String joinedText;
			// mapping from character index in joinedText to segment index in textWithWs
			int[] joinedTextMapping;
			// byte array for tracking hyphenation positions, segment boundaries and boundaries of
			// sequences of preserved white
			byte[] positions; {
				String[] textWithWsReplaced = new String[textWithWs.length];
				for (int i = 0; i < textWithWs.length; i++)
					textWithWsReplaced[i] = pre[i] ? "\u00A0" : textWithWs[i];
				Tuple2<String,byte[]> t = extractHyphens(join(textWithWsReplaced, US), SHY, ZWSP);
				joinedText = t._1;
				positions = t._2;
				String[] nohyph = toArray(SEGMENT_SPLITTER.split(joinedText), String.class);
				joinedTextMapping = new int[join(nohyph).length()];
				int i = 0;
				int j = 0;
				for (String s : nohyph) {
					int l = s.length();
					for (int k = 0; k < l; k++)
						joinedTextMapping[i++] = j;
					j++; }
				t = extractHyphens(positions, joinedText, null, null, US);
				joinedText = t._1;
				positions = t._2;
				if (joinedText.matches("\\xA0*"))
					return text;
				if (positions == null)
					positions = new byte[joinedText.length() - 1];
			}
			
			// add automatic hyphenation points to positions array
			{
				boolean someHyphenate = false;
				boolean someNotHyphenate = false;
				for (int i = 0; i < hyphenate.length; i++)
					if (hyphenate[i]) someHyphenate = true;
					else someNotHyphenate = true;
				if (someHyphenate) {
					byte[] autoHyphens = doHyphenate(joinedText);
					if (someNotHyphenate) {
						int i = 0;
						for (int j = 0; j < text.length; j++) {
							if (hyphenate[j])
								while (i < autoHyphens.length && textWithWsMapping[joinedTextMapping[i]] < j + 1) i++;
							else {
								if (i > 0)
									autoHyphens[i - 1] = 0;
								while (i < autoHyphens.length && textWithWsMapping[joinedTextMapping[i]] < j + 1)
									autoHyphens[i++] = 0; }}}
					for (int i = 0; i < autoHyphens.length; i++)
						positions[i] += autoHyphens[i]; }
			}
			
			// typeform var with the same length as joinedText
			byte[] _typeform = null;
			for (byte b : typeform)
				if (b != Typeform.PLAIN) {
					_typeform = new byte[joinedText.length()];
					for (int i = 0; i < _typeform.length; i++)
						_typeform[i] = typeform[textWithWsMapping[joinedTextMapping[i]]];
					break; }
			
			// translate to braille with hyphens and restored white space
			String[] brailleWithWs;
			try {
				
				// translation result with hyphens and segment boundary marks
				String joinedBraille; {
					TranslationResult r = translator.translate(joinedText, positions, _typeform);
					joinedBraille = r.getBraille();
					byte[] pos = r.getHyphenPositions();
					if (pos != null)
						joinedBraille = insertHyphens(joinedBraille, pos, SHY, ZWSP, US);
				}
				
				// single segment
				if (textWithWs.length == 1)
					brailleWithWs = new String[]{joinedBraille};
				else {
					
					// split into segments
					{
						brailleWithWs = new String[textWithWs.length];
						int i = 0;
						int imax = joinedText.length();
						int kmax = textWithWs.length;
						int k = (i < imax) ? joinedTextMapping[i] : kmax;
						int l = 0;
						while (l < k) brailleWithWs[l++] = "";
						for (String s : SEGMENT_SPLITTER.split(joinedBraille)) {
							brailleWithWs[l++] = s;
							while (k < l)
								k = (++i < imax) ? joinedTextMapping[i] : kmax;
							while (l < k)
								brailleWithWs[l++] = ""; }
						if (l == kmax) {
							boolean wsLost = false;
							for (k = 0; k < kmax; k++)
								if (pre[k]) {
									Matcher m = Pattern.compile("\\xA0([\\xAD\\u200B]*)").matcher(brailleWithWs[k]);
									if (m.matches())
										brailleWithWs[k] = textWithWs[k] + m.group(1);
									else
										wsLost = true; }
							if (wsLost)
								logger.warn("White space was lost in the output.\n"
								            + "Input: " + Arrays.toString(textWithWs) + "\n"
								            + "Output: " + Arrays.toString(brailleWithWs)); }
						else {
							logger.warn("Text segmentation was lost in the output. Falling back to fuzzy mode.\n"
							            + "=> input segments: " + Arrays.toString(textWithWs) + "\n"
							            + "=> output segments: " + Arrays.toString(Arrays.copyOf(brailleWithWs, l)));
							brailleWithWs = null; }
					}
					
					// if some segment breaks were discarded, fall back on a fuzzy split method
					if (brailleWithWs == null) {
						
						// number the segments
						for (int i = 0; i < positions.length; i++) {
							int n = (joinedTextMapping[i + 1] % 31) + 1;
							positions[i] |= (byte)(n << 3); }
						
						// split at all positions where the segment number is increased in the output
						TranslationResult r = translator.translate(joinedText, positions, _typeform);
						String joinedBrailleWithoutHyphens = r.getBraille();
						byte[] pos = r.getHyphenPositions();
						{
							String s = joinedBrailleWithoutHyphens;
							if (pos != null)
								s = insertHyphens(joinedBrailleWithoutHyphens, pos, SHY, ZWSP, US);
							if (!s.equals(joinedBraille))
								throw new RuntimeException("Coding error");
						}
						brailleWithWs = new String[textWithWs.length];
						boolean wsLost = false;
						StringBuffer b = new StringBuffer();
						int jmax = joinedBrailleWithoutHyphens.length();
						int kmax = textWithWs.length;
						int k = joinedTextMapping[0];
						int l = 0;
						while (l < k)
							brailleWithWs[l++] = "";
						for (int j = 0; j < jmax - 1; j++) {
							b.append(joinedBrailleWithoutHyphens.charAt(j));
							if ((pos[j] & 1) == 1)
								b.append(SHY);
							if ((pos[j] & 2) == 2)
								b.append(ZWSP);
							int n = ((pos[j] >> 3) + 32) % 32;
							if (n > 0)
								if (((n - l - 1 + 31) % 31) > 0) {
									brailleWithWs[l] = b.toString();
									b = new StringBuffer();
									if ((pos[j] & 4) == 4) {
										if (pre[l]) {
											Matcher m = Pattern.compile("\\xA0([\\xAD\\u200B]*)").matcher(brailleWithWs[l]);
											if (m.matches())
												brailleWithWs[l] = textWithWs[l] + m.group(1);
											else
												wsLost = true; }}
									else {
										if (pre[l])
											wsLost = true;
										if (l <= kmax && pre[l + 1]) {
											pre[l + 1] = false;
											wsLost = true; }}
									l++;
									while (((n - l - 1) % 31) > 0) {
										brailleWithWs[l] = "";
										if (pre[l])
											wsLost = true;
										l++; }}}
						b.append(joinedBrailleWithoutHyphens.charAt(jmax - 1));
						brailleWithWs[l] = b.toString();
						if (pre[l])
							if (brailleWithWs[l].equals("\u00A0"))
								brailleWithWs[l] = textWithWs[l];
							else
								wsLost = true;
						l++;
						while (l < kmax) {
							if (pre[l])
								wsLost = true;
							brailleWithWs[l++] = ""; }
						if (wsLost)
							logger.warn("White space was lost in the output.\n"
							            + "Input: " + Arrays.toString(textWithWs) + "\n"
							            + "Output: " + Arrays.toString(brailleWithWs));
					}
				}
			} catch (TranslationException e) {
				throw new RuntimeException(e); }
			
			// recombine white space segments with other segments
			String braille[] = new String[text.length];
			for (int i = 0; i < braille.length; i++)
				braille[i] = "";
			for (int j = 0; j < brailleWithWs.length; j++)
				braille[textWithWsMapping[j]] += brailleWithWs[j];
			return braille;
		}
		
		protected byte[] doHyphenate(String text) {
			if (hyphenator == null)
				throw new RuntimeException("'hyphens:auto' is not supported");
			return extractHyphens(hyphenator.transform(text), SHY, ZWSP)._2;
		}
		
		private static String[] splitInclDelimiter(String text, Pattern delimiterPattern) {
			List<String> split = new ArrayList<String>();
			Matcher m = delimiterPattern.matcher(text);
			int i = 0;
			while (m.find()) {
				split.add(text.substring(i, m.start()));
				split.add(m.group());
				i = m.end(); }
			split.add(text.substring(i));
			return split.toArray(new String[split.size()]);
		}
		
		@Override
		public String toString() {
			return toStringHelper(this).add("translator", translator).add("hyphenator", hyphenator).toString();
		}
	
		@Override
		public int hashCode() {
			final int prime = 31;
			int hash = 1;
			hash = prime * hash + translator.hashCode();
			hash = prime * hash + ((hyphenator == null) ? 0 : hyphenator.hashCode());
			return hash;
		}
	
		@Override
		public boolean equals(Object object) {
			if (this == object)
				return true;
			if (object == null)
				return false;
			if (object.getClass() != LiblouisTranslatorImpl.class)
				return false;
			LiblouisTranslatorImpl that = (LiblouisTranslatorImpl)object;
			if (!this.translator.equals(that.translator))
				return false;
			if (this.hyphenator == null && that.hyphenator != null)
				return false;
			if (this.hyphenator != null && that.hyphenator == null)
				return false;
			if (!this.hyphenator.equals(that.hyphenator))
				return false;
			return true;
		}
	}
	
	private static class LiblouisTranslatorHyphenatorImpl extends LiblouisTranslatorImpl {
		
		private LiblouisTranslatorHyphenatorImpl(Translator translator) {
			super(translator);
		}
		
		@Override
		public boolean isHyphenating() {
			return true;
		}
		
		@Override
		protected byte[] doHyphenate(String text) {
			try { return translator.hyphenate(text); }
			catch (TranslationException e) {
				throw new RuntimeException(e); }
		}
		
		@Override
		public String toString() {
			return toStringHelper(this).add("translator", translator).add("hyphenator", "self").toString();
		}
	}
	
	private final static Splitter.MapSplitter CSS_PARSER
		= Splitter.on(';').omitEmptyStrings().withKeyValueSeparator(Splitter.on(':').limit(2).trimResults());

	/**
	 * @parameter style An inline CSS style
	 * @returns the corresponding typeform. Possible values are:
	 * - 0 = PLAIN
	 * - 1 = ITALIC (font-style: italic|oblique)
	 * - 2 = BOLD (font-weight: bold)
	 * - 4 = UNDERLINE (text-decoration: underline)
	 * These values can be added for multiple emphasis.
	 * @see http://liblouis.googlecode.com/svn/documentation/liblouis.html#lou_translateString
	 */
	protected static byte typeformFromInlineCSS(String style) {
		return typeformFromInlineCSS(CSS_PARSER.split(style));
	}
	
	protected static byte typeformFromInlineCSS(Map<String,String> style) {
		byte typeform = Typeform.PLAIN;
		for (String prop : style.keySet()) {
			String value = style.get(prop);
			if (prop.equals("font-style") && (value.equals("italic") || value.equals("oblique")))
				typeform |= Typeform.ITALIC;
			else if (prop.equals("font-weight") && value.equals("bold"))
				typeform |= Typeform.BOLD;
			else if (prop.equals("text-decoration") && value.equals("underline"))
				typeform |= Typeform.UNDERLINE;
			else
				logger.warn("Inline CSS property {} not supported", prop); }
		return typeform;
	}
	
	private final static Splitter TEXT_TRANSFORM_PARSER = Splitter.on(' ').omitEmptyStrings().trimResults();

	/**
	 * @parameter text The text to be transformed.
	 * @parameter textTransform A text-transform value as a space separated list of keywords.
	 * @returns the transformed text, or the original text if no transformations were performed.
	 */
	protected static String textFromTextTransform(String text, String textTransform) {
		for (String tt : TEXT_TRANSFORM_PARSER.split(textTransform)) {
			if (tt.equals("uppercase"))
				text = text.toUpperCase();
			else if (tt.equals("lowercase"))
				text = text.toLowerCase();
			else
				logger.warn("text-transform: {} not supported", tt);
		}
		return text;
	}
	
	/**
	 * @parameter textTransform A text-transform value as a space separated list of keywords.
	 * @returns the corresponding typeform. Possible values are:
	 * - 0 = PLAIN
	 * - 1 = ITALIC (louis-ital)
	 * - 2 = BOLD (louis-bold)
	 * - 4 = UNDERLINE (louis-under)
	 * - 8 = COMPUTER (louis-comp)
	 * These values can be added for multiple emphasis.
	 * @see http://liblouis.googlecode.com/svn/documentation/liblouis.html#lou_translateString
	 */
	protected static byte typeformFromTextTransform(String textTransform) {
		byte typeform = Typeform.PLAIN;
		for (String tt : TEXT_TRANSFORM_PARSER.split(textTransform)) {
			if (tt.equals("louis-ital"))
				typeform |= Typeform.ITALIC;
			else if (tt.equals("louis-bold"))
				typeform |= Typeform.BOLD;
			else if (tt.equals("louis-under"))
				typeform |= Typeform.UNDERLINE;
			else if (tt.equals("louis-comp"))
				typeform |= Typeform.COMPUTER;
			else
				logger.warn("text-transform: {} not supported", tt); }
		return typeform;
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisTranslatorJnaImpl.class);
	
}
