package org.daisy.pipeline.braille.common;

/**
 * A {@link org.daisy.pipeline.braille.common.TextTransform} that can
 * translate and render CSS styled documents. The input document is assumed to
 * have CSS style sheets inlined. CSS must be processed according to <a
 * href="http://snaekobbi.github.io/braille-css-spec">http://snaekobbi.github.io/braille-css-spec</a>. The
 * resulting braille document must be a PEF.
 */
public interface CSSStyledDocumentTransform extends Transform {}
