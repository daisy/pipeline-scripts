package org.daisy.pipeline.braille.pef;

import org.daisy.braille.table.Table;
import org.daisy.pipeline.braille.common.Provider;

/**
 * Tables provided by instances of this class should also be available from
 * the BrailleUtils API.
 */
public interface TableProvider extends Provider<String,Table> {}
