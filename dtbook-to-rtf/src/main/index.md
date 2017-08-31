<link rev="dp2:doc" href="resources/xml/dtbook-to-zedai.xpl"/>
<link rel="rdf:type" href="http://www.daisy.org/ns/pipeline/userdoc"/>
<meta property="dc:title" content="DTBook to RTF"/>

<!--
labels: [Type-Doc,Compoment-UserGuide,Component-Module,Component-Script]
sidebar: UserGuideToc
-->

# DTBook To RTF

The "DTBook to RTF" script will convert one DTBook XML
documents to a single rtf document .

The script will create:

* A single valid rtf file, written to disk.


## Table of contents

{{>toc}}

## Synopsis

{{>synopsis}}


## Example running from command line

On Linux and Mac OS X:

    $ cli/dp2 dtbook-to-rtf
              -source ~/Documents/tests_dtbook/Sample1.xml
              -output-dir ~/tmp/testdtbooktortf

On Windows:

    $ cli\dp2.exe dtbook-to-rtf
                  -source samples\dtbook\Sample1.xml
                  -output-dir C:\Pipeline2-Output

Input:

DTBook

~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE dtbook
  PUBLIC '-//NISO//DTD dtbook 2005-3//EN'
  'http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd'>
<dtbook version="2005-3" xml:lang="fr" xmlns="http://www.daisy.org/z3986/2005/dtbook/">
  <head>
    <meta content="AAAAA" name="dtb:uid"/>
    <meta content="AAAAA" name="dc:Identifier"/>
    <meta content="AAAAA" name="dc:Title"/>
    <meta content="AAAAA" name="dc:Creator"/>
    <meta content="AAAAA" name="dc:Creator"/>
    <meta content="AAAAA" name="dtb:producer"/>
    <meta content="AAAAAA" name="dtb:sourcePublisher"/>
    <meta content="sourceRights" name="dtb:sourceRights"/>
    <meta content="1111111111111" name="dc:Identifier" scheme="ISBN"/>
    <meta content="1111111111" name="dc:Identifier" scheme="EAN"/>
    <meta content="2016-10-26" name="dc:Date"/>
    <meta content="AAAAAA" name="dc:Publisher"/>
    <meta content="fr-FR" name="dc:Language"/>
    <meta content="Text" name="dc:Type"/>
    <meta content="ANSI/NISO Z39.86-2005" name="dc:Format"/>
  </head>
  <book>
    <frontmatter>
      <doctitle>AAAAAAA AAAAAAAAAAAAA</doctitle>
      <docauthor>AAAAAAAAA AAAAAAAAA</docauthor>
    </frontmatter>
    <bodymatter>
      <level1>
        <p>BBBBBBBBBB</p>
        <p>BBBBBb</p>
        <p>BBBBBb</p>
        <p xml:lang="en-GB">Titre original : &quot;Aaaaaaaaa&quot;</p>
        <p>Copyright : AAAAA, 1998</p>
        <p>ISBN 0-00000-000-0</p>
        <p>Transcription en braille intégral : Bibliothèque AAAAAAAAAA</p>
        <p>juin 2004</p>
      </level1>
      <level1>
        <h1>4
          <sup>CC</sup>
          DDDDDDDDDDDDDDDDDDD</h1>
          <p>EEEEEEEEEEEEEEEEEEEEEEEEEEE</p>
      </level1>
    </bodymatter>
  </book>
</dtbook>
~~~

Output:

RTF

~~~text
{\rtf1\ansi\ansicpg1252\deff0 {\fonttbl{\f0\fswiss Arial;}{\f1\fmodern Courier New;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;\red0\green0\blue255;}{\stylesheet{\s0\plain\fs20 \sb100\sa100\li0\ri0 \sbasedon222\snext0 Normal;}{\s1\sb200\sa100\li0\ri0\plain\fs32\b \sbasedon0\snext0 heading 1;}{\s2\sb200\sa100\li0\ri0\plain\fs28\b\i \sbasedon0\snext0 heading 2;}{\s3\sb200\sa100\li0\ri0\plain\fs24\b \sbasedon0\snext0 heading 3;}{\s4\sb200\sa100\li0\ri0\plain\fs22\b \sbasedon0\snext0 heading 4;}{\s5\sb200\sa100\li0\ri0\plain\fs22\i \sbasedon0\snext0 heading 5;}{\s6\sb200\sa100\li0\ri0\plain\fs20\i \sbasedon0\snext0 heading 6;}{\s7\plain\fs20\b \sbasedon0 strong;}{\s8\plain\fs20\b \sbasedon0 Emphazised;}{\s9\sb200\sa200\qc\plain\fs32\b \sbasedon0 title;}{\s10\sb100\sa100\li0\ri0\qc\plain\fs28\b \sbasedon0 subtitle;}{\s11\sb200\sa200\li0\ri0\plain\fs20\i \sbasedon0\snext0 citation;}{\s12\sb200\sa200\li750\ri750\box\brdrs\brdrw1\brsp250\plain\fs20 \sbasedon0\snext0 boxed;}}{\info{\title }
{\subject }
{\author }
{\company }
{\doccomm }
{\*\userprops {{\propname Identifier}\proptype30\staticval }
{{\propname Copyright}\proptype30\staticval }
}}
\deflang1024\paperw11905\paperh16838\psz9\margl1134\margr1134\margt1134\margb1134\deftab283\notabind\fet2\ftnnar\aftnnar
\sectd\sbkodd\pgnstarts1\pgnlcrm{\footer\qc\plain\chpgn\par}
\s9\sb200\sa200\qc\plain\fs32\b AAAAAAA AAAAAAAAAAAAA\par
\pard \s10\sb100\sa100\li0\ri0\qc\plain\fs28\b AAAAAAAAA AAAAAAAAA\par
\pard \sect\sectd\sbkodd\pgnstarts1\pgnrestart\pgndec{\footer\qc\plain\chpgn\par}
\s0\plain\fs20 \sb100\sa100\li0\ri0 BBBBBBBBBB\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 BBBBBb\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 BBBBBb\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 Titre original : "Aaaaaaaaa"\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 Copyright : AAAAA, 1998\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 ISBN 0-00000-000-0\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 Transcription en braille int\u233?gral : Biblioth\u232?que AAAAAAAAAA\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 juin 2004\par
\pard {\*\bkmkstart d426e81}\s1\sb200\sa100\li0\ri0\plain\fs32\b \keep\keepn 4
          {\super CC}
          DDDDDDDDDDDDDDDDDDD\plain\par
\pard {\*\bkmkend d426e81}\s0\plain\fs20 \sb100\sa100\li0\ri0 EEEEEEEEEEEEEEEEEEEEEEEEEEE\par
\pard }
~~~

# See also

* [Rtf specifications](https://www.microsoft.com/en-us/download/details.aspx?id=10725)

