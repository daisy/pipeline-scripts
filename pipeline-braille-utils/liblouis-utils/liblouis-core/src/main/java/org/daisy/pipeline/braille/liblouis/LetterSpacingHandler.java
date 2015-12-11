package org.daisy.pipeline.braille.liblouis;

import java.util.ArrayList;
import java.util.Map;

import com.google.common.base.Splitter;
import com.google.common.collect.Iterators;
import com.google.common.collect.Lists;
import com.google.common.collect.PeekingIterator;

import org.daisy.pipeline.braille.liblouis.impl.LiblouisTableJnaImplProvider;

import org.liblouis.TranslationException;
import org.liblouis.Translator;
import org.liblouis.TranslationResult;

import org.osgi.framework.BundleContext;
import org.osgi.framework.InvalidSyntaxException;
import org.osgi.framework.ServiceReference;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LetterSpacingHandler {
	
	private Translator table;
	
	public LetterSpacingHandler(Translator table) {
		this.table = table;
	}
	
	public LetterSpacingHandler(String tableQuery, BundleContext context) {
		try {
			for (ServiceReference<LiblouisTableJnaImplProvider> ref :
				     context.getServiceReferences(LiblouisTableJnaImplProvider.class, null)) {
				LiblouisTableJnaImplProvider provider = context.getService(ref);
				this.table = provider.get("(white-space)" + tableQuery).iterator().next().getTranslator();
				break; }}
		catch (InvalidSyntaxException e) {
			throw new RuntimeException(e); }
	}
	
	private final static Splitter.MapSplitter CSS_PARSER
	= Splitter.on(';').omitEmptyStrings().withKeyValueSeparator(Splitter.on(':').limit(2).trimResults());
	
	public static int letterSpacingFromInlineCSS(String style) {
		return letterSpacingFromInlineCSS(CSS_PARSER.split(style));
	}
	
	public static int letterSpacingFromInlineCSS(Map<String,String> style) {
		int letterSpacing = 0;
		for (String prop : style.keySet()) {
			String value = style.get(prop);
			if (prop.equals("letter-spacing") && (!value.equals("0")))
				letterSpacing = Integer.parseInt(value);
			else
				logger.warn("Inline CSS property {} not supported", prop);
			}
		return letterSpacing;
	}
	
	public interface LineIterator {
		public boolean hasNext();
		public String nextLine(int width);
	}
	
	// initially adapted from
	// org.daisy.pipeline.braille.dotify.impl.BrailleTranslatorFactoryServiceImpl$BrailleTranslatorImpl$BrailleTranslatorResultImpl
	// which is an implementation of Dotify's
	// org.daisy.dotify.api.translator.BrailleTranslatorResult
	private static class LineBreaker implements LineIterator {
		
		private LineBreaker(String text) {
			this(text, 1);
		}

		private LineBreaker(String text, int wordSpacing) {
			this.wordSpacing = wordSpacing;
			input = Iterators.peekingIterator(Lists.charactersOf(text).iterator());
		}
		
		public boolean hasNext() {
			fillBuffer(1);
			return charBuffer.length() > 0;
		}
		
		public String nextLine(int width) {
			if (!hasNext())
				throw new RuntimeException();
			return nextTranslatedRow(width, true);
		}
		
		private final char blankChar = ' ';
		// private final char blankChar = BRAILLE_PATTERN_BLANK;
		private final char hyphenChar = '-';
		// private final char hyphenChar = '\u2824';
		
		private final PeekingIterator<Character> input;
		private StringBuilder charBuffer = new StringBuilder();
		private boolean lastCharIsSpace = false;
		
		// soft wrap opportunities
		private ArrayList<Byte> swoBuffer = new ArrayList<Byte>();
		private final static byte NO_SOFT_WRAP = (byte)0x0;
		private final static byte SOFT_WRAP_WITH_HYPHEN = (byte)0x1;
		private final static byte SOFT_WRAP_WITHOUT_HYPHEN = (byte)0x3;
		private final static byte SOFT_WRAP_AFTER_SPACE = (byte)0x7;
		
		private final static char SHY = '\u00ad';
		private final static char ZWSP = '\u200b';
		private final static char SPACE = ' ';
		private final static char CR = '\r';
		private final static char LF = '\n';
		private final static char TAB = '\t';
		private final static char NBSP = '\u00a0';
		private final static char BRAILLE_PATTERN_BLANK = '\u2800';
		
		private final int wordSpacing;

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
					for (int i = 0; i < wordSpacing; i++) {
						charBuffer.append(blankChar);
						bufSize ++;
						swoBuffer.add(SOFT_WRAP_AFTER_SPACE);
					}
					lastCharIsSpace = true;
					break;
				case NBSP:
					charBuffer.append(blankChar);
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
		
		private void flushBuffer(int size) {
			charBuffer = new StringBuilder(charBuffer.substring(size));
			swoBuffer = new ArrayList<Byte>(swoBuffer.subList(size, swoBuffer.size()));
		}
		
		private String nextTranslatedRow(int limit, boolean force) {
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
			for (int i = limit + 1; i - 1 < bufSize && charBuffer.charAt(i - 1) == blankChar; i++)
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
						rv += hyphenChar;
					flushBuffer(i);
					return rv; }}
				
			// force hard break
			if (force) {
				String rv = charBuffer.substring(0, limit);
				flushBuffer(limit);
				return rv; }
				
			return "";
		}
	}

	public LineIterator translateWithSpacing(String text, int letterSpacing) {
		return translateWithSpacing(text, letterSpacing, 2 * letterSpacing + 1);
	}

	public LineIterator translateWithSpacing(String text, int letterSpacing, int wordSpacing) {
		byte[] boundaries = detectBoundaries(text);

		String out = "";
		String braille = "";
		try {
			TranslationResult result = table.translate(text, boundaries, null);
			braille = result.getBraille();
			boundaries = result.getHyphenPositions();

			for(int i = 0; i < braille.length() - 1; i++) {
				out += braille.charAt(i);
				if((4 & boundaries[i]) == 4) {
					for (int j = 0; j < letterSpacing; j++) {
						out += '\u00a0';
					}
				}
			}
			out += braille.charAt(braille.length() - 1);
		}
		catch (TranslationException e) {
			throw new RuntimeException(e); }
		return new LineBreaker(out, wordSpacing);
	}

	// 8 signifies a word beginning after a space 
	public static byte[] detectBoundaries(String text) {
		byte[] boundaries = new byte[text.length() - 1];

		for(int i = 0; i < boundaries.length; i++){
			if(Character.isLetter(text.charAt(i)) && Character.isLetter(text.charAt(i+1)))
				boundaries[i] |= 4;
			if((text.charAt(i) == '-') || (text.charAt(i+1) == '-'))
				boundaries[i] |= 4;
			if((text.charAt(i) == '\u00ad')) // SHY is not actual character, so boundary only after SHY
				boundaries[i] |= 4;
		}

		return boundaries;
	}
	
	//TODO: Handle numbers according to Finnish braille specification
	public static String textFromLetterSpacing(String text, int letterSpacing) {
		if (letterSpacing >= 1) {
			String spaces = "";
			for (int i = 0; i < letterSpacing; i++) {
				spaces += " ";
			}
			text = text.replaceAll(".(?=.)", String.format("$0%s", spaces));
		}
		if (letterSpacing < 0)
			logger.warn("letter-spacing: {} not supported, must be non-negative", letterSpacing);
		return text;
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LetterSpacingHandler.class);
	
}
