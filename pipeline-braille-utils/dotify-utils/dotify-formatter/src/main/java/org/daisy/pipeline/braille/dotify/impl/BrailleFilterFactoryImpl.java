package org.daisy.pipeline.braille.dotify.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Set;

import com.google.common.base.Optional;
import static com.google.common.collect.Iterables.size;
import static com.google.common.collect.Iterators.concat;
import static com.google.common.collect.Iterators.singletonIterator;

import org.daisy.dotify.api.translator.BrailleFilter;
import org.daisy.dotify.api.translator.BrailleFilterFactory;
import org.daisy.dotify.api.translator.TextAttribute;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;
import org.daisy.dotify.api.translator.TranslationException;

import org.daisy.pipeline.braille.common.AbstractBrailleTranslator;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.BrailleTranslator.CSSStyledText;
import org.daisy.pipeline.braille.common.BrailleTranslatorProvider;
import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import org.daisy.pipeline.braille.common.Query;
import static org.daisy.pipeline.braille.common.Query.util.query;
import static org.daisy.pipeline.braille.common.util.Strings.join;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.dotify.impl.BrailleFilterFactoryImpl",
	service = { BrailleFilterFactoryImpl.class }
)
public class BrailleFilterFactoryImpl implements BrailleFilterFactory {
	
	public BrailleFilter newFilter(String locale, String mode) throws TranslatorConfigurationException {
		try {
			BrailleTranslator.FromStyledTextToBraille translator = getBrailleTranslator(mode);
			return new BrailleFilterImpl(translator); }
		catch (NoSuchElementException e) {
			throw new TranslatorConfigurationException("Factory does not support " + locale + "/" + mode); }
	}
	
	private BrailleTranslator.FromStyledTextToBraille getBrailleTranslator(String mode) throws NoSuchElementException {
		Matcher m = MODE.matcher(mode);
		if (!m.matches())
			throw new NoSuchElementException();
		String query = m.group(1);
		if (query == null)
			query = "";
		else if (query.trim().equals("auto"))
			return defaultNumberTranslator.fromStyledTextToBraille();
		for (BrailleTranslator t : brailleTranslatorProvider.get(query(query)))
			try { return t.fromStyledTextToBraille(); }
			catch (UnsupportedOperationException e) {}
		throw new NoSuchElementException();
	}
	
	@Reference(
		name = "BrailleTranslatorProvider",
		unbind = "unbindBrailleTranslatorProvider",
		service = BrailleTranslatorProvider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	@SuppressWarnings(
		"unchecked" // safe cast to BrailleTranslatorProvider<BrailleTranslator>
	)
	protected void bindBrailleTranslatorProvider(BrailleTranslatorProvider<?> provider) {
		brailleTranslatorProviders.add((BrailleTranslatorProvider<BrailleTranslator>)provider);
		logger.debug("Adding BrailleTranslator provider: {}", provider);
	}
	
	protected void unbindBrailleTranslatorProvider(BrailleTranslatorProvider<?> provider) {
		brailleTranslatorProviders.remove(provider);
		brailleTranslatorProvider.invalidateCache();
		logger.debug("Removing BrailleTranslator provider: {}", provider);
	}
	
	private final List<BrailleTranslatorProvider<BrailleTranslator>> brailleTranslatorProviders
	= new ArrayList<BrailleTranslatorProvider<BrailleTranslator>>();
	
	private final Provider.util.MemoizingProvider<Query,BrailleTranslator> brailleTranslatorProvider
	= memoize(dispatch(brailleTranslatorProviders));
	
	private final BrailleTranslator defaultNumberTranslator = new NumberBrailleTranslator();
	
	/**
	 * BrailleTranslator that can translate numbers.
	 *
	 * Requires that input text is a string consisting of only digits (for
	 * generating page numbers), braille pattern characters (U+28xx), white
	 * space characters (SPACE, NBSP, BRAILLE PATTERN BLANK) and
	 * pre-hyphenation characters (SHY and ZWSP).
	 */
	private static class NumberBrailleTranslator extends AbstractBrailleTranslator implements BrailleTranslator {
		
		private final static Pattern VALID_INPUT = Pattern.compile("[0-9\u2800-\u28ff" + SHY + ZWSP + SPACE + LF + CR + TAB + NBSP + "]*");
		private final static Pattern NUMBER = Pattern.compile("[0-9]+");
		private final static String NUMSIGN = "\u283c";
		private final static String[] DIGIT_TABLE = new String[]{
			"\u281a","\u2801","\u2803","\u2809","\u2819","\u2811","\u280b","\u281b","\u2813","\u280a"};
		
		@Override
		public FromStyledTextToBraille fromStyledTextToBraille() {
			return fromStyledTextToBraille;
		}
		
		private final FromStyledTextToBraille fromStyledTextToBraille = new FromStyledTextToBraille() {
			public java.lang.Iterable<String> transform(java.lang.Iterable<CSSStyledText> styledText) {
				int size = size(styledText);
				String[] braille = new String[size];
				int i = 0;
				for (CSSStyledText t : styledText) {
					String style = t.getStyle();
					if (style != null && !style.isEmpty())
						throw new RuntimeException("Translator does not support style '" + style + "'");
					braille[i++] = NumberBrailleTranslator.this.transform(t.getText()); }
				return Arrays.asList(braille);
			}
		};
		
		private String transform(String text) {
			
			// The input text must consist of only digits, braille pattern characters and
			// pre-hyphenation characters.
			if (!VALID_INPUT.matcher(text).matches())
				throw new RuntimeException("Invalid input: \"" + text + "\"");
			return translateNumbers(text);
		}
		
		private static String translateNumbers(String text) {
			Matcher m = NUMBER.matcher(text);
			int idx = 0;
			StringBuilder sb = new StringBuilder();
			for (; m.find(); idx = m.end()) {
				sb.append(text.substring(idx, m.start()));
				sb.append(translateNaturalNumber(Integer.parseInt(m.group()))); }
			if (idx == 0)
				return text;
			sb.append(text.substring(idx));
			return sb.toString();
		}
		
		private static String translateNaturalNumber(int number) {
			StringBuilder sb = new StringBuilder();
			sb.append(NUMSIGN);
			if (number == 0)
				sb.append(DIGIT_TABLE[0]);
			while (number > 0) {
				sb.insert(1, DIGIT_TABLE[number % 10]);
				number = number / 10; }
			return sb.toString();
		}
	}
	
	/**
	 * BrailleFilter wrapper for a org.daisy.pipeline.braille.common.BrailleTranslator.FromStyledTextToBraille
	 *
	 * Supports special variable assignments (in the form of "def:foo") and tests (in the form of
	 * "ifdef:foo" or "ifndef:foo") in text attributes in order to support special ad hoc handling
	 * of marker-references.
	 */
	private static class BrailleFilterImpl implements BrailleFilter {
		
		private final BrailleTranslator.FromStyledTextToBraille translator;
		
		private BrailleFilterImpl(BrailleTranslator.FromStyledTextToBraille translator) {
			this.translator = translator;
		}
		
		public String filter(Translatable specification) throws TranslationException {
			
			if (specification.getAttributes() == null && specification.isHyphenating() == false) {
				
				String text = specification.getText();
				
				// If input text is a space, it will be user for calculating the
				// margin character (see org.daisy.dotify.formatter.impl.FormatterContext)
				if (" ".equals(text))
					return "\u2800";
			
				// If input text is "??", it will be used for creating a placeholder for content that
				// can not be computed yet (forward references, see org.daisy.dotify.formatter.impl.BlockContentManager).
				// Because normally this will never end up in the resulting PEF, it is okay to return it
				// untranslated.
				if ("??".equals(text))
					return "??";
			
				// Because (1) there is not yet a way to enable translation while formatting only for
				// certain document fragments and at the same time handle pre-translated text correctly
				// with respect to white space processing and line breaking, and (2) because this
				// function is possibly called twice, namely once from MarkerProcessorFactoryServiceImpl
				// and a second time from BrailleTranslatorFactoryServiceImpl, we perform a translation
				// when there are non-braille characters in the input, and use the text as-is
				// otherwise. This means that firstly, some (pre-)translated text will inevitably be
				// translated a second time. Translators must therefore handle braille in the
				// input. Secondly, text consisting of only braille will not be translated a second time
				// even if that was intended to happen.
				if (BRAILLE.matcher(text).matches())
					return text;
			}
			return join(translator.transform(cssStyledTextFromTranslatable(specification)));
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(BrailleFilterFactoryImpl.class);
	
	/* ============================== */
	/* SHARED CONSTANTS AND UTILITIES */
	/* ============================== */
	
	protected final static Pattern MODE = Pattern.compile("dotify:format(?: +(.*))?");
	
	private final static char SHY = '\u00ad';
	private final static char ZWSP = '\u200b';
	private final static char SPACE = ' ';
	private final static char CR = '\r';
	private final static char LF = '\n';
	private final static char TAB = '\t';
	private final static char NBSP = '\u00a0';
	
	protected final static Pattern BRAILLE = Pattern.compile("[\u2800-\u28ff" + SHY + ZWSP + SPACE + NBSP + "]*");
	
	private final static Pattern TEXTATTR = Pattern.compile(
		"\\s*(?<special>(?<key>def|ifdef|ifndef|defifndef)\\s*:\\s*(?<var>[^\\s]+)(?:\\s+|$))?(?<css>.*)"
	);
	
	/**
	 * Convert Translatable specification to text + CSS style. Text attributes are assumed to
	 * contain only CSS or special variable assignments/tests. CSS inheritance is assumed to have
	 * been performed already.
	 */
	protected static Iterable<CSSStyledText> cssStyledTextFromTranslatable(Translatable specification) {
		String text = specification.getText();
		boolean hyphenating = specification.isHyphenating();
		TextAttribute attributes = specification.getAttributes();
		if (attributes == null)
			return handleVariables(Optional.of(new CSSStyledText(text, hyphenating ? "hyphens:auto" : "")).asSet());
		else {
			List<CSSStyledText> segments = new ArrayList<CSSStyledText>();
			Iterator<TextAttribute> attrs = flattenAttributes(attributes);
			int i = 0;
			while (attrs.hasNext()) {
				TextAttribute attr = attrs.next();
				String segment = text.substring(i, i + attr.getWidth());
				String style = attr.getDictionaryIdentifier();
				if (style == null)
					style = "";
				if (hyphenating) {
					if (style.isEmpty())
						style = "hyphens: auto";
					else
						style += "; hyphens: auto"; }
				segments.add(new CSSStyledText(segment, style));
				i += attr.getWidth(); }
			if (i != text.length())
				throw new RuntimeException("Coding error");
			return handleVariables(segments); }
	}
	
	private static Iterable<CSSStyledText> handleVariables(Iterable<CSSStyledText> styledText) {
		List<CSSStyledText> segments = new ArrayList<CSSStyledText>();
		Set<String> env = null;
		String segment = "";
		String style = "";
		for (CSSStyledText st : styledText) {
			String t = st.getText();
			String s = st.getStyle();
			Matcher m = TEXTATTR.matcher(s);
			m.matches();
			s = m.group("css");
			if (m.group("special") != null) {
				String key = m.group("key");
				String var = m.group("var");
				if (env == null)
					env = new HashSet<String>();
				if (key.equals("ifdef") && !env.contains(var)
				    || (key.equals("ifndef") || key.equals("defifndef")) && env.contains(var))
					t = "";
				if (key.equals("def") || key.equals("defifndef"))
					env.add(var); }
			if (s.equals(style))
				segment += t;
			else {
				if (!segment.isEmpty())
					segments.add(new CSSStyledText(segment, style));
				segment = t;
				style = s; }}
		if (!segment.isEmpty())
			segments.add(new CSSStyledText(segment, style));
		return segments;
	}
	
	private static Iterator<TextAttribute> flattenAttributes(TextAttribute attributes) {
		if (attributes.hasChildren())
			return flattenAttributes(attributes.iterator());
		else
			return singletonIterator(attributes);
	}
	
	private static Iterator<TextAttribute> flattenAttributes(Iterator<TextAttribute> attributes) {
		if (attributes.hasNext())
			return concat(flattenAttributes(attributes.next()), flattenAttributes(attributes));
		else
			return attributes;
	}
}
