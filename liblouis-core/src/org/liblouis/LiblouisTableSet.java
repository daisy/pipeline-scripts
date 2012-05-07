package org.liblouis;

import java.io.File;

public interface LiblouisTableSet {

	public String getIdentifier();

	public abstract File getPath();

	public File[] listTables();

}
