package org.daisy.pipeline.braille.dotify.impl;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Set;

import static com.google.common.collect.Iterators.concat;
import static com.google.common.collect.Iterators.singletonIterator;

import org.daisy.dotify.api.translator.BrailleFilter;
import org.daisy.dotify.api.translator.BrailleFilterFactory;
import org.daisy.dotify.api.translator.TextAttribute;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;
import org.daisy.dotify.api.translator.TranslationException;

import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.CSSStyledTextTransform;
import org.daisy.pipeline.braille.common.Provider.MemoizingProvider;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import org.daisy.pipeline.braille.common.Transform;
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
			BrailleTranslator translator = getBrailleTranslator(mode);
			return new BrailleFilterImpl(translator); }
		catch (NoSuchElementException e) {
			throw new TranslatorConfigurationException("Factory does not support " + locale + "/" + mode); }
	}
	
	private final static Pattern MODE = Pattern.compile("dotify:format(?: +(.*))?");
	
	private BrailleTranslator getBrailleTranslator(String mode) throws NoSuchElementException {
		Matcher m = MODE.matcher(mode);
		if (!m.matches())
			throw new NoSuchElementException();
		String query = m.group(1);
		if (query == null)
			query = "";
		else if (query.trim().equals("auto"))
			return defaultNumberTranslator;
		return brailleTranslatorProvider.get(query).iterator().next();
	}
	
	@Reference(
		name = "BrailleTranslatorProvider",
		unbind = "unbindBrailleTranslatorProvider",
		service = BrailleTranslator.Provider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	@SuppressWarnings(
		"unchecked" // safe cast to Transform.Provider<BrailleTranslator>
	)
	protected void bindBrailleTranslatorProvider(BrailleTranslator.Provider<?> provider) {
		brailleTranslatorProviders.add((Transform.Provider<BrailleTranslator>)provider);
		logger.debug("Adding BrailleTranslator provider: {}", provider);
	}
	
	protected void unbindBrailleTranslatorProvider(BrailleTranslator.Provider<?> provider) {
		brailleTranslatorProviders.remove(provider);
		brailleTranslatorProvider.invalidateCache();
		logger.debug("Removing BrailleTranslator provider: {}", provider);
	}
	
	private final List<Transform.Provider<BrailleTranslator>> brailleTranslatorProviders
	= new ArrayList<Transform.Provider<BrailleTranslator>>();
	
	private final MemoizingProvider<String,BrailleTranslator> brailleTranslatorProvider
	= memoize(dispatch(brailleTranslatorProviders));
	
	private final BrailleTranslator defaultNumberTranslator = new NumberBrailleTranslator();
	
	private final static char SHY = '\u00ad';
	private final static char ZWSP = '\u200b';
	private final static char SPACE = ' ';
	private final static char CR = '\r';
	private final static char LF = '\n';
	private final static char TAB = '\t';
	private final static char NBSP = '\u00a0';
	
	/**
	 * BrailleTranslator that can translate numbers.
	 *
	 * Requires that input text is a string consisting of only digits (for
	 * generating page numbers), braille pattern characters (U+28xx), white
	 * space characters (SPACE, NBSP, BRAILLE PATTERN BLANK) and
	 * pre-hyphenation characters (SHY and ZWSP).
	 */
	private static class NumberBrailleTranslator extends AbstractTransform implements BrailleTranslator {
		
		private final static Pattern VALID_INPUT = Pattern.compile("[0-9\u2800-\u28ff" + SHY + ZWSP + SPACE + LF + CR + TAB + NBSP + "]*");
		private final static Pattern NUMBER = Pattern.compile("[0-9]+");
		private final static String NUMSIGN = "\u283c";
		private final static String[] DIGIT_TABLE = new String[]{
			"\u281a","\u2801","\u2803","\u2809","\u2819","\u2811","\u280b","\u281b","\u2813","\u280a"};
		
		public String transform(String text) {
			
			// The input text must consist of only digits, braille pattern characters and
			// pre-hyphenation characters.
			if (!VALID_INPUT.matcher(text).matches())
				throw new RuntimeException("Invalid input: \"" + text + "\"");
			return translateNumbers(text);
		}
		
		public String[] transform(String[] text) {
			String[] result = new String[text.length];
			for (int i = 0; i < text.length; i++)
				result[i] = transform(text[i]);
			return result;
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
	 * BrailleFilter wrapper for a org.daisy.pipeline.braille.common.BrailleTranslator.
	 *
	 * Supports special variable assignments (in the form of "def:foo") and tests (in the form of
	 * "ifdef:foo" or "ifndef:foo") in text attributes in order to support special ad hoc handling
	 * of marker-references.
	 */
	private static class BrailleFilterImpl implements BrailleFilter {
		
		private final CSSStyledTextTransform translator;
		
		private BrailleFilterImpl(BrailleTranslator translator) {
			if (translator instanceof CSSStyledTextTransform)
				this.translator = (CSSStyledTextTransform)translator;
			else
				this.translator = new FakeCSSStyledTextTransform(translator);
		}
		
		private final static Pattern BRAILLE = Pattern.compile("[\u2800-\u28ff" + SHY + ZWSP + SPACE + NBSP + "]*");
		private final static Pattern TEXTATTR = Pattern.compile(
			"\\s*(?<special>(?<key>def|ifdef|ifndef|defifndef)\\s*:\\s*(?<var>[^\\s]+)(?:\\s+|$))?(?<css>.*)"
		);
		
		public String filter(Translatable specification) throws TranslationException {
			
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
			
			// Convert specification to text + CSS style and translate. Text attributes are assumed
			// to contain only CSS or special variable assignments/tests. CSS inheritance is assumed
			// to have been performed already.
			boolean hyphenating = specification.isHyphenating();
			TextAttribute attributes = specification.getAttributes();
			if (attributes == null) {
				
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
				else if (hyphenating)
					return translator.transform(text, "hyphens:auto");
				else
					return translator.transform(text); }
			else {
				List<String> segments = new ArrayList<String>();
				List<String> styles = new ArrayList<String>();
				Set<String> env = null;
				int i = 0;
				Iterator<TextAttribute> attrs = flattenAttributes(attributes);
				String segment = "";
				String style = "";
				while (attrs.hasNext()) {
					TextAttribute attr = attrs.next();
					String s = text.substring(i, i + attr.getWidth());
					String id = attr.getDictionaryIdentifier();
					if (id == null)
						id = "";
					Matcher m = TEXTATTR.matcher(id);
					m.matches();
					id = m.group("css");
					if (m.group("special") != null) {
						String key = m.group("key");
						String var = m.group("var");
						if (env == null)
							env = new HashSet<String>();
						if (key.equals("ifdef") && !env.contains(var)
						    || (key.equals("ifndef") || key.equals("defifndef")) && env.contains(var))
							s = "";
						if (key.equals("def") || key.equals("defifndef"))
							env.add(var); }
					if (hyphenating)
						id = "hyphens:auto; " + id;
					if (id.equals(style))
						segment += s;
					else {
						if (!segment.isEmpty()) {
							segments.add(segment);
							styles.add(style); }
						segment = s;
						style = id; }
					i += attr.getWidth(); }
				if (i != text.length())
					throw new RuntimeException("Coding error");
				if (!segment.isEmpty()) {
					segments.add(segment);
					styles.add(style); }
				return join(translator.transform(segments.toArray(new String[segments.size()]),
				                                 styles.toArray(new String[styles.size()]))); }
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
	
	/**
	 * CSSStyledTextTransform that wraps a BrailleTranslator and throws Exceptions when non-empty
	 * styles are encountered.
	 */
	private static class FakeCSSStyledTextTransform implements CSSStyledTextTransform {
		
		private final BrailleTranslator translator;
		
		public String getIdentifier() {
			return translator.getIdentifier();
		}
		
		private FakeCSSStyledTextTransform(BrailleTranslator translator) {
			this.translator = translator;
		}
		
		public String transform(String text) {
			return translator.transform(text);
		}
	
		public String[] transform(String[] text) {
			return translator.transform(text);
		}
		
		public String transform(String text, String style) {
			if (style != null && !style.isEmpty())
				throw new RuntimeException("Translator does not support style '" + style + "'");
			return translator.transform(text);
		}
	
		public String[] transform(String[] text, String[] style) {
			if (style != null)
				for (String s : style)
					if (s != null && !s.isEmpty())
						throw new RuntimeException("Translator does not support style '" + s + "'");
			return translator.transform(text);
		}
	
		public boolean isHyphenating() {
			return false;
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(BrailleFilterFactoryImpl.class);
	
}
