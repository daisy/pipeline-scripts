<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" type="d2e:media-overlay" name="media-overlay"
    version="1.0">

    <p:input port="source" primary="true"/>
    <p:input port="ncc-metadata"/>
    <p:output port="manifest" primary="false" sequence="true">
        <p:pipe port="result" step="manifest"/>
    </p:output>
    <p:output port="store-complete" sequence="true" primary="false">
        <p:pipe port="store" step="for-each"/>
    </p:output>
    <p:output port="resource-manifest" primary="false">
        <p:pipe port="result" step="resources"/>
    </p:output>
    <p:output port="metadata" primary="false">
        <p:pipe port="result" step="metadata"/>
    </p:output>
    <p:output port="id-mapping" primary="false">
        <p:pipe port="result" step="id-mapping"/>
    </p:output>
    <p:output port="spine-manifest" primary="false">
        <p:pipe port="result" step="spine"/>
    </p:output>

    <p:option name="daisy-dir" required="true"/>
    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>

    <p:import href="fileutils-library.xpl"/>
    <p:import href="smil-library.xpl"/>

    <p:viewport name="viewport" match="//c:entry">
        <p:variable name="href" select="/*/@href"/>
        <p:identity name="viewport.entry"/>
        <p:sink/>
        <p:load name="viewport.smil">
            <p:with-option name="href" select="concat($daisy-dir,$href)"/>
        </p:load>
        <p:xslt name="viewport.smil.unique-ids">
            <p:with-param name="position" select="p:iteration-position()"/>
            <p:input port="stylesheet">
                <p:document href="ensure-unique-smil-ids.xsl"/>
            </p:input>
        </p:xslt>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="smil2reverse-media-overlay.xsl"/>
            </p:input>
        </p:xslt>
        <p:choose>
            <p:when test="/*/@reverse-media-overlay">
                <p:variable name="reverse-media-overlay" select="/*/@reverse-media-overlay"/>
                <p:add-attribute match="/*" attribute-name="reverse-media-overlay">
                    <p:with-option name="attribute-value" select="$reverse-media-overlay"/>
                    <p:input port="source">
                        <p:pipe port="result" step="viewport.entry"/>
                    </p:input>
                </p:add-attribute>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="result" step="viewport.entry"/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:add-attribute match="/*" attribute-name="original-href">
            <p:with-option name="attribute-value" select="concat($daisy-dir,$href)"/>
        </p:add-attribute>
        <p:insert match="/*" position="last-child">
            <p:input port="insertion">
                <p:pipe port="result" step="viewport.smil.unique-ids"/>
            </p:input>
        </p:insert>
    </p:viewport>
    <p:sink/>

    <p:xslt>
        <p:input port="source">
            <p:pipe port="result" step="viewport"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="join-smil-entries.xsl"/>
        </p:input>
    </p:xslt>

    <p:for-each name="for-each">
        <p:output port="manifest" primary="false">
            <p:pipe port="result" step="for-each.manifest"/>
        </p:output>
        <p:output port="store" primary="false">
            <p:pipe port="result" step="for-each.store"/>
        </p:output>
        <p:output port="resources" primary="false">
            <p:pipe port="result" step="for-each.resources"/>
        </p:output>
        <p:output port="metadata" primary="false">
            <p:pipe port="result" step="for-each.metadata"/>
        </p:output>

        <p:iteration-source select="/c:manifest/c:entry"/>

        <p:variable name="href" select="string(/*/@href)"/>
        <p:variable name="reverse-media-overlay" select="string(/*/@reverse-media-overlay)"/>
        <p:variable name="original-href" select="string(/*/@original-href)"/>
        <p:identity name="for-each.entry"/>

        <p:wrap match="/*" wrapper="smil"/>
        <p:unwrap match="/smil/c:entry"/>
        <px:join-smil10/>
        <p:xslt name="for-each.media-overlay">
            <p:with-param name="language" select="/c:metadata/c:meta[@name='dc:language']/@content">
                <p:pipe port="ncc-metadata" step="media-overlay"/>
            </p:with-param>
            <p:input port="stylesheet">
                <p:document href="smil2media-overlay.xsl"/>
            </p:input>
        </p:xslt>
        <p:store name="for-each.store">
            <p:with-option name="href" select="p:resolve-uri(concat($content-dir,$href))"/>
        </p:store>
        <p:add-attribute name="for-each.document" attribute-name="xml:base" match="/*">
            <p:input port="source">
                <p:pipe port="result" step="for-each.media-overlay"/>
            </p:input>
            <p:with-option name="attribute-value" select=".">
                <p:pipe port="result" step="for-each.store"/>
            </p:with-option>
        </p:add-attribute>
        <p:sink/>

        <p:xslt name="for-each.resources">
            <p:with-param name="base" select="$epub-dir"/>
            <p:input port="source">
                <p:pipe port="result" step="for-each.document"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="media-overlay2resources.xsl"/>
            </p:input>
        </p:xslt>
        <p:sink/>

        <p:xslt name="for-each.metadata">
            <p:input port="source">
                <p:pipe port="result" step="for-each.document"/>
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
        <px:add-manifest-entry>
            <p:with-option name="href"
                select="concat(substring-after($content-dir,$epub-dir),$href)"/>
            <p:with-option name="media-type" select="'application/smil+xml'"/>
        </px:add-manifest-entry>
        <p:choose>
            <p:when test="string-length($reverse-media-overlay)&gt;0">
                <p:add-attribute match="//c:entry[last()]" attribute-name="reverse-media-overlay">
                    <p:with-option name="attribute-value" select="$reverse-media-overlay"/>
                </p:add-attribute>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        <p:choose>
            <p:when test="string-length($original-href)&gt;0">
                <p:add-attribute match="//c:entry[last()]" attribute-name="original-href">
                    <p:with-option name="attribute-value" select="$original-href"/>
                </p:add-attribute>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        <p:identity name="for-each.manifest"/>
        <p:sink/>
    </p:for-each>

    <px:join-manifests name="manifest">
        <p:input port="source">
            <p:pipe port="manifest" step="for-each"/>
        </p:input>
    </px:join-manifests>
    <p:xslt name="spine">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="manifest2spine.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>

    <px:join-manifests name="resources">
        <p:input port="source">
            <p:pipe port="resources" step="for-each"/>
        </p:input>
    </px:join-manifests>
    <p:sink/>

    <p:wrap-sequence wrapper="c:metadata">
        <p:input port="source">
            <p:pipe port="manifest" step="for-each"/>
        </p:input>
    </p:wrap-sequence>
    <p:unwrap name="metadata" match="c:metadata[parent::c:metadata]"/>
    <p:sink/>

    <p:xslt name="temp-name">
        <p:input port="source">
            <p:pipe port="result" step="viewport"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="make-id-mapping.xsl"/>
        </p:input>
    </p:xslt>
    <p:choose>
        <p:when test="//c:entry">
            <p:viewport match="c:entry">
                <p:variable name="original-content-href" select="/*/@original-content-href"/>
                <p:add-attribute match="/*" attribute-name="media-overlay-href">
                    <p:with-option name="attribute-value" select="//c:entry[@reverse-media-overlay=$original-content-href]/@href">
                        <p:pipe port="result" step="manifest"/>
                    </p:with-option>
                </p:add-attribute>
            </p:viewport>
            <p:identity/>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    <p:identity name="id-mapping"/>
    <p:sink/>

</p:declare-step>
