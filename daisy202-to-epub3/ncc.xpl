<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" xmlns:xd="http://pipeline.daisy.org/ns/sample/doc"
    type="d2e:ncc" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Load the DAISY 2.02 NCC.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:import href="../utilities/files/fileset-library.xpl">For manipulating
            filesets.</xd:import>
        <xd:import href="../utilities/html/html-library.xpl">For loading HTML.</xd:import>
        <xd:option name="href">URI to the NCC.</xd:option>
        <xd:output port="ncc">The NCC as well-formed XHTML.</xd:output>
        <xd:output port="resource-manifest">Auxiliary resources referenced from the NCC.</xd:output>
        <xd:output port="metadata">Metadata from the &lt;head/&gt; of the NCC.</xd:output>
        <xd:output port="flow">SMIL-files listed in playback order.</xd:output>
    </p:documentation>

    <p:option name="href" required="true"/>

    <p:output port="ncc" primary="false">
        <p:pipe port="result" step="ncc.ncc"/>
    </p:output>
    <p:output port="resource-manifest" primary="false">
        <p:pipe port="result" step="ncc.resources"/>
    </p:output>
    <p:output port="metadata" primary="false">
        <p:pipe port="result" step="ncc.metadata"/>
    </p:output>
    <p:output port="flow" primary="false">
        <p:pipe port="result" step="ncc.flow"/>
    </p:output>

    <p:import href="../utilities/files/fileset-library.xpl"/>
    <p:import href="../utilities/html/html-library.xpl"/>
    
    <p:documentation>Loads the NCC.</p:documentation>
    <px:load-html name="ncc.ncc">
        <p:with-option name="href" select="$href"/>
    </px:load-html>
    
    <p:documentation>Makes a list of resources referenced from the NCC.</p:documentation>
    <p:xslt name="ncc.resources">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc2resources.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>
    
    <p:documentation>Makes a list of metadata referenced from the NCC.</p:documentation>
    <p:xslt name="ncc.metadata">
        <p:input port="source">
            <p:pipe port="result" step="ncc.ncc"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc2metadata.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>
    
    <p:documentation>Makes a chronologically ordered list of SMIL-files referenced from the NCC.</p:documentation>
    <p:xslt name="ncc.flow">
        <p:input port="source">
            <p:pipe port="result" step="ncc.ncc"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc2flow-manifest.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>

</p:declare-step>
