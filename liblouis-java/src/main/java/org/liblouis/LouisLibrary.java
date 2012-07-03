package org.liblouis;

import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.NativeLibrary;
import com.sun.jna.ptr.IntByReference;

public interface LouisLibrary extends Library {

	public static final String JNA_LIBRARY_NAME = "louis";
	public static final NativeLibrary JNA_NATIVE_LIB = 
			NativeLibrary.getInstance(LouisLibrary.JNA_LIBRARY_NAME);
	public static final LouisLibrary INSTANCE = 
			(LouisLibrary)Native.loadLibrary(LouisLibrary.JNA_LIBRARY_NAME, LouisLibrary.class);
	
	public int lou_translate(final String tableList, final WideString inbuf, final IntByReference inlen,
			final WideString outbuf, final IntByReference outlen, final byte typeform[], final byte spacing[],
			final int[] outputPos, final int[] inputPos, final IntByReference cursorPos, final int mode);
	
	public int lou_charSize();
}
