<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:opf="http://www.idpf.org/2007/opf"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" type="px:media-overlay" name="media-overlay"
    version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Load the DAISY 2.02 SMILs and store them as EPUB 3 SMILs.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:input port="flow">SMIL-files listed in playback order.</xd:input>
        <xd:input port="ncc-metadata">Metadata from the &lt;head/&gt; of the NCC.</xd:input>
        <xd:output port="manifest">List of stored files.</xd:output>
        <xd:output port="store-complete">Pipe connection for 'p:store'-dependencies.</xd:output>
        <xd:output port="resource-manifest">Auxiliary resources referenced from the resulting
            SMILs.</xd:output>
        <xd:output port="metadata">Metadata from the SMILs.</xd:output>
        <xd:output port="id-mapping">Maps id-attributes and fragment identifiers from the original
            and resulting filesets together.</xd:output>
        <xd:output port="spine-manifest">List of DAISY 2.02 text content documents in playback
            order.</xd:output>
        <xd:option name="daisy-dir">URI to the directory containing the NCC.</xd:option>
        <xd:option name="content-dir">URI to the directory where all the EPUB 3 content should be
            stored.</xd:option>
        <xd:option name="epub-dir">URI to the directory where the OCF is being created.</xd:option>
        <xd:import href="../utilities/file-utils/fileset-library.xpl">For manipulating
            filesets.</xd:import>
        <xd:import href="../utilities/smil-utils/smil-library.xpl">For manipulating
            SMIL-files.</xd:import>
    </p:documentation>

    <p:input port="flow" primary="true"/>
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

    <p:import href="../utilities/file-utils/fileset-library.xpl"/>
    <p:import href="../utilities/smil-utils/smil-library.xpl"/>

    <p:documentation>Load all SMIL-files</p:documentation>
    <p:viewport name="viewport" match="//c:entry">
        <p:variable name="href" select="/*/@href"/>
        <p:identity name="viewport.entry"/>
        <p:sink/>
        <p:load name="viewport.smil">
            <p:with-option name="href" select="concat($daisy-dir,$href)"/>
        </p:load>
        <p:xslt name="viewport.unique-smil-ids">
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
                <p:pipe port="result" step="viewport.unique-smil-ids"/>
            </p:input>
        </p:insert>
    </p:viewport>
    <p:sink/>

    <p:documentation>Concatenate SMIL-files which reference the same text
        document.</p:documentation>
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

    <p:documentation>
        <xd:short>For each resulting SMIL; extract metadata, list referenced resources, convert to
            SMIL 3.0 and store the files.</xd:short>
        <xd:output port="manifest">Sequence of manifests representing each stored
            SMIL-file.</xd:output>
        <xd:output port="store">Sequence of results from storing the SMIL-files, allowing other
            steps to depend on the files being stored.</xd:output>
        <xd:output port="resources">Sequence of manifests derived from each SMIL-file containing
            references to all the auxiliary resources.</xd:output>
        <xd:output port="metadata">Sequence of metadata sets intended for "global" consuption,
            derived from each SMIL-file.</xd:output>
    </p:documentation>
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

        <p:documentation xd:exclude="true">Unwrap c:entry to sequence.</p:documentation>
        <p:for-each>
            <p:iteration-source select="/c:entry/*"/>
            <p:identity/>
        </p:for-each>

        <p:documentation xd:exclude="true">Merge SMIL-files which reference the same text
            document.</p:documentation>
        <px:smil10-join-adjacent/>

        <px:smil10-to-smil30 name="for-each.media-overlay">
            <p:with-option name="language" select="/c:metadata/c:meta[@name='dc:language']/@content">
                <p:pipe port="ncc-metadata" step="media-overlay"/>
            </p:with-option>
        </px:smil10-to-smil30>

        <p:validate-with-schematron>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="schema">
                <p:document href="../schemas/epub30/media-overlay-30.sch"/>
            </p:input>
        </p:validate-with-schematron>

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
        <p:documentation>Make a manifest of all the stored files.</p:documentation>
        <p:input port="source">
            <p:pipe port="manifest" step="for-each"/>
        </p:input>
    </px:join-manifests>
    <p:xslt name="spine">
        <p:documentation>Make chronological list of content documents in reading order based on the
            list of resulting SMIL-files.</p:documentation>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="manifest2spine.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>

    <p:documentation>Make a manifest of all the referenced resources.</p:documentation>
    <px:join-manifests name="resources">
        <p:input port="source">
            <p:pipe port="resources" step="for-each"/>
        </p:input>
    </px:join-manifests>
    <p:sink/>

    <p:documentation>Join all metadata into one metadata set.</p:documentation>
    <p:group name="metadata">
        <p:output port="result"/>
        <p:wrap-sequence wrapper="c:metadata">
            <p:input port="source">
                <p:pipe port="manifest" step="for-each"/>
            </p:input>
        </p:wrap-sequence>
        <p:unwrap match="c:metadata[parent::c:metadata]"/>
    </p:group>
    <p:sink/>

    <p:documentation>Make id-mapping.</p:documentation>
    <p:group name="id-mapping">
        <p:output port="result"/>
        <p:xslt>
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
                        <p:with-option name="attribute-value"
                            select="//c:entry[@reverse-media-overlay=$original-content-href]/@href">
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
    </p:group>
    <p:sink/>

</p:declare-step>
