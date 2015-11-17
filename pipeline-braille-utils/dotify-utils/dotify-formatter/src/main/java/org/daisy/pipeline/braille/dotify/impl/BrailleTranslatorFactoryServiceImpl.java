package org.daisy.pipeline.braille.dotify.impl;

import java.util.ArrayList;
import java.util.Collection;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterators;
import com.google.common.collect.Lists;
import com.google.common.collect.PeekingIterator;

import org.daisy.dotify.api.translator.BrailleFilter;
import org.daisy.dotify.api.translator.BrailleTranslator;
import org.daisy.dotify.api.translator.BrailleTranslatorFactory;
import org.daisy.dotify.api.translator.BrailleTranslatorFactoryService;
import org.daisy.dotify.api.translator.BrailleTranslatorResult;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;
import org.daisy.dotify.api.translator.TranslatorSpecification;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

@Component(
	name = "org.daisy.pipeline.braille.dotify.impl.BrailleTranslatorFactoryServiceImpl",
	service = { BrailleTranslatorFactoryService.class }
)
public class BrailleTranslatorFactoryServiceImpl implements BrailleTranslatorFactoryService {
	
	private BrailleFilterFactoryImpl filterFactory;
	
	@Reference(
		name = "BrailleFilterFactoryImpl",
		service = BrailleFilterFactoryImpl.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindBrailleFilterFactoryImpl(BrailleFilterFactoryImpl filterFactory) {
		this.filterFactory = filterFactory;
	}
	
	public boolean supportsSpecification(String locale, String mode) {
		try {
			filterFactory.newFilter(locale, mode);
			return true; }
		catch (TranslatorConfigurationException e) {
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
			return new BrailleTranslatorImpl(mode, filterFactory.newFilter(locale, mode));
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
	 * BrailleTranslator with <a
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
	private static class BrailleTranslatorImpl implements BrailleTranslator {
		
		private final String mode;
		private final BrailleFilter filter;
		
		private BrailleTranslatorImpl(String mode, BrailleFilter filter) {
			this.mode = mode;
			this.filter = filter;
		}
		
		public BrailleTranslatorResult translate(Translatable input) throws TranslationException {
			return new BrailleTranslatorResultImpl(filter.filter(input));
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
}
