pef-utils
=========

Building blocks related to [PEF][] (Portable Embosser Format).

[library.xsl](src/main/resources/xml/library.xsl)
-------------------------------------------------

- `pef:encode`: Re-encode a Braille string (Unicode Braille) using a
  specified character set.

[library.xpl](src/main/resources/xml/library.xpl)
-------------------------------------------------

- `pef:pef2text`: Convert a PEF document into a textual (ASCII-based)
  format.
- `pef:text2pef`: Convert an ASCII-based Braille format into PEF.
- `pef:validate`: Validate a PEF document.
- `pef:merge`: Merge PEF documents on volume- or section-level.
- `pef:store`: Store a PEF document to disk, possibly in an
  ASCII-based format or with an HTML preview.
- `pef:compare`: Compare two PEF documents.
- `x:pef-compare`: Compare two PEF documents as a custom [XProcSpec][] assertion.

Submodules
----------

- [`pef-calabash`](../pef/pef-calabash): XProc bindings for
  [BrailleUtils][].
- [`pef-saxon`](../pef/pef-saxon): XPath bindings for BrailleUtils.
- [`pef-to-html`](../pef/pef-to-html): XProc step for converting a PEF
  document into an HTML preview.

[PEF]: http://pef-format.org
[BrailleUtils]: http://code.google.com/p/brailleutils
[XProcSpec]: http://josteinaj.github.io/xprocspec
