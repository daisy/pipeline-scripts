<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-to-pef.convert" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/"
                exclude-inline-prefixes="#all"
                name="main">
    
    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true"/>
    <p:output port="fileset.out" primary="true">
        <p:pipe port="result" step="fileset.out"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe port="result" step="in-memory.out"/>
    </p:output>

    <p:option name="default-stylesheet" required="true"/>
    <p:option name="stylesheet" required="true"/>
    <p:option name="transform" required="true"/>
    
    <!-- <p:option name="page-width" required="true"/> -->
    <!-- <p:option name="page-height" required="true"/> -->
    <!-- <p:option name="predefined-page-formats" required="true"/> -->
    <!-- <p:option name="left-margin" required="true"/> -->
    <!-- <p:option name="duplex" required="true"/> -->
    <!-- <p:option name="levels-in-footer" required="true"/> -->
    <!-- <p:option name="main-document-language" required="true"/> -->
    <!-- <p:option name="contraction-grade" required="true"/> -->
    <!-- <p:option name="hyphenation-with-single-line-spacing" required="true"/> -->
    <!-- <p:option name="hyphenation-with-double-line-spacing" required="true"/> -->
    <!-- <p:option name="line-spacing" required="true"/> -->
    <!-- <p:option name="tab-width" required="true"/> -->
    <!-- <p:option name="capital-letters" required="true"/> -->
    <!-- <p:option name="accented-letters" required="true"/> -->
    <!-- <p:option name="polite-forms" required="true"/> -->
    <!-- <p:option name="downshift-ordinal-numbers" required="true"/> -->
    <!-- <p:option name="include-captions" required="true"/> -->
    <!-- <p:option name="include-images" required="true"/> -->
    <!-- <p:option name="include-image-groups" required="true"/> -->
    <!-- <p:option name="include-line-groups" required="true"/> -->
    <!-- <p:option name="text-level-formatting" required="true"/> -->
    <!-- <p:option name="include-note-references" required="true"/> -->
    <!-- <p:option name="include-production-notes" required="true"/> -->
    <!-- <p:option name="show-braille-page-numbers" required="true"/> -->
    <!-- <p:option name="show-print-page-numbers" required="true"/> -->
    <!-- <p:option name="force-braille-page-break" required="true"/> -->
    <p:option name="toc-depth" required="true"/>
    <!-- <p:option name="ignore-document-title" required="true"/> -->
    <!-- <p:option name="include-symbols-list" required="true"/> -->
    <!-- <p:option name="choice-of-colophon" required="true"/> -->
    <!-- <p:option name="footnotes-placement" required="true"/> -->
    <!-- <p:option name="colophon-metadata-placement" required="true"/> -->
    <!-- <p:option name="rear-cover-placement" required="true"/> -->
    <!-- <p:option name="number-of-pages" required="true"/> -->
    <!-- <p:option name="maximum-number-of-pages" required="true"/> -->
    <!-- <p:option name="minimum-number-of-pages" required="true"/> -->
    <!-- <p:option name="sbsform-macros" required="true"/> -->

    <!-- Empty temporary directory dedicated to this conversion -->
    <p:option name="temp-dir" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="fileset-add-tempfile.xpl"/>
    
    <!-- Load OPF and add content files to fileset. -->
    <px:fileset-load media-types="application/oebps-package+xml">
        <p:input port="fileset">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>
    <p:identity name="opf"/>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/opf-manifest-to-fileset.xsl"/>
        </p:input>
    </p:xslt>
    <p:identity name="opf-fileset"/>
    <p:sink/>
    
    <px:fileset-create name="temp-dir">
        <p:with-option name="base" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </px:fileset-create>
    
    <p:choose>
        <p:when test="not($toc-depth='0')">
            <pxi:fileset-add-tempfile media-type="text/css" suffix=".css">
                <p:input port="source">
                    <p:inline>
                        <c:data>#generated-toc {
  flow: document-toc;
  display: -obfl-toc;
  -obfl-toc-range: document;
}

#generated-toc::duplicate {
  flow: volume-toc;
  display: -obfl-toc;
  -obfl-toc-range: volume;
}
</c:data>
                    </p:inline>
                </p:input>
            </pxi:fileset-add-tempfile>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    <p:identity name="generated-css"/>
    
    <!-- Load XHTML documents in spine order. -->
    <px:fileset-load media-types="application/oebps-package+xml application/xhtml+xml">
        <p:input port="fileset">
            <p:pipe port="result" step="opf-fileset"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>
    <p:wrap-sequence wrapper="wrapper"/>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/get-epub3-spine.xsl"/>
        </p:input>
    </p:xslt>
    <p:filter select="/*/*"/>
    
    <!-- In case there exists any CSS in the EPUB already; inline that CSS. -->
    <p:for-each>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="base-uri(/*)"/>
        </p:add-attribute>
        
        <px:message>
            <p:with-option name="message" select="concat('Inlining document-specific CSS for ',replace(base-uri(/*),'.*/',''),'')"/>
        </px:message>
        <css:inline/>
        
        <p:filter select="/*/html:body"/>
    </p:for-each>
    <p:identity name="spine-bodies"/>
    
    <!-- Convert OPF metadata to HTML metadata. -->
    <p:xslt>
        <p:input port="source">
            <p:pipe port="result" step="opf"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/opf-to-html-head.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <p:identity name="opf-as-head"/>
    
    <!-- Create a new HTML document with <head> based on the OPF and all <body> elements from the input HTML documents -->
    <p:wrap-sequence wrapper="html" wrapper-namespace="http://www.w3.org/1999/xhtml">
        <p:input port="source">
            <p:pipe port="result" step="opf-as-head"/>
            <p:pipe port="result" step="spine-bodies"/>
        </p:input>
    </p:wrap-sequence>
    
    <px:message message="Generating table of contents"/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/generate-toc.xsl"/>
        </p:input>
        <p:with-param name="_depth" select="$toc-depth"/>
    </p:xslt>
    
    <px:message message="Inlining global CSS"/>
    <css:inline>
        <p:with-option name="default-stylesheet" select="string-join((
                                                           $default-stylesheet,
                                                           $stylesheet,
                                                           //d:file/resolve-uri(@href, base-uri(.))),' ')">
            <p:pipe step="generated-css" port="result"/>
        </p:with-option>
    </css:inline>
    
    <p:group>
        <p:variable name="lang" select="(/*/opf:metadata/dc:language[not(@refines)])[1]/text()">
            <p:pipe port="result" step="opf"/>
        </p:variable>
        
        <px:message message="Transforming MathML"/>
        <p:viewport match="math:math">
            <px:transform>
                <p:with-option name="query" select="concat('(input:mathml)(locale:',$lang,')')"/>
                <p:with-option name="temp-dir" select="$temp-dir"/>
            </px:transform>
        </p:viewport>
        
        <px:message message="Transforming from XML with inline CSS to PEF"/>
        <px:transform>
            <p:with-option name="query" select="concat('(input:css)(output:pef)',$transform,'(locale:',$lang,')')"/>
            <p:with-option name="temp-dir" select="$temp-dir"/>
        </px:transform>
    </p:group>
    <p:identity name="pef"/>

    <p:identity>
        <p:input port="source">
            <p:pipe step="pef" port="result"/>
            <p:pipe step="opf" port="result"/>
        </p:input>
    </p:identity>
    <px:message message="Adding metadata to PEF based on EPUB 3 package document metadata"/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="http://www.daisy.org/pipeline/modules/braille/pef-utils/add-opf-metadata-to-pef.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <p:add-attribute match="/*" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="replace(base-uri(/*),'[^/]+$',concat(((/*/opf:metadata/dc:identifier[not(@refines)]/text()), 'pef')[1],'.pef'))">
            <p:pipe port="result" step="opf"/>
        </p:with-option>
    </p:add-attribute>
    <p:identity name="in-memory.out"/>
    
    <px:fileset-create>
        <p:with-option name="base" select="replace(base-uri(/*),'[^/]+$','')"/>
    </px:fileset-create>
    <px:fileset-add-entry media-type="application/x-pef+xml">
        <p:with-option name="href" select="base-uri(/*)">
            <p:pipe port="result" step="in-memory.out"/>
        </p:with-option>
    </px:fileset-add-entry>
    <p:identity name="fileset.out"/>
    
</p:declare-step>
