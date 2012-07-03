package org.liblouis;

import com.sun.jna.ptr.IntByReference;

public class Translator {

	private static final LouisLibrary LIBLOUIS = LouisLibrary.INSTANCE;

	private static WideString INPUT_BUFFER = new WideString(512);
	private static WideString OUTPUT_BUFFER = new WideString(1024);
	
	private final String tables;
	
	public Translator(String tables) {
		this.tables = tables;
	}

	public TranslationResult translate(String text) throws Exception {
		
		text = squeeze(text);
		
		try {
			INPUT_BUFFER.write(text);
		} catch (IllegalArgumentException e) {
			INPUT_BUFFER = new WideString(text);
		}
		final IntByReference inLen = new IntByReference(text.length());
		final IntByReference outLen = new IntByReference();
		
		while (true) {
			outLen.setValue(OUTPUT_BUFFER.length());
			if (LIBLOUIS.lou_translate(tables, INPUT_BUFFER, inLen, OUTPUT_BUFFER, outLen,
					null, null, null, null, null, 0) == 0) {
				throw new RuntimeException("Unable to complete translation");
			}
			boolean outputBufferFull = (outLen.getValue() >= OUTPUT_BUFFER.length());
			if (!outputBufferFull) {
				break;
			}
			if (outputBufferFull) {
				OUTPUT_BUFFER = new WideString(2 * OUTPUT_BUFFER.length());
			}
		}
		
		return new TranslationResult(OUTPUT_BUFFER, outLen);
	}

	public static String squeeze(final String in) {
		return in.replaceAll("(?:\\p{Z}|\\s)+", " ");
	}
}
