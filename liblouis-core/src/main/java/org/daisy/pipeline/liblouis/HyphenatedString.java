package org.daisy.pipeline.liblouis;

import java.text.CharacterIterator;
import java.text.StringCharacterIterator;
import java.util.Arrays;
import java.util.List;

public class HyphenatedString {

	/**
	 * The unhyphenated string
	 */
	private final String unhyphenatedString;
	
	/**
	 * An array of booleans which represent the possible hyphenation points.
	 * The length of the hyphen array is the length of the unhyphenated string minus 1.
	 * A hyphen at index i corresponds to characters i and i+1 of the string.
	 */
	private final boolean[] hyphenPoints;
	
	/**
	 * The default constructor
	 * @param unHyphenatedString The unhyphenated string
	 * @param hyphenPoints The hyphenation points
	 */
	public HyphenatedString(String unHyphenatedString, boolean[] hyphenPoints) {
		if (hyphenPoints.length != (unHyphenatedString.length() - 1)) {
			throw new RuntimeException("hyphenPoints.length must be equal to unHyphenatedString.length() - 1");
		}
		this.unhyphenatedString = unHyphenatedString;
		this.hyphenPoints = hyphenPoints;
	}
	
	/**
	 * Constructor which unhyphenates the given to extract the hyphenation points
	 * @param hyphenatedString The hyphenated string
	 * @param hyphen The character to be used as hyphenation mark
	 */
	public HyphenatedString(String hyphenatedString, char hyphen) {
		
		// TODO this might not work for all hyphen values
		unhyphenatedString = hyphenatedString.replaceAll(String.valueOf(hyphen), "");

		hyphenPoints = new boolean[unhyphenatedString.length() - 1];
		
		// first remove any leading hyphens
		CharacterIterator iter = new StringCharacterIterator(hyphenatedString);
		int i = 0;
		char c = iter.first();
		while (c != CharacterIterator.DONE) {
			if (c == hyphen) {
				c = iter.next();
			} else {
				c = iter.next();
				break;
			}
		}
		
		// extract hyphenation points
		boolean newSyllable = false;
		while(c != CharacterIterator.DONE) {
			if (c == hyphen) {
				newSyllable = true;
			} else {
				hyphenPoints[i++] = newSyllable;
				newSyllable = false;
			}
			c = iter.next();
		}
	}

	/**
	 * @return The unhyphenated string
	 */
	public String getUnhyphenatedString() {
		return unhyphenatedString;
	}
	
	/**
	 * @return All possible hyphenation points
	 */
	public boolean[] getHyphenPoints() {
		return Arrays.copyOf(hyphenPoints, hyphenPoints.length);
	}
	
	/**
	 * Returns the fully hyphenated string.
	 * The specified hyphen is inserted at all possible hyphenation points.
	 * @param hyphen The character to be used as hyphenation mark.
	 * @return The hyphenated string
	 */
	public String getFullyHyphenatedString(char hyphen) {
		
		// TODO what if string already contains hyphens?
		
		StringBuffer hyphenatedString = new StringBuffer();
		int i;
		for (i=0; i<hyphenPoints.length; i++) {
			hyphenatedString.append(unhyphenatedString.charAt(i));
			if (hyphenPoints[i]) {
				hyphenatedString.append(hyphen);
			}
		}
		hyphenatedString.append(unhyphenatedString.charAt(i));
		return hyphenatedString.toString();
	}
	
	/**
	 * Returns a list of all possible hyphenated strings.
	 * Each string in the list contains only 1 hyphen.
	 * This method is useful in the case of non-standard hyphenation.
	 * @param hyphen The character to be used as hyphenation mark
	 * @return The list of hyphenated strings
	 */
	public List<String> getPossibleHyphenations(char hyphen) {
		throw new UnsupportedOperationException("Not implemented yet");
	}
}
