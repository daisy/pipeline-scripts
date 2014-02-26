<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    type="px:epub3-to-daisy202-convert" name="main" version="1.0" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:cx="http://xmlcalabash.com/ns/extensions">

    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true"/>

    <p:output port="fileset.out" primary="true">
        <p:pipe port="result" step="result.fileset"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe port="result" step="result.in-memory"/>
    </p:output>

    <p:import href="../library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>

    <px:fileset-load media-types="application/xhtml+xml">
        <p:input port="in-memory">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>
    <p:for-each>
        <p:add-attribute attribute-name="xml:base" match="/*">
            <p:with-option name="attribute-value" select="base-uri(/*)"/>
        </p:add-attribute>

        <!-- Make sure only sections corresponding to html:h[1-6] are used. -->
        <p:xslt>
            <p:with-param name="name" select="'section article'"/>
            <!-- TODO: add other sectioning elements than section and article ? -->

            <p:with-param name="namespace" select="'http://www.w3.org/1999/xhtml'"/>
            <p:with-param name="max-depth" select="6"/>
            <p:with-param name="copy-wrapping-elements-into-result" select="true()"/>
            <p:input port="stylesheet">
                <p:document href="http://www.daisy.org/pipeline/modules/common-utils/deep-level-grouping.xsl"/>
            </p:input>
        </p:xslt>

        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../../xslt/html5-to-html4.xsl"/>
            </p:input>
        </p:xslt>

        <!-- TODO: convert or recreate smil-files? -->
        <!-- TODO: associate smil files with html files (i.e. add linkbacks) -->

        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="replace(base-uri(/*),'^(.*)\.([^/\.]*)$','$1.html')"/>
        </p:add-attribute>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../../xslt/pretty-print.xsl"/>
            </p:input>
        </p:xslt>
    </p:for-each>
    <p:identity name="result.in-memory"/>

    <p:identity>
        <p:input port="source">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
    </p:identity>
    <p:viewport match="//d:file[@media-type='application/xhtml+xml']">
        <p:add-attribute attribute-name="href" match="/*">
            <p:with-option name="attribute-value" select="replace(/*/@href,'^(.*)\.([^/\.]*)$','$1.html')"/>
        </p:add-attribute>
    </p:viewport>
    <p:xslt>
        <p:with-param name="preserve-empty-whitespace" select="'false'"/>
        <p:input port="stylesheet">
            <p:document href="../xslt/pretty-print.xsl"/>
        </p:input>
    </p:xslt>
    <p:identity name="result.fileset"/>

</p:declare-step>
