<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" type="pxi:daisy202-to-epub3-resources" name="resources" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Copy the auxiliary resources from the DAISY 2.02 fileset to the EPUB 3 fileset, and return a manifest of all the resulting files.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:input port="resource-manifests">List of auxiliary resources, like audio, stylesheets and graphics.</xd:input>
        <xd:output port="manifest">List of stored files.</xd:output>
        <xd:output port="store-complete">Pipe connection for 'p:store'-dependencies.</xd:output>
        <xd:option name="subcontent-dir">URI to the directory where all the EPUB 3 content should be stored.</xd:option>
        <xd:option name="epub-dir">URI to the directory where the OCF is being created.</xd:option>
        <xd:import href="../utilities/file-utils/fileutils-library.xpl">For filesystem operations.</xd:import>
        <xd:import href="../utilities/file-utils/fileset-library.xpl">For manipulating filesets.</xd:import>
        <xd:import href="../utilities/mediatype-utils/mediatype.xpl">For determining media types.</xd:import>
    </p:documentation>

    <p:input port="daisy-smil" sequence="true"/>
    <p:input port="daisy-content" sequence="true"/>
    <p:output port="manifest" primary="true"/>

    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>
    <p:option name="include-mediaoverlay-resources" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/mediatype.xpl"/>

    <p:xslt name="content-resources">
        <p:input port="source">
            <p:pipe port="daisy-content" step="resources"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="daisy202-content-to-resource-fileset.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>
    <p:for-each name="smil-resources">
        <p:output port="result" sequence="true"/>
        <p:iteration-source>
            <p:pipe port="daisy-smil" step="resources"/>
        </p:iteration-source>
        <p:choose>
            <p:when test="$include-mediaoverlay-resources='true'">
                <p:xslt>
                    <p:input port="parameters">
                        <p:empty/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:document href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/smil-to-audio-fileset.xsl"/>
                    </p:input>
                </p:xslt>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <p:sink/>
    <px:fileset-join>
        <p:input port="source">
            <p:pipe port="result" step="content-resources"/>
            <p:pipe port="result" step="smil-resources"/>
        </p:input>
    </px:fileset-join>
    <px:mediatype-detect name="iterate.mediatype"/>
    <px:fileset-copy>
        <p:with-option name="target" select="$content-dir"/>
    </px:fileset-copy>

</p:declare-step>
