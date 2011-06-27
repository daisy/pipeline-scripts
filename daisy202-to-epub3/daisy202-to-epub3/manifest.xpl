<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:opf="http://www.idpf.org/2007/opf"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
    type="px:manifest" name="manifest" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Compile the manifest in the OPF-format</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:option name="content-dir">URI to the directory where all the EPUB 3 content should be
            stored.</xd:option>
        <xd:option name="epub-dir">URI to the directory where the OCF is being created.</xd:option>
        <xd:input port="source-manifest">A sequence of manifests of content documents, media
            overlays and auxiliary resources.</xd:input>
        <xd:output port="opf-manifest">Same as result manifest but in the OPF-format.</xd:output>
        <xd:output port="result-manifest">The source manifest with the addition of the navigation
            document entry.</xd:output>
        <xd:import href="../utilities/file-utils/fileset-library.xpl">For manipulating
            filesets.</xd:import>
    </p:documentation>

    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>

    <p:input port="source-manifest" sequence="true" primary="false"/>
    <!--p:output port="opf-manifest" primary="false">
        <p:pipe port="result" step="opf-manifest"/>
    </p:output-->
    <p:output port="result-manifest" primary="true">
        <!--p:pipe port="result" step="result-manifest"/-->
    </p:output>

    <p:import href="../../utilities/fileset-utils/fileset-utils/xproc/fileset-create.xpl"/>
    <p:import href="../../utilities/fileset-utils/fileset-utils/xproc/fileset-join.xpl"/>
    <p:import href="../../utilities/fileset-utils/fileset-utils/xproc/fileset-add-entry.xpl"/>

    <px:fileset-join name="input-manifest">
        <p:input port="source">
            <p:pipe port="source-manifest" step="manifest"/>
        </p:input>
    </px:fileset-join>
    <!--p:sink/-->

    <!--px:fileset-create>
        <p:with-option name="base" select="$epub-dir"/>
    </px:fileset-create>
    <px:fileset-add-entry name="navigation-manifest">
        <p:with-option name="href"
            select="concat(substring-after($content-dir,$epub-dir),'navigation.xhtml')"/>
        <p:with-option name="media-type" select="'application/xhtml+xml'"/>
    </px:fileset-add-entry>
    <p:sink/-->

    <!--px:fileset-join name="result-manifest">
        <p:input port="source">
            <p:pipe port="result" step="navigation-manifest"/>
            <p:pipe port="result" step="input-manifest"/>
        </p:input>
    </px:fileset-join-->
    <!--p:xslt name="opf-manifest">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="manifest2opf-manifest.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/-->

</p:declare-step>
