<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" type="d2e:navigation" version="1.0">

    <p:input port="source"/>
    <p:output port="manifest">
        <p:pipe port="result" step="navigation.manifest"/>
    </p:output>
    <p:output port="store-complete" primary="false">
        <p:pipe port="result" step="navigation.store"/>
    </p:output>
    <p:output port="resource-manifest" primary="false">
        <p:pipe port="result" step="navigation.resources"/>
    </p:output>
    <p:output port="metadata" primary="false">
        <p:pipe port="result" step="navigation.metadata"/>
    </p:output>

    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>

    <p:import href="fileset-library.xpl"/>

    <p:documentation><![CDATA[
            input: from result@ncc
            primary output: "manifest"
            output: "store-complete"
            output: "resource-manifest"
            output: "metadata"
    ]]></p:documentation>

    <p:xslt name="navigation.xhtml">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc2navigation.xsl"/>
        </p:input>
    </p:xslt>
    <p:store name="navigation.store">
        <p:with-option name="href" select="concat($content-dir,'navigation.xhtml')"/>
    </p:store>
    <p:add-attribute name="navigation.document" attribute-name="xml:base" match="/*">
        <p:input port="source">
            <p:pipe port="result" step="navigation.xhtml"/>
        </p:input>
        <p:with-option name="attribute-value" select=".">
            <p:pipe port="result" step="navigation.store"/>
        </p:with-option>
    </p:add-attribute>
    <p:sink/>

    <p:xslt name="navigation.resources">
        <p:input port="source">
            <p:pipe port="result" step="navigation.document"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="navigation2resources.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>

    <p:xslt name="navigation.metadata">
        <p:input port="source">
            <p:pipe port="result" step="navigation.document"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="navigation2metadata.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>

    <px:create-manifest>
        <p:with-option name="base" select="$epub-dir"/>
    </px:create-manifest>
    <px:add-manifest-entry name="navigation.manifest" media-type="application/xhtml+xml">
        <p:with-option name="href"
            select="concat(substring-after($content-dir,$epub-dir),'navigation.xhtml')"/>
    </px:add-manifest-entry>
    <p:sink/>

</p:declare-step>
