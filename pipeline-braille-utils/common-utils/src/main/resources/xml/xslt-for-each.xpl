<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:xslt-for-each"
                name="main"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:input port="iteration-source" sequence="true" primary="true"/>
    <p:input port="stylesheet"/>
    <p:input port="parameters" kind="parameter"/>
    <p:output port="result" sequence="true" primary="true"/>
    
    <p:import href="select-by-position.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    
    <px:message message="[progress px:xslt-for-each 100 px:xslt-for-each.for-each]"/>
    <p:for-each>
        <px:message>
            <p:with-option name="message" select="concat('[progress px:xslt-for-each.for-each 1/',(p:iteration-size() * 2),' px:select-by-position]')"/>
            <p:input port="source">
                <p:pipe step="main" port="iteration-source"/>
            </p:input>
        </px:message>
        <px:select-by-position name="select">
            <p:with-option name="position" select="p:iteration-position()">
                <p:empty/>
            </p:with-option>
        </px:select-by-position>
        
        <px:message>
            <p:with-option name="message" select="concat('[progress px:xslt-for-each.for-each 1/',(p:iteration-size() * 2),' ',tokenize(base-uri(/*),'/')[last()],']')"/>
            <p:input port="source">
                <p:pipe step="select" port="matched"/>
                <p:pipe step="select" port="not-matched"/>
            </p:input>
        </px:message>
        <p:xslt name="xslt">
            <p:input port="stylesheet">
                <p:pipe step="main" port="stylesheet"/>
            </p:input>
            <p:input port="parameters">
                <p:pipe step="main" port="parameters"/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
</p:declare-step>
