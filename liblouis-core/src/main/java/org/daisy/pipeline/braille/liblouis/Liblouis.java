package org.daisy.pipeline.braille.liblouis;

import java.net.URL;

public interface Liblouis {

	/**
	 * @param tables The fully qualified table URL
	 */
	public String translate(URL table, String text);

}
