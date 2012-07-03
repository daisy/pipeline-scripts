package org.liblouis;

import com.sun.jna.ptr.IntByReference;

public class TranslationResult {

	private final String braille;

    TranslationResult(WideString outbuf, IntByReference outlen) {
        this.braille = outbuf.read(outlen.getValue());
    }
    
    public String getBraille() {
        return braille;
    }
}