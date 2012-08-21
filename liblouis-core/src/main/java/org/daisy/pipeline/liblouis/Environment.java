package org.daisy.pipeline.liblouis;

import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.Platform;

public class Environment {

	private static Object libc;
	
	static {
		switch (Platform.getOSType()) {
			case Platform.MAC:
			case Platform.LINUX:
				libc = Native.loadLibrary("c", LinuxCLibrary.class);
				break;
			case Platform.WINDOWS:
				libc = Native.loadLibrary("msvcrt", WindowsCLibrary.class);
				break;
		}
	}

	public static int setVariable(String name, String value, boolean overwrite) {
		if (libc instanceof LinuxCLibrary) {
			return ((LinuxCLibrary)libc).setenv(name, value, overwrite?1:0);
		} else {
			return ((WindowsCLibrary)libc)._putenv(name + "=" + value);
		}
	}

	public interface LinuxCLibrary extends Library {
		public int setenv(String name, String value, int overwrite);
	}
	
	public interface WindowsCLibrary extends Library {
		public int _putenv(String string);
	}
}
