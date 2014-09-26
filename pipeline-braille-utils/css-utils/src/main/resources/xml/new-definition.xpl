<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                type="css:new-definition" name="main"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:input port="source" primary="true"/>
    <p:input port="definition"/>
    <p:output port="result"/>
    
    <p:add-attribute match="xsl:include" attribute-name="href" name="include">
        <p:input port="source">
            <p:inline>
                <xsl:include/>
            </p:inline>
        </p:input>
        <p:with-option name="attribute-value" select="resolve-uri('new-definition.xsl')">
            <p:inline>
                <irrelevant/>
            </p:inline>
        </p:with-option>
    </p:add-attribute>
    
    <p:insert name="stylesheet" position="first-child">
        <p:input port="source">
            <p:pipe step="main" port="definition"/>
        </p:input>
        <p:input port="insertion">
            <p:pipe step="include" port="result"/>
        </p:input>
    </p:insert>
    
    <p:xslt>
        <p:input port="source">
            <p:pipe step="main" port="source"/>
        </p:input>
        <p:input port="stylesheet">
            <p:pipe step="stylesheet" port="result"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
