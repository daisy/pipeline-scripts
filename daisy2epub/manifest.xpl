<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:opf="http://www.idpf.org/2007/opf"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    type="d2e:manifest" version="1.0">
    
    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" primary="false">
        <p:pipe port="result" step="opf-manifest"/>
    </p:output>
    <p:output port="manifest" primary="false">
        <p:pipe port="result" step="manifest"/>
    </p:output>
    
    <p:documentation><![CDATA[
            input: manifest@navigation
            input: manifest@media-overlay
            input: manifest@documents
            input: manifest@resources
            primary output: result
    ]]></p:documentation>
    
    <px:join-manifests name="input-manifest"/>
    <p:sink/>
    
    <px:create-manifest>
        <p:with-option name="base" select="$epub-dir"/>
    </px:create-manifest>
    <px:add-manifest-entry name="navigation-manifest">
        <p:with-option name="href" select="concat(substring-after($content-dir,$epub-dir),'navigation.xhtml')"/>
        <p:with-option name="media-type" select="'application/xhtml+xml'"/>
    </px:add-manifest-entry>
    <p:sink/>
    
    <px:join-manifests name="manifest">
        <p:input port="source">
            <p:pipe port="result" step="navigation-manifest"/>
            <p:pipe port="result" step="input-manifest"/>
        </p:input>
    </px:join-manifests>
    <p:xslt name="opf-manifest">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="manifest2opf-manifest.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>
    
</p:declare-step>
