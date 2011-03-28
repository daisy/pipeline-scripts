<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" type="d2e:media-overlay" version="1.0">

    <p:input port="source"/>
    <p:output port="manifest">
        <p:pipe port="result" step="media-overlay.manifest"/>
    </p:output>
    <p:output port="store-complete" primary="false">
        <p:pipe port="store" step="media-overlay.iterate"/>
    </p:output>
    <p:output port="resource-manifest" primary="false">
        <p:pipe port="result" step="media-overlay.resources"/>
    </p:output>
    <p:output port="metadata" primary="false">
        <p:pipe port="result" step="media-overlay.metadata"/>
    </p:output>
    <p:output port="spine-manifest" primary="false">
        <p:pipe port="result" step="media-overlay.spine"/>
    </p:output>

    <p:option name="daisy-dir" required="true"/>
    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>

    <p:import href="fileutils-library.xpl"/>

    <p:documentation><![CDATA[
            read SMIL-files
            input: manifest@flow
            primary output: "manifest"
            output: "store-complete"
            output: "resource-manifest"
            output: "metadata"
            output: "spine-manifest"
    ]]></p:documentation>

    <p:for-each name="media-overlay.iterate">
        <p:output port="manifest">
            <p:pipe port="result" step="media-overlay.iterate.manifest"/>
        </p:output>
        <p:output port="store" primary="false">
            <p:pipe port="result" step="media-overlay.iterate.store"/>
        </p:output>
        <p:output port="resources" primary="false">
            <p:pipe port="result" step="media-overlay.iterate.resources"/>
        </p:output>
        <p:output port="metadata" primary="false">
            <p:pipe port="result" step="media-overlay.iterate.metadata"/>
        </p:output>

        <p:iteration-source select="//c:entry"/>
        <p:variable name="href" select="/*/@href"/>
        
        <p:load>
            <p:with-option name="href" select="concat($daisy-dir,$href)"/>
        </p:load>
        <p:xslt name="media-overlay.iterate.smil">
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="smil2media-overlay.xsl"/>
            </p:input>
        </p:xslt>
        <p:store name="media-overlay.iterate.store">
            <p:with-option name="href" select="p:resolve-uri(concat($content-dir,$href))"/>
        </p:store>
        <p:add-attribute name="media-overlay.iterate.document" attribute-name="xml:base" match="/*">
            <p:input port="source">
                <p:pipe port="result" step="media-overlay.iterate.smil"/>
            </p:input>
            <p:with-option name="attribute-value" select=".">
                <p:pipe port="result" step="media-overlay.iterate.store"/>
            </p:with-option>
        </p:add-attribute>
        <p:sink/>

        <p:xslt name="media-overlay.iterate.resources">
            <p:with-param name="base" select="$epub-dir"/>
            <p:input port="source">
                <p:pipe port="result" step="media-overlay.iterate.document"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="media-overlay2resources.xsl"/>
            </p:input>
        </p:xslt>
        <p:sink/>

        <p:xslt name="media-overlay.iterate.metadata">
            <p:input port="source">
                <p:pipe port="result" step="media-overlay.iterate.document"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="media-overlay2metadata.xsl"/>
            </p:input>
        </p:xslt>
        <p:sink/>

        <px:create-manifest>
            <p:with-option name="base" select="$epub-dir"/>
        </px:create-manifest>
        <px:add-manifest-entry name="contents.iterate.manifest-simple">
            <p:with-option name="href" select="concat(substring-after($content-dir,$epub-dir),$href)"/>
            <p:with-option name="media-type" select="'application/smil+xml'"/>
        </px:add-manifest-entry>
        <p:sink/>
        <p:xslt>
            <p:input port="source">
                <p:pipe port="result" step="media-overlay.iterate.document"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="media-overlay2reverse-media-overlay.xsl"/>
            </p:input>
        </p:xslt>
        <p:choose>
            <p:when test="/*/@reverse-media-overlay">
                <p:variable name="reverse-media-overlay" select="/*/@reverse-media-overlay"/>
                <p:add-attribute match="//c:entry[last()]" attribute-name="reverse-media-overlay">
                    <p:with-option name="attribute-value" select="$reverse-media-overlay"/>
                    <p:input port="source">
                        <p:pipe port="result" step="contents.iterate.manifest-simple"/>
                    </p:input>
                </p:add-attribute>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="result" step="contents.iterate.manifest-simple"/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:add-attribute name="media-overlay.iterate.manifest" match="//c:entry[last()]"
            attribute-name="original-href">
            <p:with-option name="attribute-value" select="concat($daisy-dir,$href)"/>
        </p:add-attribute>
        <p:sink/>
    </p:for-each>

    <px:join-manifests name="media-overlay.manifest">
        <p:input port="source">
            <p:pipe port="manifest" step="media-overlay.iterate"/>
        </p:input>
    </px:join-manifests>
    <p:xslt name="media-overlay.spine">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="manifest2spine.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>

    <px:join-manifests name="media-overlay.resources">
        <p:input port="source">
            <p:pipe port="resources" step="media-overlay.iterate"/>
        </p:input>
    </px:join-manifests>
    <p:sink/>

    <p:wrap-sequence wrapper="c:metadata">
        <p:input port="source">
            <p:pipe port="manifest" step="media-overlay.iterate"/>
        </p:input>
    </p:wrap-sequence>
    <p:unwrap name="media-overlay.metadata" match="c:metadata[parent::c:metadata]"/>
    <p:sink/>

</p:declare-step>
