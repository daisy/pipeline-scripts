<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" type="d2e:resources" version="1.0">

    <p:input port="source" sequence="true"/>
    <p:output port="manifest">
        <p:pipe port="result" step="resources.manifest"/>
    </p:output>
    <p:output port="store-complete" primary="false">
        <p:pipe port="store" step="resources.iterate"/>
    </p:output>

    <p:option name="daisy-dir" required="true"/>
    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>

    <p:import href="fileutils-library.xpl"/>
    <p:import href="mime.xpl"/>

    <p:documentation><![CDATA[
            read satellite files; mp3, css, png, jpg etc.
            input: resource-manifest@navigation
            input: resource-manifest@resources
            input: resource-manifest@documents
            primary output: "manifest"
            output: "store-complete"
    ]]></p:documentation>

    <px:join-manifests/>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="resources-manifest-cleanup.xsl"/>
        </p:input>
    </p:xslt>
    <p:for-each name="resources.iterate">
        <p:output port="result">
            <p:pipe port="result" step="resources.iterate.manifest"/>
        </p:output>
        <p:output port="store">
            <p:pipe port="result" step="resources.iterate.copy"/>
        </p:output>

        <p:iteration-source
            select="//c:entry"/>
        <p:variable name="href" select="/*/@href"/>
        <p:variable name="media-type" select="/*/@media-type"/>
        <p:variable name="reverse-media-overlay" select="/*/@reverse-media-overlay"/>
        <p:variable name="original-href" select="/*/@original-href"/>

        <p:identity name="resources.iterate.source"/>

        <cxf:copy name="resources.iterate.copy">
            <p:with-option name="href" select="concat($daisy-dir,$href)"/>
            <p:with-option name="target" select="concat($content-dir,$href)"/>
        </cxf:copy>
        <p:sink/>

        <px:mime name="contents.iterate.mime">
            <p:with-option name="href" select="$href"/>
        </px:mime>
        <p:sink/>
        <px:create-manifest>
            <p:with-option name="base" select="$epub-dir"/>
        </px:create-manifest>
        <px:add-manifest-entry>
            <p:with-option name="href" select="concat(substring-after($content-dir,$epub-dir),$href)"/>
            <p:with-option name="media-type"
                select="if ($media-type) then $media-type else /*/@media-type">
                <p:pipe port="result" step="contents.iterate.mime"/>
            </p:with-option>
        </px:add-manifest-entry>
        <p:choose>
            <p:when test="$reverse-media-overlay">
                <p:add-attribute match="//c:entry[last()]" attribute-name="reverse-media-overlay">
                    <p:with-option name="attribute-value" select="$reverse-media-overlay"/>
                </p:add-attribute>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        <p:choose>
            <p:when test="$original-href">
                <p:add-attribute match="//c:entry[last()]" attribute-name="original-href">
                    <p:with-option name="attribute-value" select="$original-href"/>
                </p:add-attribute>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        <p:identity name="contents.iterate.manifest"/>
        <p:sink/>
    </p:for-each>
    <p:sink/>

    <px:join-manifests name="resources.manifest">
        <p:input port="source">
            <p:pipe port="result" step="resources.iterate"/>
        </p:input>
    </px:join-manifests>
    <p:sink/>

</p:declare-step>
