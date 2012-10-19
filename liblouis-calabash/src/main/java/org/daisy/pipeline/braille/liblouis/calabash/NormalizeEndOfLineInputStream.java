package org.daisy.pipeline.braille.liblouis.calabash;

import java.io.FilterInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedList;
import java.util.NoSuchElementException;
import java.util.Queue;

public class NormalizeEndOfLineInputStream extends FilterInputStream {
	
	private static final int limit = 1024;
	private final Queue<Byte> available = new LinkedList<Byte>();
	
	public NormalizeEndOfLineInputStream(final InputStream in) {
		super(in);
	}
	
	public int available() throws IOException {
		fill();
		return available.size();
	}
	
	@Override
	public int read() throws IOException {
		fill();
		try {
			return available.remove();
		} catch (NoSuchElementException e) {
			return -1;
		}
	}
	
	@Override
	public int read(byte b[], int off, int len) throws IOException {
		fill();
		int i;
		for(i = 0; i < len; i++) {
			try {
				b[i] = available.remove();
			} catch (NoSuchElementException e) {
				break;
			}
		}
		return i;
	}
	
	@Override
	public long skip(long n) throws IOException {
		fill();
		int i;
		for(i = 0; i < n; i++) {
			try {
				available.remove();
			} catch (NoSuchElementException e) {
				break;
			}
		}
		return i;
	}
	
	private void fill() throws IOException {
		while(in.available() > 0 && available.size() <= limit) {
			byte data = (byte)in.read();
			if (data == '\r') continue;
			available.add(data);
		}
	}
}
