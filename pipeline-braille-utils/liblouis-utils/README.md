liblouis-utils
===============

Building blocks related to the Braille translation library
[liblouis][].

[library.xsl](src/main/resources/xml/library.xsl)
-------------------------------------------------

- `louis:translate`: Translate a text string to Braille using liblouis.
- `louis:hyphenate`: Hyphenate a text string using liblouis.

[library.xpl](src/main/resources/xml/library.xpl)
-------------------------------------------------

- `louis:format`: Convert an XML document with inline Braille CSS to
  PEF using liblouisutdml.
- `louis:translate-mathml`: Translate a MathML document to Braille
  using liblouisutdml.

Submodules
----------

- [`liblouis-core`](../liblouis/liblouis-core): Java interface for
  liblouis and liblouisutdml, and a registry for liblouis tables.
- [`liblouis-native`](../liblouis/liblouis-native): The precompiled C
  libraries/executables.
- [`liblouis-calabash`](../liblouis/liblouis-calabash): XProc bindings.
- [`liblouis-saxon`](../liblouis/liblouis-saxon): XPath bindings.
- [`liblouis-tables`](../liblouis/liblouis-tables): The default
  translation tables that come with liblouis.
- [`liblouis-formatter`](../liblouis/liblouis-formatter): XProc step
  for converting XML with inline Braille CSS to PEF using
  liblouisutdml.
- [`liblouis-mathml`](../liblouis/liblouis-mathml): XProc step for
  translating MathML to Braille using liblouisutdml.
- [`liblouis-pef`](../liblouis/liblouis-pef)
- [`liblouis-dotify`](../liblouis/liblouis-dotify)

[liblouis]: https://code.google.com/p/liblouis
