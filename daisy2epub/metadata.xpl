<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:opf="http://www.idpf.org/2007/opf"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    type="d2e:metadata" version="1.0">
    
    <p:input port="source" sequence="true"/>
    <p:output port="result"/>
    
    <p:documentation><![CDATA[
            input: metadata@navigation
            input: metadata@media-overlay
            input: metadata@documents
            primary output: "result"
    ]]></p:documentation>
    
    <p:wrap-sequence wrapper="c:metadata"/>
    <p:unwrap match="c:metadata[parent::c:metadata]"/>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="metadata2opf-metadata.xsl"/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
