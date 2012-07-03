package org.liblouis;

import com.sun.jna.Memory;
import com.sun.jna.NativeMapped;
import com.sun.jna.Pointer;
import com.sun.jna.PointerType;

public class WideString extends PointerType implements NativeMapped {

	private final int length;

    public WideString() {
    	this(0);
    }
    
    public WideString(int length) {
        this.length = length;
    }
    
    public WideString(String value) {
		this(value.length());
		write(value);
    }
    
    public WideString(Pointer p, int offset, int length) {
    	this(length);
    	setPointer(p.share(offset * WideChar.Constants.CHARSIZE));
    }
    
    public String read(int length) {
    	if (length > length()) {
    		throw new IllegalArgumentException("Maximum length is " + length());
    	}
    	try {
    		return new String(getPointer().getByteArray(0, length * WideChar.Constants.CHARSIZE), WideChar.Constants.ENCODING);
        } catch (Exception e) {
        	throw new RuntimeException(e);
        }
    }
    
    public void write(String value) {
    	if (value.length() > length) {
    		throw new IllegalArgumentException("Maximum string length is " + length());
    	}
    	try {
    		getPointer().write(0, value.getBytes(WideChar.Constants.ENCODING), 0, value.length() * WideChar.Constants.CHARSIZE);
    	} catch (Exception e) {
        	throw new RuntimeException(e);
        }
    }
    
    @Override
    public Pointer getPointer() {
    	Pointer p = super.getPointer();
    	if (p == null) {
	    	try {
		    	Memory memory = new Memory(length * WideChar.Constants.CHARSIZE);
				setPointer(memory);
				p = memory;
	    	} catch (Exception e) {
	    		throw new RuntimeException(e);
	    	}
    	}
		return p;
    }
    
    public int length() {
    	return length;
    }

    @Override
    public String toString() {
    	return read(length());
    }
	
}
