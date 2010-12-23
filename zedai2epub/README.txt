###############################################################################
###             DAISY Pipeline 2 - ZedAI to EPUB module                     ###
###############################################################################



About the ZedAI to EPUB module
-------------------------------------------------------------------------------

The 'ZedAI to EPUB' module  converts a single ZedAI document into an EPUB file set. It only supports a subset of the ZedAI book profile, and creates an EPUB 2.0 publication.

For more information on the ongoing development, see:
 - the ZedAI to EPUB wiki page:
   http://code.google.com/p/daisy-pipeline/wiki/ZedAI2EPUB
 - the ZedAI to HTML wiki page:
   http://code.google.com/p/daisy-pipeline/wiki/ZedAI2HTML



Demo
-------------------------------------------------------------------------------

Convert the provided "Alice in Wonderland" sample ZedAI book document to EPUB:

On Linux/Mac:

$ zedai2epub.sh -o alice.epub sample/alice.xml

On Windows:

> zedai2epub.bat -o alice.epub sample\alice.xml

You can optionally check that the produced EPUB is valid using EpubCheck,
available at: http://code.google.com/p/epubcheck/



Known limitations
-------------------------------------------------------------------------------

Following is a (non-exhaustive) list of current limitations.

ZedAI compliance
 - does not check the profile URI
 - does not check feature declarations
 - supports only a subset of the ZedAI book profile (v0.7)

Handling of satellite files:
 - only files referenced from zedai:object elements are copied through
 - remote files are not downloaded

Metadata extraction:
 - only the title, author, language and identifier are retrieved.
 - metadata is only retrieved from @property attributes using the DC vocab

NCX Creation
 - Only sections which have a header, bibliography, glossary and toc are
   included in the NCX
 - items to be added to the NCX are currently hardcoded

ZedAI to HTML
 - creates XHTML 1.1
 - supports only a very limited subset of ZedAI (only the elements used in the
   "Alice" sample book)


