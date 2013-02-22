<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:format-box" name="format-box"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-inline-prefixes="#all"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true"/>
    <p:option name="temp-dir" required="true"/>
    <p:output port="result" sequence="false" primary="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-calabash/xproc/library.xpl"/>
    
    <p:viewport match="louis:box" name="format">
        
        <p:rename match="/*">
            <p:with-option name="new-name" select="name(/*/*[1])">
                <p:pipe step="format-box" port="source"/>
            </p:with-option>
            <p:with-option name="new-namespace" select="namespace-uri(/*/*[1])">
                <p:pipe step="format-box" port="source"/>
            </p:with-option>
        </p:rename>
        
        <p:delete match="/*/@*"/>
        
        <p:insert match="/*" position="first-child">
            <p:input port="insertion">
                <p:inline>
                    <louis:line>&#xA0;</louis:line>
                </p:inline>
            </p:input>
        </p:insert>
        
        <p:insert match="/*" position="last-child">
            <p:input port="insertion">
                <p:inline>
                    <louis:line>&#xA0;</louis:line>
                </p:inline>
            </p:input>
        </p:insert>
        
        <louis:translate-file paged="false">
            <p:input port="styles" select="/*/*[2]">
                <p:pipe step="format-box" port="source"/>
            </p:input>
            <p:input port="semantics" select="/*/*[3]">
                <p:pipe step="format-box" port="source"/>
            </p:input>
            <p:with-param port="page-layout" name="page-width" select="/*/@width">
                <p:pipe step="format" port="current"/>
            </p:with-param>
            <p:with-option name="temp-dir" select="$temp-dir"/>
        </louis:translate-file>
        
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/read-liblouis-output.xsl"/>
            </p:input>
            <p:with-param name="width" select="/*/@width">
                <p:pipe step="format" port="current"/>
            </p:with-param>
            <p:with-param name="margin-left" select="/*/@margin-left">
                <p:pipe step="format" port="current"/>
            </p:with-param>
            <p:with-param name="border-left" select="/*/@border-left">
                <p:pipe step="format" port="current"/>
            </p:with-param>
            <p:with-param name="border-right" select="/*/@border-right">
                <p:pipe step="format" port="current"/>
            </p:with-param>
            <p:with-param name="keep-empty-trailing-lines" select="'true'">
                <p:empty/>
            </p:with-param>
            <p:with-param name="crop-top" select="1">
                <p:empty/>
            </p:with-param>
            <p:with-param name="crop-bottom" select="1">
                <p:empty/>
            </p:with-param>
        </p:xslt>
        
        <p:rename match="/*" new-name="louis:box"/>
    </p:viewport>
    
</p:declare-step>
