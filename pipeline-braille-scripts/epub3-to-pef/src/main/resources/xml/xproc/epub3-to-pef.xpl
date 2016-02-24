<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-to-pef" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:opf="http://www.idpf.org/2007/opf"
                exclude-inline-prefixes="#all"
                name="main">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">EPUB 3 to PEF</h1>
        <p px:role="desc">Transforms a EPUB 3 publication into a PEF.</p>
    </p:documentation>

    <!-- ============ -->
    <!-- Main options -->
    <!-- ============ -->
    <p:option name="epub" required="true" px:type="anyFileURI" px:sequence="false" px:media-type="application/epub+zip application/oebps-package+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Input EPUB 3</h2>
            <p px:role="desc">The EPUB you want to convert to braille. You may alternatively use the EPUB package document (the OPF-file) if your input is a unzipped/"exploded" version of an EPUB.</p>
        </p:documentation>
    </p:option>
    <p:option name="stylesheet" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">CSS stylesheets</h2>
            <p px:role="desc">CSS style sheets to apply. Space separated list of absolute or relative URIs. Applied prior to any style sheets linked from or embedded in the source document.</p>
        </p:documentation>
    </p:option>
    <p:option name="transform" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Transformer query</h2>
            <pre><code class="default">(translator:liblouis)(formatter:dotify)</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="ascii-table" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">ASCII braille table</h2>
            <p px:role="desc">The ASCII braille table, used for example to render BRF files.</p>
        </p:documentation>
    </p:option>
    <p:option name="include-preview" px:type="boolean" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Include preview</h2>
            <p px:role="desc">Whether or not to include a preview of the PEF in HTML.</p>
            <pre><code class="default">false</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="include-brf" px:type="boolean" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Include BRF</h2>
            <p px:role="desc">Whether or not to include an ASCII version of the PEF.</p>
            <pre><code class="default">false</code></pre>
        </p:documentation>
    </p:option>
    
    <!-- =========== -->
    <!-- Page layout -->
    <!-- =========== -->
    <p:option name="page-width" px:type="integer" select="'28'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Page width</h2>
            <p px:role="desc">The number of columns available for printing.</p>
        </p:documentation>
    </p:option>
    <p:option name="page-height" px:type="integer" select="'29'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Page height</h2>
            <p px:role="desc">The number of rows available for printing.</p>
        </p:documentation>
    </p:option>
    <p:option name="predefined-page-formats" px:type="string" select="'A4'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Predefined page formats</h2>
            <p px:role="desc">Paper size format.</p>
        </p:documentation>
    </p:option>
    <p:option name="left-margin" px:type="integer" select="'0'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Left margin</h2>
        </p:documentation>
    </p:option>
    <p:option name="duplex" px:type="string" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Duplex</h2>
            <p px:role="desc">When enabled, will print on both sides of the paper.</p>
        </p:documentation>
    </p:option>
    
    <!-- =============== -->
    <!-- Headers/footers -->
    <!-- =============== -->
    <p:option name="levels-in-footer" px:type="integer" select="'6'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Headers/footers: Levels in footer</h2>
        </p:documentation>
    </p:option>
    
    <!-- ============================== -->
    <!-- Translation/formatting of text -->
    <!-- ============================== -->
    <p:option name="main-document-language" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Main document language</h2>
        </p:documentation>
    </p:option>
    <p:option name="contraction-grade" px:type="integer" select="'0'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Contraction grade</h2>
            <p px:role="desc">Contraction grades are either uncontracted (0) or grade 1-3.</p>
        </p:documentation>
    </p:option>
    <p:option name="hyphenation-with-single-line-spacing" px:type="string" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Hyphenation with single line spacing</h2>
            <p px:role="desc">When enabled, will hyphenate content where single line spacing is used.</p>
        </p:documentation>
    </p:option>
    <p:option name="hyphenation-with-double-line-spacing" px:type="string" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Hyphenation with double line spacing</h2>
            <p px:role="desc">When enabled, will hyphenate content where double line spacing is used.</p>
        </p:documentation>
    </p:option>
    <p:option name="line-spacing" px:data-type="epub3-to-pef:line-spacing" select="'single'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Line spacing</h2>
            <p px:role="desc">'single' or 'double' line spacing.</p>
        </p:documentation>
    </p:option>
    <p:option name="tab-width" px:type="integer" select="'4'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Tab width</h2>
        </p:documentation>
    </p:option>
    <p:option name="capital-letters" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Capital letters</h2>
            <p px:role="desc">When enabled, will capitalize letters. When disabled, all letters are printed in lower case.</p>
        </p:documentation>
    </p:option>
    <p:option name="accented-letters" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Accented letters</h2>
        </p:documentation>
    </p:option>
    <p:option name="polite-forms" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Polite forms</h2>
        </p:documentation>
    </p:option>
    <p:option name="downshift-ordinal-numbers" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Downshift ordinal numbers</h2>
        </p:documentation>
    </p:option>
    
    <!-- ============== -->
    <!-- Block elements -->
    <!-- ============== -->
    <p:option name="include-captions" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Block elements: Include captions</h2>
            <p px:role="desc">When enabled, will include captions for images, tables, and so on.</p>
        </p:documentation>
    </p:option>
    <p:option name="include-images" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Block elements: Include images</h2>
            <p px:role="desc">When enabled, will include the alt text of the images. When disabled, the images will be completely removed.</p>
        </p:documentation>
    </p:option>
    <p:option name="include-image-groups" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Block elements: Include image groups</h2>
        </p:documentation>
    </p:option>
    <p:option name="include-line-groups" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Block elements: Include line groups</h2>
        </p:documentation>
    </p:option>
    
    <!-- =============== -->
    <!-- Inline elements -->
    <!-- =============== -->
    <p:option name="text-level-formatting" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Inline elements: Text-level formatting (emphasis, strong)</h2>
            <p px:role="desc">When enabled, text that is in bold or italics in the print version will be rendered in bold or italics in the braille version as well.</p>
        </p:documentation>
    </p:option>
    <p:option name="include-note-references" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Inline elements: Include note references</h2>
        </p:documentation>
    </p:option>
    <p:option name="include-production-notes" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Inline elements: Include production notes</h2>
            <p px:role="desc">When enabled, production notes are included in the content.</p>
        </p:documentation>
    </p:option>
    
    <!-- ============ -->
    <!-- Page numbers -->
    <!-- ============ -->
    <p:option name="show-braille-page-numbers" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page numbers: Show braille page numbers</h2>
        </p:documentation>
    </p:option>
    <p:option name="show-print-page-numbers" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page numbers: Show print page numbers</h2>
        </p:documentation>
    </p:option>
    <p:option name="force-braille-page-break" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page numbers: Force braille page break</h2>
        </p:documentation>
    </p:option>
    
    <!-- ================= -->
    <!-- Table of contents -->
    <!-- ================= -->
    <p:option name="toc-depth" px:type="integer" select="'0'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Table of contents: Table of contents depth</h2>
            <p px:role="desc" xml:space="preserve">The depth of the table of contents hierarchy to include. '0' means no table of contents.

A table of contents will be generated from the heading elements present in the document: from `h1`
elements if the specified value for "depth" is 1, from `h1` and `h2` elements if the specified value
is 2, etc. The resulting table of contents has the following nested structure:

```
&lt;list id="generated-toc"&gt;
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

`ch_1`, `ch_1_2` etc. are the IDs of the heading elements from which the list was constructed, and
the content of the links are exact copies of the content of the heading elements. By default the
list is not rendered. The list should be styled and positioned with CSS. The following rules are
included by default:

```
#generated-toc {
  flow: document-toc;
  display: -obfl-toc;
  -obfl-toc-range: document;
}

#generated-toc::duplicate {
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
    <p:option name="ignore-document-title" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Generated content: Ignore document title</h2>
        </p:documentation>
    </p:option>
    <p:option name="include-symbols-list" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Generated content: Include symbols list</h2>
        </p:documentation>
    </p:option>
    <p:option name="choice-of-colophon" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Generated content: Choice of colophon</h2>
        </p:documentation>
    </p:option>
    
    <!-- ==================== -->
    <!-- Placement of content -->
    <!-- ==================== -->
    <p:option name="footnotes-placement" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Placement of content: Footnotes placement</h2>
        </p:documentation>
    </p:option>
    <p:option name="colophon-metadata-placement" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Placement of content: Colophon/metadata placement</h2>
        </p:documentation>
    </p:option>
    <p:option name="rear-cover-placement" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Placement of content: Rear cover placement</h2>
        </p:documentation>
    </p:option>
    
    <!-- ======= -->
    <!-- Volumes -->
    <!-- ======= -->
    <p:option name="number-of-pages" px:type="integer" select="'50'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Volumes: Number of pages</h2>
        </p:documentation>
    </p:option>
    <p:option name="maximum-number-of-pages" px:type="integer" select="'70'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Volumes: Maximum number of pages</h2>
        </p:documentation>
    </p:option>
    <p:option name="minimum-number-of-pages" px:type="integer" select="'30'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Volumes: Minimum number of pages</h2>
        </p:documentation>
    </p:option>
    
    <!-- ============= -->
    <!-- Miscellaneous -->
    <!-- ============= -->
    <p:option name="sbsform-macros" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Miscellaneous: SBSForm macros</h2>
        </p:documentation>
    </p:option>
    <p:option name="apply-document-specific-stylesheets" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Apply document-specific CSS</h2>
            <p px:role="desc" xml:space="preserve">If this option is enabled, any pre-existing CSS in the EPUB with `media="embossed"` will be used.

The input EPUB may already contain CSS that applies to embossed media (using media="embossed").
Such document-specific CSS takes precedence over any CSS attached when running this script.

For instance, if the EPUB already contains the rule `p { padding-left: 2; }`,
and using this script the rule `p#docauthor { padding-left: 4; }` is provided, then the
`padding-left` property will get the value `2` because that's what was defined in the EPUB,
even though the provided CSS is more specific.
            </p>
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
    <p:option name="temp-dir" px:output="temp" px:type="anyDirURI" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Temporary directory</h2>
            <p px:role="desc">Directory for storing temporary files.</p>
        </p:documentation>
    </p:option>
    
    <!-- ======= -->
    <!-- Imports -->
    <!-- ======= -->
    <p:import href="epub3-to-pef.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/zip-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl"/>
    
    <!-- =============== -->
    <!-- CREATE TEMP DIR -->
    <!-- =============== -->
    <px:tempdir name="temp-dir">
        <p:with-option name="href" select="if ($temp-dir!='') then $temp-dir else $output-dir"/>
    </px:tempdir>
    
    <!--
        Until v1.10 of DP2 is released, we cannot point into ZIP files using URIs.
        So for now we unzip the entire EPUB before continuing.
        See: https://github.com/daisy/pipeline-modules-common/pull/73
    -->
    <px:message message="Loading EPUB"/>
    <p:choose name="load">
        <p:when test="ends-with(lower-case($epub),'.epub')">
            <p:output port="fileset.out" primary="true"/>
            <p:output port="in-memory.out" sequence="true">
                <p:pipe port="in-memory.out" step="unzip"/>
            </p:output>
            
            <px:message severity="DEBUG" message="EPUB is in a ZIP container; unzipping"/>
            <px:unzip-fileset name="unzip">
                <p:with-option name="href" select="$epub"/>
                <p:with-option name="unzipped-basedir" select="concat(string(/c:result),'epub/')">
                    <p:pipe step="temp-dir" port="result"/>
                </p:with-option>
            </px:unzip-fileset>
            <px:fileset-store name="load.stored">
                <p:input port="fileset.in">
                    <p:pipe port="fileset.out" step="unzip"/>
                </p:input>
                <p:input port="in-memory.in">
                    <p:pipe port="in-memory.out" step="unzip"/>
                </p:input>
            </px:fileset-store>
            <p:identity>
                <p:input port="source">
                    <p:pipe port="fileset.out" step="load.stored"/>
                </p:input>
            </p:identity>
            <p:viewport match="/*/d:file">
                <p:add-attribute match="/*" attribute-name="original-href">
                    <p:with-option name="attribute-value" select="resolve-uri(/*/@href,base-uri())"/>
                </p:add-attribute>
            </p:viewport>
            <px:mediatype-detect/>
            
        </p:when>
        <p:otherwise>
            <p:output port="fileset.out" primary="true">
                <p:pipe port="result" step="load.fileset"/>
            </p:output>
            <p:output port="in-memory.out" sequence="true">
                <p:pipe port="result" step="load.in-memory"/>
            </p:output>
            
            <px:message message="EPUB is not in a container"/>
            <px:fileset-create>
                <p:with-option name="base" select="replace($epub,'(.*/)([^/]*)','$1')"/>
            </px:fileset-create>
            <px:fileset-add-entry media-type="application/oebps-package+xml">
                <p:with-option name="href" select="replace($epub,'(.*/)([^/]*)','$2')"/>
                <p:with-option name="original-href" select="$epub"/>
            </px:fileset-add-entry>
            <px:mediatype-detect/>
            <p:identity name="load.fileset"/>
            
            <px:fileset-load>
                <p:input port="in-memory">
                    <p:empty/>
                </p:input>
            </px:fileset-load>
            <p:identity name="load.in-memory"/>
        </p:otherwise>
    </p:choose>
    
    <!-- Get the OPF so that we can use the metadata in options -->
    <p:identity>
        <p:input port="source">
            <p:pipe port="fileset.out" step="load"/>
        </p:input>
    </p:identity>
    <px:message message="Getting the OPF"/>
    <px:fileset-load media-types="application/oebps-package+xml">
        <p:input port="in-memory">
            <p:pipe port="in-memory.out" step="load"/>
        </p:input>
    </px:fileset-load>
    <p:identity name="opf"/>
    <p:sink/>
    
    <!-- ============= -->
    <!-- EPUB 3 TO PEF -->
    <!-- ============= -->
    <p:identity>
        <p:input port="source">
            <p:pipe port="fileset.out" step="load"/>
        </p:input>
    </p:identity>
    <px:message message="Done loading EPUB, starting conversion to PEF"/>
    <px:epub3-to-pef.convert default-stylesheet="http://www.daisy.org/pipeline/modules/braille/epub3-to-pef/css/default.css" name="convert">
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="load"/>
        </p:input>
        <p:with-option name="stylesheet" select="$stylesheet"/>
        <p:with-option name="transform" select="if ($transform!='') then $transform
                                                else '(translator:liblouis)(formatter:dotify)'"/>
        <p:with-option name="temp-dir" select="concat(string(/c:result),'convert/')">
            <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
        
        <!-- <p:with-option name="page-width" select="$page-width"/> -->
        <!-- <p:with-option name="page-height" select="$page-height"/> -->
        <!-- <p:with-option name="predefined-page-formats" select="$predefined-page-formats"/> -->
        <!-- <p:with-option name="left-margin" select="$left-margin"/> -->
        <!-- <p:with-option name="duplex" select="$duplex"/> -->
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
        <p:with-option name="apply-document-specific-stylesheets" select="$apply-document-specific-stylesheets"/>
    </px:epub3-to-pef.convert>
    <p:sink/>
    
    <!-- ========= -->
    <!-- STORE PEF -->
    <!-- ========= -->
    <p:identity>
        <p:input port="source">
            <p:pipe port="in-memory.out" step="convert"/>
        </p:input>
    </p:identity>
    <px:message message="Storing PEF"/>
    <p:delete match="/*/@xml:base"/>
    <pef:store>
        <p:with-option name="output-dir" select="$output-dir"/>
        <p:with-option name="name" select="if (ends-with(lower-case($epub),'.epub')) then replace($epub,'^.*/([^/]*)\.[^/\.]*$','$1')
                                           else (/opf:package/opf:metadata/dc:identifier[not(@refines)], 'unknown-identifier')[1]">
            <p:pipe step="opf" port="result"/>
        </p:with-option>
        <p:with-option name="brf-table" select="if ($ascii-table!='') then $ascii-table
                                                else concat('(locale:',((/opf:package/opf:metadata/dc:language[not(@refines)])[1]/text(),'und')[1],')')">
            <p:pipe step="opf" port="result"/>
        </p:with-option>
        <p:with-option name="include-preview" select="$include-preview"/>
        <p:with-option name="include-brf" select="$include-brf"/>
    </pef:store>
    
</p:declare-step>
