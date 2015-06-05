libhyphen-utils
===============

Building blocks related to the hyphenation library
[Hyphen][libhyphen], used in OpenOffice/LibreOffice, Firefox,
Chromium, etc.

[library.xsl](libhyphen-utils/src/main/resources/xml/library.xsl)
-------------------------------------------------

- `hyphen:hyphenate`: Hyphenate a text string using Hyphen.

Submodules
----------

- [`libhyphen-core`](libhyphen-core): Java interface for the Hyphen C
  library and a registry for hyphenation tables.
- [`libhyphen-native`](libhyphen-native): The precompiled C library.
- [`libhyphen-saxon`](libhyphen-saxon): XPath bindings.
- [`libhyphen-libreoffice-tables`](libhyphen-libreoffice-tables): A
  standard collection of hyphenation tables used in LibreOffice.


[libhyphen]: http://sourceforge.net/projects/hunspell
