package org.daisy.pipeline.braille.liblouis.impl;

import java.net.URI;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.common.base.Objects;
import com.google.common.base.Objects.ToStringHelper;
import com.google.common.base.Splitter;
import com.google.common.collect.ImmutableList;
import static com.google.common.collect.Iterables.size;
import static com.google.common.collect.Iterables.toArray;

import cz.vutbr.web.css.CSSProperty;
import cz.vutbr.web.css.CSSProperty.FontStyle;
import cz.vutbr.web.css.CSSProperty.FontWeight;
import cz.vutbr.web.css.CSSProperty.TextDecoration;
import cz.vutbr.web.css.Term;
import cz.vutbr.web.css.TermIdent;
import cz.vutbr.web.css.TermInteger;
import cz.vutbr.web.css.TermList;

import org.daisy.braille.css.BrailleCSSProperty.Hyphens;
import org.daisy.braille.css.BrailleCSSProperty.LetterSpacing;
import org.daisy.braille.css.BrailleCSSProperty.TextTransform;
import org.daisy.braille.css.BrailleCSSProperty.WhiteSpace;
import org.daisy.braille.css.BrailleCSSProperty.WordSpacing;
import org.daisy.braille.css.SimpleInlineStyle;

import org.daisy.pipeline.braille.common.AbstractBrailleTranslator;
import org.daisy.pipeline.braille.common.AbstractBrailleTranslator.util.DefaultLineBreaker;
import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Function;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables.concat;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables.transform;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logCreate;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logSelect;
import org.daisy.pipeline.braille.common.BrailleTranslatorProvider;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.Feature;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.common.TransformProvider;
import static org.daisy.pipeline.braille.common.TransformProvider.util.memoize;
import static org.daisy.pipeline.braille.common.TransformProvider.util.dispatch;
import org.daisy.pipeline.braille.common.util.Locales;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Strings.extractHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.insertHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.common.util.Tuple2;

import org.daisy.pipeline.braille.liblouis.LiblouisTable;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator.Typeform;
import org.daisy.pipeline.braille.liblouis.impl.LiblouisTableJnaImplProvider.LiblouisTableJnaImpl;

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
	name = "org.daisy.pipeline.braille.liblouis.impl.LiblouisTranslatorJnaImplProvider",
	service = {
		LiblouisTranslator.Provider.class,
		BrailleTranslatorProvider.class,
		TransformProvider.class
	}
)
public class LiblouisTranslatorJnaImplProvider extends AbstractTransformProvider<LiblouisTranslator> implements LiblouisTranslator.Provider {
	
	private final static char SHY = '\u00AD';
	private final static char ZWSP = '\u200B';
	
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
		logger.debug("Registering Liblouis JNA translator provider: " + provider);
	}
	
	protected void unbindLiblouisTableJnaImplProvider(LiblouisTableJnaImplProvider provider) {
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
		"unchecked" // safe cast to TransformProvider<Hyphenator>
	)
	protected void bindHyphenatorProvider(Hyphenator.Provider<?> provider) {
		if (provider instanceof LiblouisHyphenatorJnaImplProvider)
			return;
		hyphenatorProviders.add((TransformProvider<Hyphenator>)provider);
		hyphenatorProvider.invalidateCache();
		logger.debug("Adding Hyphenator provider: " + provider);
	}
	
	protected void unbindHyphenatorProvider(Hyphenator.Provider<?> provider) {
		if (provider instanceof LiblouisHyphenatorJnaImplProvider)
			return;
		hyphenatorProviders.remove(provider);
		hyphenatorProvider.invalidateCache();
		logger.debug("Removing Hyphenator provider: " + provider);
	}
	
	private List<TransformProvider<Hyphenator>> hyphenatorProviders
	= new ArrayList<TransformProvider<Hyphenator>>();
	
	private TransformProvider.util.MemoizingProvider<Hyphenator> hyphenatorProvider
	= memoize(dispatch(hyphenatorProviders));
	
	private final static Iterable<LiblouisTranslator> empty
	= Iterables.<LiblouisTranslator>empty();
	
	private final static List<String> supportedInput = ImmutableList.of("text-css");
	
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
	 * Other features are passed on to lou_findTable. All matched tables must be of type "translation table".
	 *
	 * A translator will only use external hyphenators with the same locale as the translator itself.
	 */
	protected final Iterable<LiblouisTranslator> _get(Query query) {
		MutableQuery q = mutableQuery(query);
		for (Feature f : q.removeAll("input"))
			if (!supportedInput.contains(f.getValue().get()))
				return empty;
		boolean asciiBraille = false;
		if (q.containsKey("output")) {
			String v = q.removeOnly("output").getValue().get();
			if ("braille".equals(v)) {}
			else if ("ascii".equals(v))
				asciiBraille = true;
			else
				return empty; }
		if (q.containsKey("translator"))
			if (!"liblouis".equals(q.removeOnly("translator").getValue().get()))
				return empty;
		String table = null;
		if (q.containsKey("liblouis-table"))
			table = q.removeOnly("liblouis-table").getValue().get();
		if (q.containsKey("table"))
			if (table != null) {
				logger.warn("A query with both 'table' and 'liblouis-table' never matches anything");
				return empty; }
			else
				table = q.removeOnly("table").getValue().get();
		String v = null;
		if (q.containsKey("hyphenator"))
			v = q.removeOnly("hyphenator").getValue().get();
		else
			v = "auto";
		final String hyphenator = v;
		v = null;
		if (q.containsKey("locale"))
			v = q.removeAll("locale").iterator().next().getValue().get();
		final String locale = v;
		if (table != null && !q.isEmpty()) {
			logger.warn("A query with both 'table' or 'liblouis-table' and '"
			            + q.iterator().next().getKey() + "' never matches anything");
			return empty; }
		if (table != null)
			q.add("table", table);
		if (locale != null)
			q.add("locale", Locales.toString(parseLocale(locale), '_'));
		if (!asciiBraille)
			q.add("unicode");
		q.add("white-space");
		Iterable<LiblouisTableJnaImpl> tables = logSelect(q.asImmutable(), tableProvider);
		return concat(
			transform(
				tables,
				new Function<LiblouisTableJnaImpl,Iterable<LiblouisTranslator>>() {
					public Iterable<LiblouisTranslator> _apply(final LiblouisTableJnaImpl table) {
						Iterable<LiblouisTranslator> translators = empty;
						if (!"none".equals(hyphenator)) {
							if ("liblouis".equals(hyphenator) || "auto".equals(hyphenator))
								for (URI t : table.asURIs())
									if (t.toString().endsWith(".dic")) {
										translators = Iterables.of(
											logCreate((LiblouisTranslator)new LiblouisTranslatorHyphenatorImpl(table.getTranslator()))
										);
										break; }
							if (!"liblouis".equals("hyphenator")) {
								MutableQuery hyphenatorQuery = mutableQuery();
								if (!"auto".equals(hyphenator))
									hyphenatorQuery.add("hyphenator", hyphenator);
								if (locale != null)
									hyphenatorQuery.add("locale", locale);
								Iterable<Hyphenator> hyphenators = logSelect(hyphenatorQuery.asImmutable(), hyphenatorProvider);
								translators = concat(
									translators,
									transform(
										hyphenators,
										new Function<Hyphenator,LiblouisTranslator>() {
											public LiblouisTranslator _apply(Hyphenator hyphenator) {
												return __apply(
													logCreate(
														(LiblouisTranslator)new LiblouisTranslatorImpl(table.getTranslator(), hyphenator))); }}));
								}}
						if ("none".equals(hyphenator) || "auto".equals(hyphenator))
							translators = concat(
								translators,
								logCreate((LiblouisTranslator)new LiblouisTranslatorImpl(table.getTranslator())));
						return translators;
					}
				}
			)
		);
	}
	
	@Override
	public ToStringHelper toStringHelper() {
		return Objects.toStringHelper("o.d.p.b.liblouis.impl.LiblouisTranslatorJnaImplProvider");
	}
	
	private static class LiblouisTranslatorImpl extends AbstractBrailleTranslator implements LiblouisTranslator {
		
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
		
		// FIXME: not if (input:text-css)
		public LiblouisTable asLiblouisTable() {
			return table;
		}
		
		public FromTypeformedTextToBraille fromTypeformedTextToBraille() {
			return fromTypeformedTextToBraille;
		}
		
		private FromTypeformedTextToBraille fromTypeformedTextToBraille = new FromTypeformedTextToBraille() {
			public String[] transform(String[] text, byte[] typeform) {
				return LiblouisTranslatorImpl.this.transform(text, typeform);
			}
		};
		
		@Override
		public FromStyledTextToBraille fromStyledTextToBraille() {
			return fromStyledTextToBraille;
		}
		
		private FromStyledTextToBraille fromStyledTextToBraille = new FromStyledTextToBraille() {
			public java.lang.Iterable<String> transform(java.lang.Iterable<CSSStyledText> styledText) {
				int size = size(styledText);
				String[] text = new String[size];
				List<SimpleInlineStyle> style = new ArrayList<SimpleInlineStyle>();
				int i = 0;
				for (CSSStyledText t : styledText) {
					text[i++] = t.getText();
					style.add(t.getStyle()); }
				return Arrays.asList(LiblouisTranslatorImpl.this.transform(text, style));
			}
		};
		
		@Override
		public LineBreakingFromStyledText lineBreakingFromStyledText() {
			return lineBreakingFromStyledText;
		}
		
		private final LineBreakingFromStyledText lineBreakingFromStyledText = new LineBreakingFromStyledText() {
			public LineIterator transform(java.lang.Iterable<CSSStyledText> styledText) {
				int size = size(styledText);
				String[] text = new String[size];
				List<SimpleInlineStyle> styles = new ArrayList<SimpleInlineStyle>();
				int wordSpacing = -1;
				int i = 0;
				for (CSSStyledText st : styledText) {
					SimpleInlineStyle style = st.getStyle();
					int spacing = 1;
					if (style != null) {
						CSSProperty val = style.getProperty("word-spacing");
						if (val != null) {
							if (val == WordSpacing.length) {
								spacing = style.getValue(TermInteger.class, "word-spacing").getIntValue();
								if (spacing < 0) {
									logger.warn("word-spacing: {} not supported, must be non-negative", val);
									spacing = 1; }}
							style.removeProperty("word-spacing"); }}
					if (wordSpacing < 0)
						wordSpacing = spacing;
					else if (wordSpacing != spacing)
						throw new RuntimeException("word-spacing must be constant, but both "
						                           + wordSpacing + " and " + spacing + " specified");
					text[i++] = st.getText();
					styles.add(style); }
				return new DefaultLineBreaker(join(LiblouisTranslatorImpl.this.transform(text, styles)), wordSpacing);
			}
		};
		
		private String[] transform(String[] text, List<SimpleInlineStyle> styles) {
			int size = text.length;
			byte[] typeform = new byte[size];
			boolean[] hyphenate = new boolean[size];
			boolean[] preserveLines = new boolean[size];
			boolean[] preserveSpace = new boolean[size];
			int[] letterSpacing = new int[size];
			boolean someTransform = false;
			boolean someNotTransform = false;
			for (int i = 0; i < size; i++) {
				typeform[i] = Typeform.PLAIN;
				hyphenate[i] = false;
				preserveLines[i] = preserveSpace[i] = false;
				letterSpacing[i] = 0;
				SimpleInlineStyle style = styles.get(i);
				if (style != null) {
					CSSProperty val = style.getProperty("white-space");
					if (val != null) {
						if (val == WhiteSpace.PRE_WRAP)
							preserveLines[i] = preserveSpace[i] = true;
						else if (val == WhiteSpace.PRE_LINE)
							preserveLines[i] = true;
						style.removeProperty("white-space"); }
					val = style.getProperty("text-transform");
					if (val != null) {
						if (val == TextTransform.NONE) {
							someNotTransform = true;
							if (!style.isEmpty())
								logger.warn("text-transform: none can not be used in combination with "
								            + style.getPropertyNames().iterator().next());
							continue; }
						else if (val == TextTransform.AUTO) {}
						else if (val == TextTransform.list_values) {
							TermList values = style.getValue(TermList.class, "text-transform");
							text[i] = textFromTextTransform(text[i], values);
							typeform[i] |= typeformFromTextTransform(values); }
						style.removeProperty("text-transform"); }
					someTransform = true;
					val = style.getProperty("hyphens");
					if (val != null) {
						if (val == Hyphens.AUTO)
							hyphenate[i] = true;
						style.removeProperty("hyphens"); }
					val = style.getProperty("letter-spacing");
					if (val != null) {
						if (val == LetterSpacing.length) {
							letterSpacing[i] = style.getValue(TermInteger.class, "letter-spacing").getIntValue();
							if (letterSpacing[i] < 0) {
								logger.warn("letter-spacing: {} not supported, must be non-negative", val);
								letterSpacing[i] = 0; }}
						style.removeProperty("letter-spacing"); }
					typeform[i] |= typeformFromInlineCSS(style); }
				else
					someTransform = true; }
			if (someNotTransform && !someTransform)
				return text;
			// FIXME: handle (someNotTransform && someTransform)
			return transform(text, typeform, hyphenate, preserveLines, preserveSpace, letterSpacing);
		}
		
		private String[] transform(String[] text, byte[] typeform) {
			int size = text.length;
			boolean[] hyphenate = new boolean[size];
			boolean[] preserveLines = new boolean[size];
			boolean[] preserveSpace = new boolean[size];
			int[] letterSpacing = new int[size];
			for (int i = 0; i < hyphenate.length; i++) {
				hyphenate[i] = preserveLines[i] = preserveSpace[i] = false;
				letterSpacing[i] = 0; }
			return transform(text, typeform, hyphenate, preserveLines, preserveSpace, letterSpacing);
		}
		
		protected final static char RS = '\u001E';
		protected final static char US = '\u001F';
		protected final static char NBSP = '\u00A0';
		protected final static Splitter SEGMENT_SPLITTER = Splitter.on(RS);
		private final static Pattern ON_NBSP_SPLITTER = Pattern.compile("[\\xAD\\u200B]*\\xA0[\\xAD\\u200B\\xA0]*");
		private final static Pattern ON_SPACE_SPLITTER = Pattern.compile("[\\xAD\\u200B]*[\\x20\t\\n\\r\\u2800\\xA0][\\xAD\\u200B\\x20\t\\n\\r\\u2800\\xA0]*");
		private final static Pattern LINE_SPLITTER = Pattern.compile("[\\xAD\\u200B]*[\\n\\r][\\xAD\\u200B\\n\\r]*");
		
		// the positions in the text where spacing must be inserted have been previously indicated with a US control character
		private String applyLetterSpacing(String text, int letterSpacing) {
			String space = "";
			for (int i = 0; i < letterSpacing; i++)
				space += NBSP;
			return text.replaceAll("\u001F", space);
		}
		
		private String[] transform(String[] text, byte[] typeform, boolean[] hyphenate,
		                           boolean[] preserveLines, boolean[] preserveSpace, int[] letterSpacing) {
			
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
			// sequences of preserved white space
			byte[] inputAttrs; {
				String[] textWithWsReplaced = new String[textWithWs.length];
				for (int i = 0; i < textWithWs.length; i++)
					textWithWsReplaced[i] = pre[i] ? "\u00A0" : textWithWs[i];
				Tuple2<String,byte[]> t = extractHyphens(join(textWithWsReplaced, RS), SHY, ZWSP);
				joinedText = t._1;
				inputAttrs = t._2;
				String[] nohyph = toArray(SEGMENT_SPLITTER.split(joinedText), String.class);
				joinedTextMapping = new int[join(nohyph).length()];
				int i = 0;
				int j = 0;
				for (String s : nohyph) {
					int l = s.length();
					for (int k = 0; k < l; k++)
						joinedTextMapping[i++] = j;
					j++; }
				t = extractHyphens(inputAttrs, joinedText, null, null, null, RS);
				joinedText = t._1;
				inputAttrs = t._2;
				if (joinedText.matches("\\xA0*"))
					return text;
				if (inputAttrs == null)
					inputAttrs = new byte[joinedText.length() - 1];
			}
			
			// add automatic hyphenation points to inputAttrs array
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
						inputAttrs[i] += autoHyphens[i]; }
			}
			
			// add letter information to inputAttrs array
			boolean someLetterSpacing = false; {
				for (int i = 0; i < letterSpacing.length; i++)
					if (letterSpacing[i] > 0) someLetterSpacing = true; }
			if (someLetterSpacing)
				inputAttrs = detectLetterBoundaries(inputAttrs, joinedText, (byte)4);
			
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
				String joinedBrailleWithoutHyphens;
				String joinedBraille;
				byte[] outputAttrs; {
					TranslationResult r = translator.translate(joinedText, inputAttrs, _typeform);
					joinedBrailleWithoutHyphens = r.getBraille();
					outputAttrs = r.getHyphenPositions();
					if (outputAttrs != null)
						joinedBraille = insertHyphens(joinedBrailleWithoutHyphens, outputAttrs, SHY, ZWSP, US, RS);
					else
						joinedBraille = joinedBrailleWithoutHyphens;
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
						
						// number of values in the attributes array that can be used for segment numbers
						int nmax = 2^8;
						// byte array for tracking segment numbers
						byte[] inputSegmentNumbers = new byte[inputAttrs.length]; {
							for (int i = 0; i < inputAttrs.length; i++) {
								int n = (joinedTextMapping[i + 1] % (nmax-1)) + 1;
								inputSegmentNumbers[i] = (byte)n; }}
						
						// split at all positions where the segment number is increased in the output
						TranslationResult r = translator.translate(joinedText, inputSegmentNumbers, _typeform);
						if (!r.getBraille().equals(joinedBrailleWithoutHyphens))
							throw new RuntimeException("Coding error");
						byte[] outputSegmentNumbers = r.getHyphenPositions();
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
							if ((outputAttrs[j] & 1) == 1)
								b.append(SHY);
							if ((outputAttrs[j] & 2) == 2)
								b.append(ZWSP);
							int n = mod(outputSegmentNumbers[j], nmax);
							if (n > 0)
								if (mod(n - l - 1, nmax-1) > 0) {
									brailleWithWs[l] = b.toString();
									b = new StringBuffer();
									if ((outputAttrs[j] & 8) == 8) {
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
									while (mod(n - l - 1, nmax-1) > 0) {
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
			
			// apply letter spacing
			if (someLetterSpacing)
				for (int i = 0; i < braille.length; i++)
					braille[i] = applyLetterSpacing(braille[i], letterSpacing[i]);
			
			return braille;
		}
		
		protected byte[] doHyphenate(String text) {
			if (hyphenator == null) {
				logger.warn("hyphens:auto not supported");
				byte[] hyphens = new byte[text.length() - 1];
				for (int i = 0; i < hyphens.length; i++)
					hyphens[i] = 0;
				return hyphens; }
			return extractHyphens(hyphenator.transform(new String[]{text})[0], SHY, ZWSP)._2;
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
		
		/*
		 * Detect where letter boundaries meet. Length of addTo must be one less than length of text.
		 */
		private static byte[] detectLetterBoundaries(byte[] addTo, String text, byte val) {
			for(int i = 0; i < addTo.length; i++){
				if(Character.isLetter(text.charAt(i)) && Character.isLetter(text.charAt(i+1)))
					addTo[i] |= val;
				if((text.charAt(i) == '-') || (text.charAt(i+1) == '-'))
					addTo[i] |= val;
				if((text.charAt(i) == '\u00ad')) // SHY is not actual character, so boundary only after SHY
					addTo[i] |= val;
				}
			return addTo;
		}
		
		@Override
		public ToStringHelper toStringHelper() {
			return Objects.toStringHelper("o.d.p.b.liblouis.impl.LiblouisTranslatorJnaImplProvider$LiblouisTranslatorImpl")
				.add("translator", translator)
				.add("hyphenator", hyphenator);
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
		protected byte[] doHyphenate(String text) {
			try { return translator.hyphenate(text); }
			catch (TranslationException e) {
				throw new RuntimeException(e); }
		}
		
		@Override
		public ToStringHelper toStringHelper() {
			return Objects.toStringHelper("o.d.p.b.liblouis.impl.LiblouisTranslatorJnaImplProvider$LiblouisTranslatorImpl")
				.add("translator", translator)
				.add("hyphenator", "self");
		}
	}
	
	/**
	 * @param style An inline CSS style
	 * @return the corresponding typeform. Possible values are:
	 * - 0 = PLAIN
	 * - 1 = ITALIC (font-style: italic|oblique)
	 * - 2 = BOLD (font-weight: bold)
	 * - 4 = UNDERLINE (text-decoration: underline)
	 * These values can be added for multiple emphasis.
	 * @see <a href="http://liblouis.googlecode.com/svn/documentation/liblouis.html#lou_translateString">lou_translateString</a>
	 */
	protected static byte typeformFromInlineCSS(SimpleInlineStyle style) {
		byte typeform = Typeform.PLAIN;
		for (String prop : style.getPropertyNames()) {
			if (prop.equals("font-style")) {
				CSSProperty value = style.getProperty(prop);
				if (value == FontStyle.ITALIC || value == FontStyle.OBLIQUE) {
					typeform |= Typeform.ITALIC;
					continue; }}
			else if (prop.equals("font-weight")) {
				CSSProperty value = style.getProperty(prop);
				if (value == FontWeight.BOLD) {
					typeform |= Typeform.BOLD;
					continue; }}
			else if (prop.equals("text-decoration")) {
				CSSProperty value = style.getProperty(prop);
				if (value == TextDecoration.UNDERLINE) {
					typeform |= Typeform.UNDERLINE;
					continue; }}
			logger.warn("Inline CSS property {} not supported", style.getSourceDeclaration(prop)); }
		return typeform;
	}
	
	/**
	 * @param text The text to be transformed.
	 * @param textTransform A text-transform value as a space separated list of keywords.
	 * @return the transformed text, or the original text if no transformations were performed.
	 */
	protected static String textFromTextTransform(String text, TermList textTransform) {
		for (Term<?> t : textTransform) {
			String tt = ((TermIdent)t).getValue();
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
	 * @param textTransform A text-transform value as a space separated list of keywords.
	 * @return the corresponding typeform. Possible values are:
	 * - 0 = PLAIN
	 * - 1 = ITALIC (louis-ital)
	 * - 2 = BOLD (louis-bold)
	 * - 4 = UNDERLINE (louis-under)
	 * - 8 = COMPUTER (louis-comp)
	 * These values can be added for multiple emphasis.
	 * @see <a href="http://liblouis.googlecode.com/svn/documentation/liblouis.html#lou_translateString">lou_translateString</a>
	 */
	protected static byte typeformFromTextTransform(TermList textTransform) {
		byte typeform = Typeform.PLAIN;
		for (Term<?> t : textTransform) {
			String tt = ((TermIdent)t).getValue();
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
	
	private static int mod(int a, int n) {
		int result = a % n;
		if (result < 0)
			result += n;
		return result;
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisTranslatorJnaImplProvider.class);
	
}
