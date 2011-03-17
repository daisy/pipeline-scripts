<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:opf="http://www.idpf.org/2007/opf"
    type="d2e:flow" version="1.0">
    
    <p:documentation><![CDATA[
            input: result@ncc
            primary output: "manifest"
    ]]></p:documentation>
    
    <p:input port="source"/>
    <p:output port="manifest"/>

    <p:option name="content-dir" required="true"/>

    <p:import href="daisy2epub-library.xpl"/>

    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc2flow-manifest.xsl"/>
        </p:input>
    </p:xslt>

</p:declare-step>
