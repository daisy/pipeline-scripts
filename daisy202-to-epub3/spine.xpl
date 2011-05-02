<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/" xmlns:opf="http://www.idpf.org/2007/opf"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" type="d2e:spine" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Compile the spine in the OPF-format based on the OPF-manifest.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:input port="opf-manifest">Manifest in OPF-format.</xd:input>
        <xd:output port="opf-spine">Spine in OPF-format.</xd:output>
    </p:documentation>

    <p:input port="opf-manifest" sequence="true"/>
    <p:output port="opf-spine" primary="false">
        <p:pipe port="result" step="opf-spine"/>
    </p:output>

    <p:xslt name="opf-spine">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="manifest2opf-spine.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>

</p:declare-step>
