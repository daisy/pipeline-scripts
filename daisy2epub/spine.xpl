<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/" xmlns:opf="http://www.idpf.org/2007/opf"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    type="d2e:spine" version="1.0">

    <p:input port="source" sequence="true"/>
    <p:output port="result" primary="false">
        <p:pipe port="result" step="opf-spine"/>
    </p:output>

    <p:documentation><![CDATA[
            input: manifest@documents
            output: "result"
    ]]></p:documentation>

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
