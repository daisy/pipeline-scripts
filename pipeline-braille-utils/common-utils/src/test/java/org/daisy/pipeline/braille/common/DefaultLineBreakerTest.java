package org.daisy.pipeline.braille.common;

import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

import org.daisy.pipeline.braille.common.AbstractBrailleTranslator.util.DefaultLineBreaker;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.BrailleTranslator.CSSStyledText;
import org.daisy.pipeline.braille.common.BrailleTranslator.LineBreakingFromStyledText;

public class DefaultLineBreakerTest {
	
	@Test
	public void testLineBreaking() {
		TestHyphenator hyphenator = new TestHyphenator();
		TestTranslator translator = new TestTranslator(hyphenator);
		assertEquals(
			"BUSS-\n" +
			"STOPP",
			fillLines(translator.transform(text("busstopp")), 5));
	}
	
	/* This will be the new Hyphenator interface */
	
	private static interface Hyphenator {
		
		public LineIterator hyphenate(Iterable<CSSStyledText> input);
		
		public interface LineIterator {
			public Iterable<CSSStyledText> nextLine(int limit, boolean force);
			public void mark();
			public void reset();
		}
	}
	
	/* A hyphenator mock for testing */
	
	private static class TestHyphenator implements Hyphenator {
		
		public LineIterator hyphenate(Iterable<CSSStyledText> styledText) {
			
			final Iterator<CSSStyledText> rest = styledText.iterator();
			final List<CSSStyledText> buffer = new ArrayList<CSSStyledText>();
			
			return new LineIterator() {
				
				CSSStyledText next = null;
				int position = 0;
				
				public Iterable<CSSStyledText> nextLine(int limit, boolean force) {
					List<CSSStyledText> line = new ArrayList<CSSStyledText>();
					int available = limit;
					while (available > 0 && hasNext()) {
						if (next == null) {
							if (position < buffer.size())
								next = buffer.get(position++);
							else
								next = rest.next(); }
						String text = next.getText();
						if (text.length() <= available) {
							line.add(next);
							available -= text.length();
							next = null; }
						else {
							String thisLine = "";
							String nextLine = "";
							boolean word = false;
							for (String segment : splitInclDelimiter(text, ON_SPACE_SPLITTER)) {
								if (available == 0)
									nextLine += segment;
								else if (segment.length() <= available) {
									thisLine += segment;
									available -= segment.length();
									word = !word; }
								else if (word) {
									String[] brokenWord = breakWord(segment, available, force);
									thisLine += brokenWord[0];
									nextLine += brokenWord[1];
									available = 0; }
								else {
									nextLine += segment;
									available = 0; }}
							line.add(new CSSStyledText(thisLine, next.getStyle()));
							next = new CSSStyledText(nextLine, next.getStyle()); }}
					return line;
				}
				
				public boolean hasNext() {
					return next != null || position < buffer.size() || rest.hasNext();
				}
				
				public void mark() {
					buffer.subList(0, position).clear();
					position = 0;
				}
				
				public void reset() {
					position = 0;
				}
			};
		}
		
		private static String[] breakWord(String word, int limit, boolean force) {
			if (limit >= 4 && word.equals("busstopp"))
				return new String[]{"buss","stopp"};
			else if (force)
				return new String[]{word.substring(0, limit), word.substring(limit)};
			else
				return new String[]{"", word};
		}
				
		private final static Pattern ON_SPACE_SPLITTER = Pattern.compile("\\s+");
				
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
	}
	
	/*
	 * A translator mock for testing.
	 *
	 * TODO: Improve DefaultLineBreaker so that it can be used for
	 * non-standard hyphenation and then use it in TestTranslator.
	 */
	
	private static class TestTranslator implements LineBreakingFromStyledText {
		
		private final Hyphenator hyphenator;
		
		private TestTranslator(Hyphenator hyphenator) {
			this.hyphenator = hyphenator;
		}
		
		// Simply transform to uppercase.
		private String translate(Iterable<CSSStyledText> text) {
			String result = "";
			for (CSSStyledText t : text)
				result += t.getText().toUpperCase();
			return result;
		}
		
		// Not using hyphenator at all yet, just translating all text in
		// advance and performing line breaking in a second step. The idea is
		// to extend DefaultLineBreaker with a callback function for
		// translating any text (basically to plugin the translate function
		// above).
		public BrailleTranslator.LineIterator transform(Iterable<CSSStyledText> styledText) {
			return new DefaultLineBreaker(translate(styledText), 1, ' ', '-');
		}
	}
	
	private Iterable<CSSStyledText> text(String... text) {
		List<CSSStyledText> styledText = new ArrayList<CSSStyledText>();
		for (String t : text)
			styledText.add(new CSSStyledText(t, ""));
		return styledText;
	}
	
	private static String fillLines(BrailleTranslator.LineIterator lines, int width) {
		StringBuilder sb = new StringBuilder();
		while (lines.hasNext()) {
			sb.append(lines.nextTranslatedRow(width, true));
			if (lines.hasNext())
				sb.append('\n'); }
		return sb.toString();
	}
}
