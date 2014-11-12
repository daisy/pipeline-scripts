package org.daisy.pipeline.braille.common;

/**
 * A {@link org.daisy.pipeline.braille.common.Transform} that can transform
 * (translate) documents on the block level, i.e. only translating nodes
 * inside CSS blocks.
 *
 * The input is assumed to be a document with CSS style sheets inlined. CSS
 * must be processed according to <a
 * href="http://snaekobbi.github.io/braille-css-spec">http://snaekobbi.github.io/braille-css-spec</a>. All
 * resulting text nodes, as well as everything that will end up in CSS
 * generated content (such as attributes, CSS values, ...) must be braille
 * and, depending on the `hyphen' property, pre-hyphenated. Structure that is
 * important for further CSS processing must be preserved.
 */
public interface CSSBlockTransform extends Transform {}
