package org.daisy.pipeline.liblouis;

public interface Liblouis {

	/**
	 * @param tables The fully qualified table URL
	 */
	public String translate(String tables, String text);

}
