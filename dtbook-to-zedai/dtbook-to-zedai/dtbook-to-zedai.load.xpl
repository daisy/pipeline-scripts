<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-to-zedai.load" type="px:dtbook-to-zedai-load" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp" xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" exclude-inline-prefixes="cx p c cxo px xd pxi z tmp">

    <p:documentation>
        <xd:short>DTBook to ZedAI - load</xd:short>
        <xd:detail>Loads the DTBook XML fileset.</xd:detail>
        <xd:homepage>http://code.google.com/p/daisy-pipeline/wiki/DTBookToZedAI</xd:homepage>
        <xd:author>
            <xd:name>Marisa DeMeglio</xd:name>
            <xd:mailto>marisa.demeglio@gmail.com</xd:mailto>
            <xd:organization>DAISY</xd:organization>
        </xd:author>
    </p:documentation>

    <p:input port="source" primary="true" sequence="true" px:media-type="application/x-dtbook+xml">
        <p:documentation>
            <xd:short>DTBook file(s)</xd:short>
            <xd:detail>One or more DTBook files to be loaded. Any auxilliary resources referenced from the DTBook documents will be resolved based on these
                files.</xd:detail>
        </p:documentation>
    </p:input>

    <p:output port="fileset.out" primary="true">
        <p:documentation>
            <xd:short>A fileset referencing all input resources.</xd:short>
            <xd:detail>Contains references to all the DTBook files and any resources they reference (images etc.). The xml:base is also set with an absolute URI
                for each file, and is intended to represent the "original file", while the href can change during conversions to reflect the path and filename
                of the resource in the output fileset.</xd:detail>
        </p:documentation>
        <p:pipe port="result" step="fileset"/>
    </p:output>

    <p:output port="in-memory.out" sequence="true">
        <p:documentation>
            <xd:short>The DTBook documents.</xd:short>
            <xd:detail>While all resources are referenced in the fileset on the `fileset` output port, the `in-memory`-port contains a sequence of all the
                DTBook documents loaded from disk so that the DTBook conversion step does not depend on documents being stored on disk. This means that the
                conversion step can receive DTBook documents either through this step, or as a result from other conversion steps, allowing for easy chaining of
                scripts.</xd:detail>
        </p:documentation>
        <p:pipe port="result" step="dtbook"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/mediatype.xpl"/>

    <p:for-each>
        <p:add-xml-base/>
    </p:for-each>
    <p:identity name="dtbook"/>

    <p:for-each>
        <p:variable name="dtbook-base" select="/*/@xml:base"/>
        <p:variable name="fileset-base" select="replace($dtbook-base,'^(.*/)[^/]*$','$1')"/>
        <p:identity name="for-each.dtbook"/>
        <px:fileset-create name="for-each.fileset">
            <p:with-option name="base" select="$fileset-base"/>
        </px:fileset-create>
        <p:for-each>
            <p:iteration-source select="//*[@src]">
                <p:pipe port="result" step="for-each.dtbook"/>
            </p:iteration-source>
            <p:variable name="src" select="/*/@src"/>
            <px:fileset-add-entry>
                <p:input port="source">
                    <p:pipe port="result" step="for-each.fileset"/>
                </p:input>
                <p:with-option name="href" select="$src"/>
            </px:fileset-add-entry>
        </p:for-each>
        <px:fileset-join/>
        <px:fileset-add-entry>
            <p:with-option name="href" select="$dtbook-base"/>
            <p:with-option name="media-type" select="'application/x-dtbook+xml'"/>
        </px:fileset-add-entry>
    </p:for-each>
    <px:fileset-join/>
    <px:mediatype-detect/>
    <p:group>
        <p:variable name="fileset-base" select="/*/@xml:base"/>
        <p:viewport match="/*/*">
            <p:add-attribute attribute-name="original-href" match="/*">
                <p:with-option name="attribute-value" select="p:resolve-uri(/*/@href,$fileset-base)"/>
            </p:add-attribute>
        </p:viewport>
    </p:group>
    <p:identity name="fileset"/>
    <p:sink/>

</p:declare-step>
