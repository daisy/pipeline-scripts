<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:opf="http://www.idpf.org/2007/opf"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
    type="px:metadata" name="metadata" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Compile the metadata in the OPF-format</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:input port="metadata">Sequence of metadata sets from other conversion steps, to be
            included in the final set of OPF-metadata.</xd:input>
        <xd:output port="opf-metadata">Metadata in OPF-format.</xd:output>
    </p:documentation>

    <p:input port="ncc" primary="true"/>
    <p:output port="opf-metadata" primary="false">
        <p:pipe port="result" step="opf-metadata"/>
    </p:output>

    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc2metadata.xsl"/>
        </p:input>
    </p:xslt>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="metadata2opf-metadata.xsl"/>
        </p:input>
    </p:xslt>
    <p:identity name="opf-metadata"/>
    <p:sink/>

</p:declare-step>
