liblouis-utils
===============

Building blocks related to the Braille translation library
[liblouis][].

[library.xsl](liblouis-utils/src/main/resources/xml/library.xsl)
-------------------------------------------------

- `louis:translate`: Translate a text string to Braille using liblouis.
- `louis:hyphenate`: Hyphenate a text string using liblouis.

[library.xpl](liblouis-utils/src/main/resources/xml/library.xpl)
-------------------------------------------------

- `louis:format`: Convert an XML document with inline Braille CSS to
  PEF using liblouisutdml.
- `louis:translate-mathml`: Translate a MathML document to Braille
  using liblouisutdml.

Submodules
----------

- [`liblouis-core`](liblouis-core): Java interface for liblouis and
  liblouisutdml, and a registry for liblouis tables.
- [`liblouis-native`](liblouis-native): The precompiled C
  libraries/executables.
- [`liblouis-calabash`](liblouis-calabash): XProc bindings.
- [`liblouis-saxon`](liblouis-saxon): XPath bindings.
- [`liblouis-tables`](liblouis-tables): The default translation tables
  that come with liblouis.
- [`liblouis-formatter`](liblouis-formatter): XProc step for
  converting XML with inline Braille CSS to PEF using liblouisutdml.
- [`liblouis-mathml`](liblouis-mathml): XProc step for translating
  MathML to Braille using liblouisutdml.

[liblouis]: https://code.google.com/p/liblouis
