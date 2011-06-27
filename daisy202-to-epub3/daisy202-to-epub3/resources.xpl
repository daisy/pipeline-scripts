<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:opf="http://www.idpf.org/2007/opf"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" type="px:resources" name="resources"
    version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Copy the auxiliary resources from the DAISY 2.02 fileset to the EPUB 3 fileset,
            and return a manifest of all the resulting files.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:input port="resource-manifests">List of auxiliary resources, like audio, stylesheets and
            graphics.</xd:input>
        <xd:output port="manifest">List of stored files.</xd:output>
        <xd:output port="store-complete">Pipe connection for 'p:store'-dependencies.</xd:output>
        <xd:option name="daisy-dir">URI to the directory containing the NCC.</xd:option>
        <xd:option name="content-dir">URI to the directory where all the EPUB 3 content should be
            stored.</xd:option>
        <xd:option name="epub-dir">URI to the directory where the OCF is being created.</xd:option>
        <xd:import href="../utilities/file-utils/fileutils-library.xpl">For filesystem
            operations.</xd:import>
        <xd:import href="../utilities/file-utils/fileset-library.xpl">For manipulating
            filesets.</xd:import>
        <xd:import href="../utilities/mediatype-utils/mediatype.xpl">For determining media
            types.</xd:import>
    </p:documentation>

    <p:input port="mediaoverlay" sequence="true"/>
    <p:input port="content" sequence="true"/>
    <p:output port="manifest" primary="true">
        <!--p:pipe port="result" step="manifest"/-->
    </p:output>
    <!--p:output port="store-complete" primary="false" sequence="true">
        <p:pipe port="store" step="iterate"/>
    </p:output-->

    <p:option name="daisy-dir" required="true"/>
    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>

    <!--p:import href="../../utilities/file-utils/fileutils-library.xpl"/-->
    <p:import href="../../utilities/fileset-utils/xproc/fileset-join.xpl"/>
    <p:import href="../../utilities/fileset-utils/xproc/fileset-copy.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/fileutils.xpl"/>
    <p:import href="../../utilities/mediatype-utils/mediatype-utils/mediatype.xpl"/>

    <!--p:documentation>Merge all resource manifests and remove duplicate entries.</p:documentation>
    <p:group>
        <p:output port="result"/>
        <px:fileset-join>
            <p:input port="source">
                <p:pipe port="resource-manifests" step="resources"/>
            </p:input>
        </px:fileset-join>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="resources-manifest-cleanup.xsl"/>
            </p:input>
        </p:xslt>
        </p:group-->

    <p:xslt name="content-resources">
        <p:input port="source">
            <p:pipe port="content" step="resources"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="content2resources.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>
    <p:xslt name="smil-resources">
        <p:input port="source">
            <p:pipe port="mediaoverlay" step="resources"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="media-overlay2resources.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>
    <px:fileset-join>
        <p:input port="source">
            <p:pipe port="result" step="content-resources"/>
            <p:pipe port="result" step="smil-resources"/>
        </p:input>
    </px:fileset-join>

    <!--px:fileset-join/>
    <px:fileset-copy>
        <p:with-option name="target" select="$content-dir"/>
    </px:fileset-copy-->
    <!--p:documentation>
        <xd:short>Iterate through all resources and copy them from the DAISY 2.02 fileset to the
            EPUB 3 fileset.</xd:short>
        <xd:output port="manifest">Sequence of manifests representing each stored auxiliary
            resource.</xd:output>
        <xd:output port="store">Sequence of results from storing the auxiliary resources, allowing
            other steps to depend on the files being stored.</xd:output>
    </p:documentation>
    <p:for-each name="iterate">
        <p:output port="manifest" primary="false">
            <p:pipe port="result" step="iterate.manifest"/>
        </p:output>
        <p:output port="store" primary="false">
            <p:pipe port="result" step="iterate.copy"/>
        </p:output>

        <p:iteration-source select="//c:entry"/>
        <p:variable name="href" select="/*/@href"/>
        <p:variable name="media-type" select="/*/@media-type"/>
        <p:variable name="reverse-media-overlay" select="/*/@reverse-media-overlay"/>
        <p:variable name="original-href" select="/*/@original-href"/>

        <p:variable name="copy-target" select="concat($content-dir,$href)"/>

        <p:identity name="iterate.source"/>

        <cxf:mkdir name="iterate.mkdir">
            <p:with-option name="href" select="replace($copy-target,'[^/]+$','')"/>
        </cxf:mkdir>
        <cxf:copy name="iterate.copy">
            <p:with-option name="href" select="concat($daisy-dir,$href)">
                <p:pipe port="result" step="iterate.mkdir"/>
            </p:with-option>
            <p:with-option name="target" select="$copy-target"/>
        </cxf:copy>

        <px:mediatype-detect name="iterate.mediatype">
            <p:with-option name="href" select="$href"/>
        </px:mediatype-detect>
        <p:sink/>
        <px:fileset-create>
            <p:with-option name="base" select="$epub-dir"/>
        </px:fileset-create>
        <px:add-manifest-entry>
            <p:with-option name="href"
                select="concat(substring-after($content-dir,$epub-dir),$href)"/>
            <p:with-option name="media-type"
                select="if ($media-type) then $media-type else /*/@type">
                <p:pipe port="result" step="iterate.mediatype"/>
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
        <p:identity name="iterate.manifest"/>
        <p:sink/>
    </p:for-each-->

    <!--p:documentation>Make one manifest that references all auxiliary resources.</p:documentation>
    <px:join-manifests name="manifest">
        <p:input port="source">
            <p:pipe port="manifest" step="iterate"/>
        </p:input>
    </px:join-manifests>
    <p:sink/-->

</p:declare-step>
