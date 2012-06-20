package org.daisy.pipeline.liblouis;

public class OSUtils {

	public static enum OSType { WINDOWS, MAC, LINUX, UNSPECIFIED };

	private static OSType osType;

	static {
		String osName = System.getProperty("os.name", "generic").toLowerCase();
		if (osName.startsWith("windows")) {
			osType = OSType.WINDOWS;
		} else if (osName.startsWith("mac") ||
				   osName.startsWith("darwin")) {
			osType = OSType.MAC;
		} else if (osName.startsWith("linux")) {
			osType = OSType.LINUX;
		} else {
			osType = OSType.UNSPECIFIED;
		}
	}

	public static OSType getOSType() {
		return osType;
	}

	public static boolean isWindows() {
	    return osType== OSType.WINDOWS;
	}

	public static boolean isMac() {
		return osType== OSType.MAC;
	}

	public static boolean isLinux() {
		return osType== OSType.LINUX;
	}
}
