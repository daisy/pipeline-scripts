libhyphen-utils
===============

Building blocks related to the hyphenation library
[Hyphen][libhyphen], used in OpenOffice/LibreOffice, Firefox,
Chromium, etc.

[library.xsl](src/main/resources/xml/library.xsl)
-------------------------------------------------

- `hyphen:hyphenate`: Hyphenate a text string using Hyphen.
- `hyphen:lookup-table`: Find a hyphenation table based on a language
  code.
- `hyphen:resolve-table`: Resolve a hyphenation table URI.

Submodules
----------

- [`libhyphen-core`](../libhyphen/libhyphen-core): Java interface for
  the Hyphen C library and a registry for hyphenation tables.
- [`libhyphen-native`](../libhyphen/libhyphen-native): The precompiled C
  library.
- [`libhyphen-saxon`](../libhyphen/libhyphen-saxon): XPath bindings.
- [`libhyphen-libreoffice-tables`](../libhyphen/libhyphen-libreoffice-tables):
  A standard collection of hyphenation tables used in LibreOffice.


[libhyphen]: http://sourceforge.net/projects/hunspell
