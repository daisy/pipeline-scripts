texhyph-utils
=============

Building blocks related to
[Frank Liang's hyphenation algorithm][Liang] as used in [TeX][], and
re-implemented in [texhyphj][].

[library.xsl](src/main/resources/xml/library.xsl)
-------------------------------------------------

- `tex:hyphenate`: Hyphenate a text string using texhyphj.
- `tex:lookup-table`: Find a hyphenation table based on a language
  code.
- `tex:resolve-table`: Resolve a hyphenation table URI.

Submodules
----------

- [`texhyph-core`](../texhyph/texhyph-core): A wrapper for texhyphj and
  a registry for hyphenation tables.
- [`texhyph-saxon`](../texhyph/texhyph-saxon): XPath bindings.


[Liang]: http://tug.org/docs/liang
[TeX]: http://www.tug.org
[texhyphj]: http://code.google.com/p/texhyphj
