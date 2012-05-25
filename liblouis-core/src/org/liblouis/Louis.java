package org.liblouis;

import java.io.UnsupportedEncodingException;
import java.util.Arrays;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.NativeLibrary;
import com.sun.jna.ptr.IntByReference;

/**
 * Copyright (C) 2010 Swiss Library for the Blind, Visually Impaired and Print
 * Disabled
 *
 * This file is part of liblouis-javabindings.
 *
 * liblouis-javabindings is free software: you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

public class Louis {

	private static final String TABLE_SET_ID = "org.liblouis.DefaultLiblouisTableSet";

	private static final int OUT_IN_RATIO = 2;
	private static final char TXT_SOFT_HYPHEN = '\u00AD';
	private static final char BRL_SOFT_HYPHEN = 't';
	private static final String BRL_HARD_HYPHEN = "-m";

	private final int charSize;
	private final String encoding;
	private final LouisLibrary INSTANCE;

	private static Louis instance;

	/**
	 * public interface that calls Liblouis translate. As a workaround for a bug
	 * in LibLouis, we squeeze all whitespace into a single space before calling
	 * liblouis translate.
	 *
	 * @param trantab
	 * @param inbuf
	 * @return
	 */
	public static String translate(final String trantab, final String inbuf) {
		System.out.println(inbuf);
		return getInstance().translateString(trantab, squeeze(inbuf));
	}

	public static Louis getInstance() {
		if (instance == null) {
			instance = new Louis();
		}
		return instance;
	}

	public String version() {
		return INSTANCE.lou_version();
	}

	private Louis() {
		NativeLibrary.addSearchPath("louis", Activator.getNativePath().getAbsolutePath());
		Environment.setVariable("LOUIS_TABLEPATH",
				LiblouisTableRegistry.getLouisTablePath(TABLE_SET_ID), true);
		INSTANCE = (LouisLibrary) Native.loadLibrary(("louis"),
				LouisLibrary.class);
		charSize = INSTANCE.lou_charSize();
		switch (charSize) {
		case 2:
			encoding = "UTF-16LE";
			break;
		case 4:
			encoding = "UTF-32LE";
			break;
		default:
			throw new RuntimeException(
					"unsuported char size configured in liblouis: " + charSize);
		}
	}

	private String translateString(final String trantab, String inbuf) {
		try {
			if (inbuf.length() == 0) {
				return "";
			}
			HyphenatedString hyphenatedInbuf = null;
			boolean preHyphenated = inbuf.contains(String.valueOf(TXT_SOFT_HYPHEN)) ||
					                inbuf.contains(String.valueOf('-'));
			if (preHyphenated) {
				hyphenatedInbuf = new HyphenatedString(inbuf, TXT_SOFT_HYPHEN);
				inbuf = hyphenatedInbuf.getUnhyphenatedString();
			}
			final int inlen = inbuf.length();
			final int maxOutlen = OUT_IN_RATIO * inlen;
			final byte[] inbufArray = inbuf.getBytes(encoding);
			final byte[] outbufArray = new byte[charSize * maxOutlen];
			final IntByReference pInlen = new IntByReference(inlen);
			final IntByReference pOutlen = new IntByReference(maxOutlen);
			int[] outputPosArray = null;
			if (preHyphenated) {
				outputPosArray = new int[maxOutlen];
			}
			if (INSTANCE.lou_translate(trantab, inbufArray,
					pInlen, outbufArray, pOutlen, null,
					null, null, outputPosArray, null, 0) == 0) {
				throw new RuntimeException("Unable to complete translation");
			}
			int outlen = pOutlen.getValue();
			String outbuf = new String(outbufArray, 0, outlen * charSize, encoding);
			if (preHyphenated) {
				try {
					outputPosArray = Arrays.copyOf(outputPosArray, outlen);
					boolean[] inHyphenPos = hyphenatedInbuf.getHyphenPoints();
					// Add hyphen points after hard hyphens (= "-" followed and preceded by a letter)
					Matcher matcher = Pattern.compile("\\p{L}-\\p{L}").matcher(inbuf);
					while (matcher.find()) {
						inHyphenPos[matcher.start()+1] = true;
					}
					boolean[] outHyphenPos = convertHyphenPos(inHyphenPos, outputPosArray);
					HyphenatedString hyphenatedOutbuf = new HyphenatedString(outbuf, outHyphenPos);
					outbuf = hyphenatedOutbuf.getFullyHyphenatedString(BRL_SOFT_HYPHEN);
					// Replace 't' hyphen points after a hard hyphen by 'm'
					outbuf = outbuf.replaceAll("-" + BRL_SOFT_HYPHEN, BRL_HARD_HYPHEN);
				} catch (RuntimeException e) {
					// Don't hyphenate the text when an exception occurs (because of liblouis bug in outputPos).
				}
			}
			return outbuf;
		} catch (UnsupportedEncodingException e) {
			throw new RuntimeException("Encoding not supported by JVM:" + encoding);
		}
	}

	public void louFree() {
		INSTANCE.lou_free();
	}

	public static String squeeze(final String in) {
		return in.replaceAll("(?:\\p{Z}|\\s)+", " ");
	}

	private static boolean[] convertHyphenPos(boolean[] inHyphenPos, int[] inPosToOutPosMap) {
		boolean[] outHyphenPos = new boolean[inPosToOutPosMap.length - 1];
		try {
			int inPos = 0;
			for (int outPos=0; outPos<outHyphenPos.length; outPos++) {
				int newInPos = inPosToOutPosMap[outPos+1];
				if (newInPos < inPos) {
					// TODO fix liblouis bug in outputPos
					throw new RuntimeException("inPosToOutPosMap must be a non-negative, " +
							"non-decreasing function");
				} else if(newInPos > inPos) {
					inPos = newInPos;
					outHyphenPos[outPos] = inHyphenPos[inPos-1];
				} else {
					outHyphenPos[outPos] = false;
				}
			}
		} catch (ArrayIndexOutOfBoundsException e) {
			throw new RuntimeException("values of inPosToOutPosMap can not exceed " +
					"the length of inHyphenPos + 1");
		}
		return outHyphenPos;
	}

	interface LouisLibrary extends Library {

		public int lou_translateString(final String trantab,
				final byte[] inbuf, final IntByReference inlen,
				final byte[] outbuf, final IntByReference outlen,
				final byte[] typeform, final byte[] spacing, final int mode);

		public int lou_translate(final String trantab,
				final byte[] inbuf, final IntByReference inlen,
				final byte[] outbuf, final IntByReference outlen,
				final byte[] typeform, final byte[] spacing,
				final int[] outposPos, final int[] inposPos, final IntByReference cursorpos,
				final int mode);

		public int lou_charSize();

		public String lou_version();

		public String lou_free();
	}

	public static void main(final String[] args) {
		if (args.length != 2) {
			System.out.println("Usage: prog table(s) string");
			System.exit(1);
		}
		else {
			System.out.println(Louis.translate(args[0], args[1]));
		}

	}
}
