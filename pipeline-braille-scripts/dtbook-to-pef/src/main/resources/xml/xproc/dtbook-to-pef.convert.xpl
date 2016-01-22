<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:dtbook-to-pef.convert" version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:pef="http://www.daisy.org/ns/2008/pef"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:math="http://www.w3.org/1998/Math/MathML" exclude-inline-prefixes="#all" name="main">

    <p:input port="source" px:media-type="application/x-dtbook+xml"/>
    <p:output port="result" px:media-type="application/x-pef+xml"/>

    <p:option name="default-stylesheet" required="false" select="''"/>
    <p:option name="stylesheet" required="false" select="''"/>
    <p:option name="transform" required="false" select="''"/>
    
    <!--
    <p:option name="page-width" required="false" select="'28'"/>
    <p:option name="page-height" required="false" select="'29'"/>
    <p:option name="predefined-page-formats" required="false" select="'A4'"/>
    <p:option name="left-margin" required="false" select="'0'"/>
    <p:option name="duplex" required="false" select="'true'"/>
    <p:option name="levels-in-footer" required="false" select="'6'"/>
    <p:option name="main-document-language" required="false" select="''"/>
    <p:option name="contraction-grade" required="false" select="'0'"/>
    <p:option name="hyphenation-with-single-line-spacing" required="false" select="'true'"/>
    <p:option name="hyphenation-with-double-line-spacing" required="false" select="'false'"/>
    <p:option name="line-spacing" required="false" select="'false'"/>
    <p:option name="tab-width" required="false" select="'4'"/>
    <p:option name="capital-letters" required="false" select="'true'"/>
    <p:option name="accented-letters" required="false" select="'true'"/>
    <p:option name="polite-forms" required="false" select="'false'"/>
    <p:option name="downshift-ordinal-numbers" required="false" select="'false'"/>
    <p:option name="include-captions" required="false" select="'true'"/>
    <p:option name="include-images" required="false" select="'true'"/>
    <p:option name="include-image-groups" required="false" select="'true'"/>
    <p:option name="include-line-groups" required="false" select="'true'"/>
    <p:option name="text-level-formatting" required="false" select="'true'"/>
    <p:option name="include-note-references" required="false" select="'true'"/>
    <p:option name="include-production-notes" required="false" select="'false'"/>
    <p:option name="show-braille-page-numbers" required="false" select="'true'"/>
    <p:option name="show-print-page-numbers" required="false" select="'true'"/>
    <p:option name="force-braille-page-break" required="false" select="'false'"/>
    <p:option name="generate-table-of-contents" required="false" select="'true'"/>
    <p:option name="table-of-contents-depth" required="false" select="'6'"/>
    <p:option name="ignore-document-title" required="false" select="'false'"/>
    <p:option name="include-symbols-list" required="false" select="'true'"/>
    <p:option name="choice-of-colophon" required="false" select="''"/>
    <p:option name="footnotes-placement" required="false" select="''"/>
    <p:option name="colophon-metadata-placement" required="false" select="''"/>
    <p:option name="rear-cover-placement" required="false" select="''"/>
    <p:option name="number-of-pages" required="false" select="'50'"/>
    <p:option name="maximum-number-of-pages" required="false" select="'70'"/>
    <p:option name="minimum-number-of-pages" required="false" select="'30'"/>
    <p:option name="sbsform-macros" required="false" select="''"/>
    -->

    <!-- Empty temporary directory dedicated to this conversion -->
    <p:option name="temp-dir" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>

    <p:variable name="lang" select="(/*/@xml:lang,'und')[1]"/>

    <px:dtbook-load name="load"/>
    <css:inline>
        <p:input port="source">
            <p:pipe step="load" port="in-memory.out"/>
        </p:input>
        <p:with-option name="default-stylesheet" select="concat($default-stylesheet, ' ', $stylesheet)"/>
    </css:inline>

    <p:viewport match="math:math">
        <px:transform>
            <p:with-option name="query" select="concat('(input:mathml)(locale:',$lang,')')"/>
            <p:with-option name="temp-dir" select="$temp-dir"/>
        </px:transform>
    </p:viewport>

    <px:transform name="pef">
        <p:with-option name="query" select="concat('(input:css)(output:pef)',$transform,'(locale:',$lang,')')"/>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </px:transform>

    <p:xslt name="metadata">
        <p:input port="source">
            <p:pipe step="main" port="source"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/dtbook-to-metadata.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <pef:add-metadata>
        <p:input port="source">
            <p:pipe step="pef" port="result"/>
        </p:input>
        <p:input port="metadata">
            <p:pipe step="metadata" port="result"/>
        </p:input>
    </pef:add-metadata>

</p:declare-step>
