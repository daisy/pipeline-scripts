<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/" xmlns:opf="http://www.idpf.org/2007/opf"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" type="d2e:metadata" name="metadata"
    version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Compile the metadata in the OPF-format</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:input port="metadata">Sequence of metadata sets from other conversion steps, to be included in the final set of OPF-metadata.</xd:input>
        <xd:output port="opf-metadata">Metadata in OPF-format.</xd:output>
    </p:documentation>

    <p:input port="metadata" sequence="true" primary="false"/>
    <p:output port="opf-metadata" primary="false">
        <p:pipe port="result" step="opf-metadata"/>
    </p:output>
    
    <p:wrap-sequence wrapper="c:metadata">
        <p:input port="source">
            <p:pipe port="metadata" step="metadata"/>
        </p:input>
    </p:wrap-sequence>
    <p:unwrap match="c:metadata[parent::c:metadata]"/>
    <p:xslt name="opf-metadata">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="metadata2opf-metadata.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>

</p:declare-step>
