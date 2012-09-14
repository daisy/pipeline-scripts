package org.daisy.pipeline.braille;

import java.net.URL;

public interface TablePath {

	public URL getIdentifier();

	public URL getPath();

	public URL getManifest();
	
	public boolean hasTable(String tableName);

}
