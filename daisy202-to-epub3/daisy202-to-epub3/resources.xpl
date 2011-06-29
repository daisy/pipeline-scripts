<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
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
        <xd:option name="subcontent-dir">URI to the directory where all the EPUB 3 content should be
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
    <p:output port="manifest"/>

    <p:option name="daisy-dir" required="true"/>
    <p:option name="subcontent-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/mediatype.xpl"/>

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
    <p:for-each name="smil-resources">
        <p:output port="result"/>
        <p:iteration-source>
            <p:pipe port="mediaoverlay" step="resources"/>
        </p:iteration-source>
        <p:xslt>
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
        <p:with-option name="target" select="$subcontent-dir"/>
    </px:fileset-copy>

</p:declare-step>
