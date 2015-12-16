package org.daisy.pipeline.braille.pef;

import org.daisy.braille.api.table.Table;
import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.Query;

/**
 * Tables provided by instances of this class should also be available from
 * the BrailleUtils API.
 */
public interface TableProvider extends Provider<Query,Table> {}
