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
              --source ~/Documents/tests_dtbook/Sample1.xml
              --output-dir ~/tmp/testdtbooktortf

On Windows:

    $ cli\dp2.exe dtbook-to-rtf
                  --source samples\dtbook\Sample1.xml
                  --output-dir C:\Pipeline2-Output

Input:

DTBook

~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE dtbook
  PUBLIC '-//NISO//DTD dtbook 2005-3//EN'
  'http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd'>
<dtbook version="2005-3" xml:lang="fr" xmlns="http://www.daisy.org/z3986/2005/dtbook/">
  <head>
    <meta content="AUTO-UID-5373731396833" name="dtb:uid"/>
    <meta content="fr-00000-packaged" name="dc:Identifier"/>
    <meta content="Test Dtbook To RTF" name="dc:Title"/>
    <meta content="Book Creator" name="dc:Creator"/>
    <meta content="Book Producer" name="dtb:producer"/>
    <meta content="Source Publisher" name="dtb:sourcePublisher"/>
    <meta content="Source Rights" name="dtb:sourceRights"/>
    <meta content="0-00000-000-0" name="dc:Identifier" scheme="ISBN"/>
    <meta content="1111111111" name="dc:Identifier" scheme="EAN"/>
    <meta content="2016-10-26" name="dc:Date"/>
    <meta content="Publisher" name="dc:Publisher"/>
    <meta content="fr-FR" name="dc:Language"/>
    <meta content="Text" name="dc:Type"/>
    <meta content="ANSI/NISO Z39.86-2005" name="dc:Format"/>
  </head>
  <book>
    <frontmatter>
      <doctitle>Test Dtbook To RTF</doctitle>
      <docauthor>Book Author</docauthor>
    </frontmatter>
    <bodymatter>
      <level1>
        <p>Content 1</p>
        <p>Content 2</p>
        <p>Content 3</p>
        <p xml:lang="en-GB">Titre original : &quot;Test Dtbook To RTF&quot;</p>
        <p>Copyright : Source Rights, 1998</p>
        <p>ISBN 0-00000-000-0</p>
        <p>Transcription en braille intégral : Bibliothèque Braille Intégral</p>
        <p>juin 2004</p>
      </level1>
      <level1>
        <h1>Content Before
          <sup>Sup</sup>
          Content After</h1>
          <p>Content</p>
      </level1>
    </bodymatter>
  </book>
</dtbook>
~~~

Output:

Rtf Source Code

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
\s9\sb200\sa200\qc\plain\fs32\b Test Dtbook To RTF\par
\pard \s10\sb100\sa100\li0\ri0\qc\plain\fs28\b Book Author\par
\pard \sect\sectd\sbkodd\pgnstarts1\pgnrestart\pgndec{\footer\qc\plain\chpgn\par}
\s0\plain\fs20 \sb100\sa100\li0\ri0 Content 1\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 Content 2\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 Content 3\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 Titre original : "Test Dtbook To RTF"\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 Copyright : Source Rights, 1998\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 ISBN 0-00000-000-0\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 Transcription en braille int\u233?gral : Biblioth\u232?que Braille Int\u233?gral\par
\pard \s0\plain\fs20 \sb100\sa100\li0\ri0 juin 2004\par
\pard {\*\bkmkstart d426e79}\s1\sb200\sa100\li0\ri0\plain\fs32\b \keep\keepn Content Before
          {\super Sup}
          Content After\plain\par
\pard {\*\bkmkend d426e79}\s0\plain\fs20 \sb100\sa100\li0\ri0 Content\par
\pard }
~~~

Rtf Appearance

~~~xhtml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1 plus MathML 2.0//EN" "http://www.w3.org/Math/DTD/mathml2/xhtml-math11-f.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><!--This file was converted to xhtml by LibreOffice - see http://cgit.freedesktop.org/libreoffice/core/tree/filter/source/xslt for the code.--><head profile="http://dublincore.org/documents/dcmi-terms/"><meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8"/><title xml:lang="en-US">- no title specified</title><meta name="DCTERMS.title" content="" xml:lang="en-US"/><meta name="DCTERMS.language" content="en-US" scheme="DCTERMS.RFC4646"/><meta name="DCTERMS.source" content="http://xml.openoffice.org/odf2xhtml"/><meta name="DCTERMS.provenance" content="" xml:lang="en-US"/><meta name="DCTERMS.subject" content="," xml:lang="en-US"/><link rel="schema.DC" href="http://purl.org/dc/elements/1.1/" hreflang="en"/><link rel="schema.DCTERMS" href="http://purl.org/dc/terms/" hreflang="en"/><link rel="schema.DCTYPE" href="http://purl.org/dc/dcmitype/" hreflang="en"/><link rel="schema.DCAM" href="http://purl.org/dc/dcam/" hreflang="en"/><style type="text/css">
  @page {  }
  table { border-collapse:collapse; border-spacing:0; empty-cells:show }
  td, th { vertical-align:top; font-size:12pt;}
  h1, h2, h3, h4, h5, h6 { clear:both }
  ol, ul { margin:0; padding:0;}
  li { list-style: none; margin:0; padding:0;}
  <!-- "li span.odfLiEnd" - IE 7 issue-->
  li span. { clear: both; line-height:0; width:0; height:0; margin:0; padding:0; }
  span.footnodeNumber { padding-right:1em; }
  span.annotation_style_by_filter { font-size:95%; font-family:Arial; background-color:#fff000;  margin:0; border:0; padding:0;  }
  * { margin:0;}
  .P1 { font-size:10pt; margin-bottom:0.176cm; margin-left:0cm; margin-right:0cm; margin-top:0.176cm; text-indent:0cm; font-family:Arial; writing-mode:page; text-align:center ! important; }
  .P3 { font-size:10pt; margin-bottom:0cm; margin-left:0cm; margin-right:0cm; margin-top:0cm; text-indent:0cm; font-family:Arial; writing-mode:page; }
  .P4 { font-size:10pt; margin-bottom:0.176cm; margin-left:0cm; margin-right:0cm; margin-top:0.176cm; text-indent:0cm; font-family:Arial; writing-mode:page; }
  .P5 { font-size:10pt; margin-bottom:0.176cm; margin-left:0cm; margin-right:0cm; margin-top:0.176cm; text-indent:0cm; font-family:Arial; writing-mode:page; }
  .P6 { font-size:14pt; font-weight:bold; margin-bottom:0.176cm; margin-left:0cm; margin-right:0cm; margin-top:0.176cm; text-align:center ! important; text-indent:0cm; font-family:Arial; writing-mode:page; }
  .P7 { font-size:16pt; font-weight:bold; margin-bottom:0.353cm; margin-left:0cm; margin-right:0cm; margin-top:0.353cm; text-align:center ! important; text-indent:0cm; font-family:Arial; writing-mode:page; }
  .T1 { font-family:Arial; }
  .T4 { vertical-align:super; font-size:58%;}
  <!-- ODF styles with no properties representable as CSS -->
  .Endnote_20_Symbol  { }
  </style></head><body dir="ltr" style="max-width:21.001cm;margin-top:2cm; margin-bottom:1.27cm; margin-left:2cm; margin-right:2cm; border-style:none; padding:0cm; background-color:transparent; "><p class="P7">Test Dtbook To RTF</p><p class="P6">Book Author</p><p class="P5">Content 1</p><p class="P4">Content 2</p><p class="P4">Content 3</p><p class="P4">Titre original : "Test Dtbook To RTF"</p><p class="P4">Copyright : Source Rights, 1998</p><p class="P4">ISBN 0-00000-000-0</p><p class="P4">Transcription en braille intégral : Bibliothèque Braille Intégral</p><p class="P4">juin 2004</p><p class="P3"><a id="d426e79"/>Content Before<span> </span><span> </span><span> </span><span> </span><span> <span class="T4">Sup</span></span><span> </span><span> </span><span> </span><span> </span><span> Content After</span></p><p class="P4">Content</p></body></html>
~~~

# See also

* [Rtf specifications](https://www.microsoft.com/en-us/download/details.aspx?id=10725)

