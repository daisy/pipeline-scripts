<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" type="pxi:daisy202-to-epub3-ncc" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Load the DAISY 2.02 NCC.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:import href="../utilities/html-utils/html-library.xpl">For loading HTML.</xd:import>
        <xd:option name="href">URI to the NCC.</xd:option>
        <xd:output port="ncc">The NCC as well-formed XHTML.</xd:output>
        <xd:output port="resource-manifest">Auxiliary resources referenced from the NCC.</xd:output>
        <xd:output port="metadata">Metadata from the &lt;head/&gt; of the NCC.</xd:output>
        <xd:output port="flow">SMIL-files listed in playback order.</xd:output>
    </p:documentation>

    <p:option name="href" required="true"/>

    <p:output port="ncc" primary="false">
        <p:pipe port="result" step="ncc"/>
    </p:output>
    <p:output port="flow" primary="false">
        <p:pipe port="result" step="flow"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/html-utils/html-library.xpl"/>

    <p:documentation>Loads the NCC.</p:documentation>
    <px:html-load name="ncc">
        <p:with-option name="href" select="$href"/>
    </px:html-load>

    <p:documentation>Makes a chronologically ordered list of SMIL-files referenced from the
        NCC.</p:documentation>
    <p:xslt name="flow">
        <p:input port="source">
            <p:pipe port="result" step="ncc"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc-to-flow-fileset.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>

</p:declare-step>
