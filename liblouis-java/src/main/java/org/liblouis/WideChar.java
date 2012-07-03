package org.liblouis;

import com.sun.jna.NativeMapped;

public interface WideChar extends NativeMapped {

	public static abstract class Constants {
		
		public static final int CHARSIZE;
		public static final String ENCODING;
	    
	    static {
	    	CHARSIZE = LouisLibrary.INSTANCE.lou_charSize();
	    	switch (CHARSIZE) {
	    		case 2:
	    			ENCODING = "UTF-16LE";
	    			break;
	    		case 4:
	    			ENCODING = "UTF-32LE";
	    			break;
	    		default:
	    			throw new RuntimeException();
			}
	    }
	}
}
