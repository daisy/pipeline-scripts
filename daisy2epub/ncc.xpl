<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" type="d2e:ncc" version="1.0">
    
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

    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>

    <p:import href="fileset-library.xpl"/>
    <p:import href="html-library.xpl"/>
    
    <px:load-html name="ncc.ncc">
        <p:with-option name="href" select="$href"/>
    </px:load-html>
    
    <p:xslt name="ncc.resources">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc2resources.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>

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
