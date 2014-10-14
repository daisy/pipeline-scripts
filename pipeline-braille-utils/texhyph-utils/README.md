texhyph-utils
=============

Building blocks related to
[Frank Liang's hyphenation algorithm][Liang] as used in [TeX][], and
re-implemented in [texhyphj][].

[library.xsl](src/main/resources/xml/library.xsl)
-------------------------------------------------

- `tex:hyphenate`: Hyphenate a text string using texhyphj.

Submodules
----------

- [`texhyph-core`](../texhyph/texhyph-core): A wrapper for texhyphj and
  a registry for hyphenation tables.
- [`texhyph-saxon`](../texhyph/texhyph-saxon): XPath bindings.


[Liang]: http://tug.org/docs/liang
[TeX]: http://www.tug.org
[texhyphj]: http://code.google.com/p/texhyphj
