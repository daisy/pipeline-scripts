<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:dtbook-to-pef" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                exclude-inline-prefixes="#all"
                name="main">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DTBook to PEF</h1>
        <p px:role="desc">Transforms a DTBook (DAISY 3 XML) document into a PEF.</p>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Bert Frees</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.sbs-online.ch/">SBS</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:bertfrees@gmail.com">bertfrees@gmail.com</a></dd>
        </dl>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Jostein Austvik Jacobsen</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.nlb.no/">NLB</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:josteinaj@gmail.com">josteinaj@gmail.com</a></dd>
        </dl>
    </p:documentation>

    <!-- ============ -->
    <!-- Main options -->
    <!-- ============ -->
    <p:input port="source" primary="true" px:name="source" px:media-type="application/x-dtbook+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Input DTBook</h2>
        </p:documentation>
    </p:input>
    <p:option name="stylesheet" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">CSS stylesheets</h2>
            <p px:role="desc">CSS style sheets to apply. Space separated list of absolute or relative URIs. Applied prior to any style sheets linked from or embedded in the source document.</p>
        </p:documentation>
    </p:option>
    <p:option name="transform" required="false" px:data-type="transform-query" select="'(translator:liblouis)(formatter:dotify)'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Transformer query</h2>
        </p:documentation>
    </p:option>
    <p:option name="ascii-table" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">ASCII braille table</h2>
            <p px:role="desc">The ASCII braille table, used for example to render BRF files.</p>
        </p:documentation>
    </p:option>
    <p:option name="include-preview" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Include preview</h2>
            <p px:role="desc">Whether or not to include a preview of the PEF in HTML.</p>
        </p:documentation>
    </p:option>
    <p:option name="include-brf" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Include BRF</h2>
            <p px:role="desc">Whether or not to include an ASCII version of the PEF.</p>
        </p:documentation>
    </p:option>
    
    <!-- =========== -->
    <!-- Page layout -->
    <!-- =========== -->
    <p:option name="page-width" required="false" px:type="integer" select="'40'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Page width</h2>
            <p px:role="desc">The number of columns available for printing.</p>
        </p:documentation>
    </p:option>
    <p:option name="page-height" required="false" px:type="integer" select="'25'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Page height</h2>
            <p px:role="desc">The number of rows available for printing.</p>
        </p:documentation>
    </p:option>
    <p:option name="predefined-page-formats" required="false" px:type="string" select="'A4'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Predefined page formats</h2>
            <p px:role="desc">Paper size format.
**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="left-margin" required="false" px:type="integer" select="'0'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Left margin</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="duplex" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Duplex</h2>
            <p px:role="desc">When enabled, will print on both sides of the paper.</p>
        </p:documentation>
    </p:option>
    
    <!-- =============== -->
    <!-- Headers/footers -->
    <!-- =============== -->
    <p:option name="levels-in-footer" required="false" px:type="integer" select="'6'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Headers/footers: Levels in footer</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    
    <!-- ============================== -->
    <!-- Translation/formatting of text -->
    <!-- ============================== -->
    <p:option name="main-document-language" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Main document language</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="contraction-grade" required="false" px:type="integer" select="'0'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Contraction grade</h2>
            <p px:role="desc">Contraction grades are either uncontracted (0) or grade 1-3.
**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="hyphenation-with-single-line-spacing" required="false" px:type="string" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Hyphenation with single line spacing</h2>
            <p px:role="desc">When enabled, will hyphenate content where single line spacing is used.
**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="hyphenation-with-double-line-spacing" required="false" px:type="string" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Hyphenation with double line spacing</h2>
            <p px:role="desc">When enabled, will hyphenate content where double line spacing is used.
**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="line-spacing" required="false" px:data-type="dtbook-to-pef:line-spacing" select="'single'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Line spacing</h2>
            <p px:role="desc">'single' or 'double' line spacing.
**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="tab-width" required="false" px:type="integer" select="'4'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Tab width
**Not implemented**</h2>
        </p:documentation>
    </p:option>
    <p:option name="capital-letters" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Capital letters</h2>
            <p px:role="desc">When enabled, will capitalize letters. When disabled, all letters are printed in lower case.
**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="accented-letters" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Accented letters</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="polite-forms" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Polite forms</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="downshift-ordinal-numbers" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Downshift ordinal numbers</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    
    <!-- ============== -->
    <!-- Block elements -->
    <!-- ============== -->
    <p:option name="include-captions" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Block elements: Include captions</h2>
            <p px:role="desc">When enabled, will include captions for images, tables, and so on.
**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="include-images" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Block elements: Include images</h2>
            <p px:role="desc">When enabled, will include the alt text of the images. When disabled, the images will be completely removed.
**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="include-image-groups" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Block elements: Include image groups</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="include-line-groups" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Block elements: Include line groups</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    
    <!-- =============== -->
    <!-- Inline elements -->
    <!-- =============== -->
    <p:option name="text-level-formatting" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Inline elements: Text-level formatting (emphasis, strong)</h2>
            <p px:role="desc">When enabled, text that is in bold or italics in the print version will be rendered in bold or italics in the braille version as well.
**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="include-note-references" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Inline elements: Include note references</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="include-production-notes" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Inline elements: Include production notes</h2>
            <p px:role="desc">When enabled, production notes are included in the content.
**Not implemented**</p>
        </p:documentation>
    </p:option>
    
    <!-- ============ -->
    <!-- Page numbers -->
    <!-- ============ -->
    <p:option name="show-braille-page-numbers" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page numbers: Show braille page numbers</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="show-print-page-numbers" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page numbers: Show print page numbers</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="force-braille-page-break" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page numbers: Force braille page break</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    
    <!-- ================= -->
    <!-- Table of contents -->
    <!-- ================= -->
    <p:option name="toc-depth" required="false" px:type="integer" select="'0'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Table of contents: Table of contents depth</h2>
            <p px:role="desc" xml:space="preserve">The depth of the table of contents hierarchy to include. '0' means no table of contents.

A table of contents will be generated from the heading elements present in the document: from `h1`
elements if the specified value for "depth" is 1, from `h1` and `h2` elements if the specified value
is 2, etc. The resulting table of contents has the following nested structure:

```
&lt;list id="generated-document-toc"&gt;
  &lt;li&gt;
      &lt;a href="#ch_1"&gt;Chapter 1&lt;/a&gt;
      &lt;list&gt;
          &lt;li&gt;
              &lt;a href="#ch_1_1"&gt;1.1&lt;/a&gt;
              ...
          &lt;/li&gt;
          &lt;li&gt;
              &lt;a href="#ch_1_2"&gt;1.2&lt;/a&gt;
              ...
          &lt;/li&gt;
          ...
      &lt;/list&gt;
  &lt;/li&gt;
  ...
&lt;/list&gt;
```

Another one of these is generated but with ID `generated-volume-toc`. `ch_1`, `ch_1_2` etc. are the
IDs of the heading elements from which the list was constructed, and the content of the links are
exact copies of the content of the heading elements. By default the list is not rendered. The list
should be styled and positioned with CSS. The following rules are included by default:

```
#generated-document-toc {
  flow: document-toc;
  display: -obfl-toc;
  -obfl-toc-range: document;
}

#generated-volume-toc {
  flow: volume-toc;
  display: -obfl-toc;
  -obfl-toc-range: volume;
}
```

This means that a document range table of contents is added to the named flow called "document-toc",
and a volume range table of contents is added to the named flow called "volume-toc". In order to
consume these named flows use the function `flow()`. For example, to position the document range
table of contents at the beginning of the first volume, and to repeat the volume range table of
content at the beginning of every other volume, include the following additional rules:

```
@volume {
  @begin {
    content: flow(volume-toc);
  }
}

@volume:first {
  @begin {
    content: flow(document-toc);
  }
}
```
</p>
        </p:documentation>
    </p:option>
    
    <!-- ================= -->
    <!-- Generated content -->
    <!-- ================= -->
    <p:option name="ignore-document-title" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Generated content: Ignore document title</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="include-symbols-list" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Generated content: Include symbols list</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="choice-of-colophon" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Generated content: Choice of colophon</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    
    <!-- ==================== -->
    <!-- Placement of content -->
    <!-- ==================== -->
    <p:option name="footnotes-placement" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Placement of content: Footnotes placement</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="colophon-metadata-placement" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Placement of content: Colophon/metadata placement</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="rear-cover-placement" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Placement of content: Rear cover placement</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    
    <!-- ======= -->
    <!-- Volumes -->
    <!-- ======= -->
    <p:option name="number-of-pages" required="false" px:type="integer" select="'50'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Volumes: Number of pages</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="maximum-number-of-pages" required="false" px:type="integer" select="'70'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Volumes: Maximum number of pages</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="minimum-number-of-pages" required="false" px:type="integer" select="'30'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Volumes: Minimum number of pages</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    
    <!-- ============= -->
    <!-- Miscellaneous -->
    <!-- ============= -->
    <p:option name="sbsform-macros" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Miscellaneous: SBSForm macros</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    
    <!-- ======= -->
    <!-- Outputs -->
    <!-- ======= -->
    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Output directory</h2>
            <p px:role="desc">Directory for storing result files.</p>
        </p:documentation>
    </p:option>
    <p:option name="temp-dir" required="false" px:output="temp" px:type="anyDirURI" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Temporary directory</h2>
            <p px:role="desc">Directory for storing temporary files.</p>
        </p:documentation>
    </p:option>
    
    <!-- ======= -->
    <!-- Imports -->
    <!-- ======= -->
    <p:import href="dtbook-to-pef.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    
    <!-- =============== -->
    <!-- CREATE TEMP DIR -->
    <!-- =============== -->
    <px:tempdir name="temp-dir">
        <p:with-option name="href" select="if ($temp-dir!='') then $temp-dir else $output-dir"/>
    </px:tempdir>
    <p:sink/>
    
    <!-- ============= -->
    <!-- DTBOOK TO PEF -->
    <!-- ============= -->
    <px:dtbook-to-pef.convert default-stylesheet="http://www.daisy.org/pipeline/modules/braille/dtbook-to-pef/css/default.css">
        <p:input port="source">
            <p:pipe step="main" port="source"/>
        </p:input>
        <p:with-option name="stylesheet" select="$stylesheet"/>
        <p:with-option name="transform" select="$transform"/>
        <p:with-option name="temp-dir" select="string(/c:result)">
            <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
        <p:with-option name="page-width" select="$page-width"/>
        <p:with-option name="page-height" select="$page-height"/>
        <!-- <p:with-option name="predefined-page-formats" select="$predefined-page-formats"/> -->
        <!-- <p:with-option name="left-margin" select="$left-margin"/> -->
        <p:with-option name="duplex" select="$duplex"/>
        <!-- <p:with-option name="levels-in-footer" select="$levels-in-footer"/> -->
        <!-- <p:with-option name="main-document-language" select="$main-document-language"/> -->
        <!-- <p:with-option name="contraction-grade" select="$contraction-grade"/> -->
        <!-- <p:with-option name="hyphenation-with-single-line-spacing" select="$hyphenation-with-single-line-spacing"/> -->
        <!-- <p:with-option name="hyphenation-with-double-line-spacing" select="$hyphenation-with-double-line-spacing"/> -->
        <!-- <p:with-option name="line-spacing" select="$line-spacing"/> -->
        <!-- <p:with-option name="tab-width" select="$tab-width"/> -->
        <!-- <p:with-option name="capital-letters" select="$capital-letters"/> -->
        <!-- <p:with-option name="accented-letters" select="$accented-letters"/> -->
        <!-- <p:with-option name="polite-forms" select="$polite-forms"/> -->
        <!-- <p:with-option name="downshift-ordinal-numbers" select="$downshift-ordinal-numbers"/> -->
        <!-- <p:with-option name="include-captions" select="$include-captions"/> -->
        <!-- <p:with-option name="include-images" select="$include-images"/> -->
        <!-- <p:with-option name="include-image-groups" select="$include-image-groups"/> -->
        <!-- <p:with-option name="include-line-groups" select="$include-line-groups"/> -->
        <!-- <p:with-option name="text-level-formatting" select="$text-level-formatting"/> -->
        <!-- <p:with-option name="include-note-references" select="$include-note-references"/> -->
        <!-- <p:with-option name="include-production-notes" select="$include-production-notes"/> -->
        <!-- <p:with-option name="show-braille-page-numbers" select="$show-braille-page-numbers"/> -->
        <!-- <p:with-option name="show-print-page-numbers" select="$show-print-page-numbers"/> -->
        <!-- <p:with-option name="force-braille-page-break" select="$force-braille-page-break"/> -->
        <p:with-option name="toc-depth" select="$toc-depth"/>
        <!-- <p:with-option name="ignore-document-title" select="$ignore-document-title"/> -->
        <!-- <p:with-option name="include-symbols-list" select="$include-symbols-list"/> -->
        <!-- <p:with-option name="choice-of-colophon" select="$choice-of-colophon"/> -->
        <!-- <p:with-option name="footnotes-placement" select="$footnotes-placement"/> -->
        <!-- <p:with-option name="colophon-metadata-placement" select="$colophon-metadata-placement"/> -->
        <!-- <p:with-option name="rear-cover-placement" select="$rear-cover-placement"/> -->
        <!-- <p:with-option name="number-of-pages" select="$number-of-pages"/> -->
        <!-- <p:with-option name="maximum-number-of-pages" select="$maximum-number-of-pages"/> -->
        <!-- <p:with-option name="minimum-number-of-pages" select="$minimum-number-of-pages"/> -->
        <!-- <p:with-option name="sbsform-macros" select="$sbsform-macros"/> -->
    </px:dtbook-to-pef.convert>
    
    <!-- ========= -->
    <!-- STORE PEF -->
    <!-- ========= -->
    <pef:store>
        <p:with-option name="output-dir" select="$output-dir"/>
        <p:with-option name="name" select="replace(p:base-uri(/),'^.*/([^/]*)\.[^/\.]*$','$1')">
            <p:pipe step="main" port="source"/>
        </p:with-option>
        <p:with-option name="brf-table" select="if ($ascii-table!='') then $ascii-table
                                                else concat('(locale:',(/*/@xml:lang,'und')[1],')')">
            <p:pipe step="main" port="source"/>
        </p:with-option>
        <p:with-option name="include-preview" select="$include-preview"/>
        <p:with-option name="include-brf" select="$include-brf"/>
    </pef:store>
    
</p:declare-step>
