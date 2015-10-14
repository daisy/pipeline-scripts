package org.daisy.pipeline.braille.dotify.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterators;
import com.google.common.collect.Lists;
import com.google.common.collect.PeekingIterator;

import org.daisy.dotify.api.translator.BrailleTranslatorFactory;
import org.daisy.dotify.api.translator.BrailleTranslatorFactoryService;
import org.daisy.dotify.api.translator.BrailleTranslatorResult;
import org.daisy.dotify.api.translator.TextAttribute;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;
import org.daisy.dotify.api.translator.TranslatorSpecification;

import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.CSSStyledTextTransform;
import org.daisy.pipeline.braille.common.Provider.MemoizingProvider;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.Transform.AbstractTransform;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.dotify.impl.BrailleTranslatorFactoryServiceImpl",
	service = { BrailleTranslatorFactoryService.class }
)
public class BrailleTranslatorFactoryServiceImpl implements BrailleTranslatorFactoryService {
	
	protected final static Pattern MODE = Pattern.compile("dotify:format(?: +(.*))?");
	
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
	
	public boolean supportsSpecification(String locale, String mode) {
		try {
			return getBrailleTranslator(mode) != null; }
		catch (NoSuchElementException e) {
			return false; }
	}
	
	public Collection<TranslatorSpecification> listSpecifications() {
		return ImmutableList.of();
	}
	
	public BrailleTranslatorFactory newFactory() {
		return new BrailleTranslatorFactoryImpl();
	}
	
	public <T> void setReference(Class<T> c, T reference) throws TranslatorConfigurationException {}
	
	private class BrailleTranslatorFactoryImpl implements BrailleTranslatorFactory {
		public BrailleTranslatorImpl newTranslator(String locale, String mode) throws TranslatorConfigurationException {
			BrailleTranslator translator = getBrailleTranslator(mode);
			if (translator != null)
				return new BrailleTranslatorImpl(mode, translator);
			throw new TranslatorConfigurationException("Factory does not support " + locale + "/" + mode);
		}
	}
	
	private final static char SHY = '\u00ad';
	private final static char ZWSP = '\u200b';
	private final static char SPACE = ' ';
	private final static char CR = '\r';
	private final static char LF = '\n';
	private final static char TAB = '\t';
	private final static char NBSP = '\u00a0';
	private final static char BRAILLE_PATTERN_BLANK = '\u2800';
	
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
	 * org.daisy.dotify.api.translator.BrailleTranslator wrapper for a
	 * org.daisy.pipeline.braille.common.BrailleTranslator, with <a
	 * href="http://snaekobbi.github.io/braille-css-spec/#h3_white-space-processing">white
	 * space processing</a> and <a
	 * href="http://snaekobbi.github.io/braille-css-spec/#line-breaking">line
	 * breaking</a> according to braille CSS.
	 *
	 * White space is normalised. Preserved spaces must have been converted to
	 * no-break spaces and preserved line feeds must have been converted to
	 * &lt;obfl:br/&gt;.
	 *
	 * Through setHyphenating() the translator can be made to perform
	 * automatic hyphenation or not. Regardless of this setting, hyphenation
	 * characters (SHY and ZWSP) in the input are always used in line
	 * breaking. These hyphenation characters must have been removed from the
	 * input when no breaking within words is desired at all (hyphens:none).
	 */
	private static class BrailleTranslatorImpl implements org.daisy.dotify.api.translator.BrailleTranslator {
		
		private final String mode;
		private final BrailleTranslator translator;
		private final CSSStyledTextTransform asCSSTranslator;
		
		private BrailleTranslatorImpl(String mode, BrailleTranslator translator) {
			this.mode = mode;
			this.translator = translator;
			if (translator instanceof CSSStyledTextTransform)
				asCSSTranslator = (CSSStyledTextTransform)translator;
			else
				asCSSTranslator = null;
		}
		
		private boolean hyphenating = false;
		
		public void setHyphenating(boolean value) {
			if (value && asCSSTranslator == null)
				throw new RuntimeException("'hyphens:auto' is not supported");
			hyphenating = value;
		}
		
		public boolean isHyphenating() {
			return hyphenating;
		}
		
		private final static Pattern BRAILLE = Pattern.compile("[\u2800-\u28ff" + SHY + ZWSP + SPACE + NBSP + "]*");
		
		public BrailleTranslatorResult translate(String text) {
			
			// If input text is a space, it will be user for calculating the
			// margin character (see org.daisy.dotify.formatter.impl.FormatterContext)
			if (" ".equals(text))
				return new BrailleTranslatorResult() {
					public String nextTranslatedRow(int l, boolean f) { throw new UnsupportedOperationException(); }
					public int countRemaining() { throw new UnsupportedOperationException(); }
					public boolean hasNext() { throw new UnsupportedOperationException(); }
					public String getTranslatedRemainder() { return "\u2800"; }};
			
			// If input text is "??", it will be used for creating a placeholder for content that
			// can not be computed yet (forward references, see org.daisy.dotify.formatter.impl.BlockContentManager).
			// Because normally this will never end up in the resulting PEF, it is okay to return it
			// untranslated.
			if ("??".equals(text))
				return new BrailleTranslatorResultImpl(text);
			
			// Because there is not yet a way to enable translation while formatting only for certain document fragments
			// and at the same time handle pre-translated text correctly with respect to white space processing and line
			// breaking (translate='pre-translated' currently delegates to a non-configurable bypass translator), we
			// perform a translation when there are non-braille characters in the input, and use the text as-is
			// otherwise. This means that firstly, some pre-translated text will inevitably be translated a second
			// time. Translators must therefore handle braille in the input. Secondly, text consisting of only braille
			// will not be translated a second time even if that was intended to happen.
			String braille = BRAILLE.matcher(text).matches() ? text :
			                 hyphenating                     ? asCSSTranslator.transform(text, "hyphens:auto") :
			                                                   translator.transform(text);
			
			return new BrailleTranslatorResultImpl(braille);
		}
		
		public BrailleTranslatorResult translate(String text, String locale) {
			return translate(text);
		}
		
		public BrailleTranslatorResult translate(String text, TextAttribute atts) {
			return translate(text);
		}
		
		public BrailleTranslatorResult translate(String text, String locale, TextAttribute attributes) throws TranslationException {
			return translate(text);
		}
		
		public String getTranslatorMode() {
			return mode;
		}
		
		// FIXME: should not be hard-coded
		private final static char HYPHENATE_CHARACTER = '\u2824';
		
		private final static byte NO_SOFT_WRAP = (byte)0x0;
		private final static byte SOFT_WRAP_WITH_HYPHEN = (byte)0x1;
		private final static byte SOFT_WRAP_WITHOUT_HYPHEN = (byte)0x3;
		private final static byte SOFT_WRAP_AFTER_SPACE = (byte)0x7;
		
		private static class BrailleTranslatorResultImpl implements BrailleTranslatorResult {
			
			private final PeekingIterator<Character> input;
			
			private BrailleTranslatorResultImpl(String text) {
				this.input = Iterators.peekingIterator(Lists.charactersOf(text).iterator());
			}
			
			private StringBuilder charBuffer = new StringBuilder();
			
			/**
			 * Array with soft wrap opportunity info
			 * - SPACE, LF, CR, TAB and ZWSP create normal soft wrap opportunities
			 * - SHY create soft wrap opportunities that insert a hyphen glyph
			 * - normal soft wrap opportunities override soft wrap opportunities that insert a hyphen glyph
			 *
			 * @see <a href="http://snaekobbi.github.io/braille-css-spec/#h3_line-breaking">Braille CSS – § 9.4 Line Breaking</a>
			 */
			private ArrayList<Byte> swoBuffer = new ArrayList<Byte>();
			
			private boolean lastCharIsSpace = false;
			
			/**
			 * Fill the character and soft wrap opportunity buffers while normalising and collapsing spaces
			 * - until the buffers are at least 'size' long
			 * - or until the remaining input is empty
			 * - and while the remaining input starts with SPACE, LF, CR, TAB, NBSP or BRAILLE PATTERN BLANK
			 */
			private void fillBuffer(int size) {
				int bufSize = charBuffer.length();
				loop: while (input.hasNext()) {
					char next = input.peek();
					switch (next) {
					case SHY:
						if (bufSize > 0)
							swoBuffer.set(bufSize - 1, (byte)(swoBuffer.get(bufSize - 1) | SOFT_WRAP_WITH_HYPHEN));
						lastCharIsSpace = false;
						break;
					case ZWSP:
						if (bufSize > 0)
							swoBuffer.set(bufSize - 1, (byte)(swoBuffer.get(bufSize - 1) | SOFT_WRAP_WITHOUT_HYPHEN));
						lastCharIsSpace = false;
						break;
					case SPACE:
					case LF:
					case CR:
					case TAB:
					case BRAILLE_PATTERN_BLANK:
						if (lastCharIsSpace)
							break;
						if (bufSize > 0)
							swoBuffer.set(bufSize - 1, (byte)(swoBuffer.get(bufSize - 1) | SOFT_WRAP_WITHOUT_HYPHEN));
						charBuffer.append(BRAILLE_PATTERN_BLANK);
						bufSize ++;
						swoBuffer.add(SOFT_WRAP_AFTER_SPACE);
						lastCharIsSpace = true;
						break;
					case NBSP:
						charBuffer.append(BRAILLE_PATTERN_BLANK);
						bufSize ++;
						swoBuffer.add(NO_SOFT_WRAP);
						lastCharIsSpace = false;
						break;
					default:
						if (bufSize >= size) break loop;
						charBuffer.append(next);
						bufSize ++;
						swoBuffer.add(NO_SOFT_WRAP);
						lastCharIsSpace = false; }
					input.next(); }
			}
			
			/**
			 * Flush the first 'size' elements of the character and soft wrap opportunity buffers
			 * Assumes that 'size &lt;= charBuffer.length()'
			 */
			private void flushBuffer(int size) {
				charBuffer = new StringBuilder(charBuffer.substring(size));
				swoBuffer = new ArrayList<Byte>(swoBuffer.subList(size, swoBuffer.size()));
			}
			
			public String nextTranslatedRow(int limit, boolean force) {
				fillBuffer(limit + 1);
				int bufSize = charBuffer.length();
				
				// no need to break if remaining text is shorter than line
				if (bufSize <= limit) {
					String rv = charBuffer.toString();
					charBuffer.setLength(0);
					swoBuffer.clear();
					return rv; }
				
				// break at SPACE or ZWSP
				if ((swoBuffer.get(limit - 1) & SOFT_WRAP_WITHOUT_HYPHEN) == SOFT_WRAP_WITHOUT_HYPHEN) {
					String rv = charBuffer.substring(0, limit);
					
					// strip leading SPACE in remaining text
					while (limit < bufSize && swoBuffer.get(limit) == SOFT_WRAP_AFTER_SPACE) limit++;
					flushBuffer(limit);
					return rv; }
				
				// try to break later if the overflowing characters are blank
				for (int i = limit + 1; i - 1 < bufSize && charBuffer.charAt(i - 1) == BRAILLE_PATTERN_BLANK; i++)
					if ((swoBuffer.get(i - 1) & SOFT_WRAP_WITHOUT_HYPHEN) == SOFT_WRAP_WITHOUT_HYPHEN) {
						String rv = charBuffer.substring(0, limit);
						flushBuffer(i);
						return rv; }
				
				// try to break sooner
				for (int i = limit - 1; i > 0; i--) {
					
					// break at SPACE, ZWSP or SHY
					if (swoBuffer.get(i - 1) > 0) {
						String rv = charBuffer.substring(0, i);
						
						// insert hyphen glyph at SHY
						if (swoBuffer.get(i - 1) == 0x1)
							rv += HYPHENATE_CHARACTER;
						flushBuffer(i);
						return rv; }}
				
				// force hard break
				if (force) {
					String rv = charBuffer.substring(0, limit);
					flushBuffer(limit);
					return rv; }
				
				return "";
			}
			
			public String getTranslatedRemainder() {
				while (input.hasNext()) fillBuffer(1000);
				return charBuffer.toString();
			}
			
			public int countRemaining() {
				while (input.hasNext()) fillBuffer(1000);
				return charBuffer.length();
			}
			
			public boolean hasNext() {
				fillBuffer(1);
				return charBuffer.length() > 0;
			}
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(BrailleTranslatorFactoryServiceImpl.class);
	
}
