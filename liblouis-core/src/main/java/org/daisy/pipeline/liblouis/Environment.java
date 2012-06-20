package org.daisy.pipeline.liblouis;

import com.sun.jna.Library;
import com.sun.jna.Native;

public class Environment {

	private static CLibrary libc = (CLibrary) Native.loadLibrary("c", CLibrary.class);

	public static int setVariable(String name, String value, boolean overwrite) {
		return libc.setenv(name, value, overwrite?1:0);
	}

	public interface CLibrary extends Library {
		public int setenv(String name, String value, int overwrite);
	}
}
