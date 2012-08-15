<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-inline-prefixes="px css xsl"
    type="px:zedai-to-pef.translation" name="zedai-to-pef.translation" version="1.0">

    <p:input port="source" primary="true" px:media-type="application/z3998-auth+xml"/>
    <p:output port="result" primary="true" px:media-type="application/z3998-auth+xml"/>
    <p:option name="translator" required="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <!-- Identify blocks -->
    
    <p:xslt name="blocks">
        <p:input port="stylesheet">
            <p:document href="../xslt/identify-blocks.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <!-- Load translator from URL -->
    
    <p:load name="translator">
        <p:with-option name="href" select="$translator">
            <p:empty/>
        </p:with-option>
    </p:load>

    <!-- Translate each block -->
    
    <p:group>
        <p:variable name="translator-type" select="if (/xsl:stylesheet) then 'stylesheet'
            else if (/p:declare-step or /p:pipeline) then 'pipeline' else '?'">
            <p:pipe step="translator" port="result"/>
        </p:variable>
        
        <p:viewport match="css:block">
            <p:viewport-source>
                <p:pipe step="blocks" port="result"/>
            </p:viewport-source>
            
            <p:choose>
                <p:when test="$translator-type='stylesheet'">
                    <p:xslt>
                        <p:input port="stylesheet">
                            <p:pipe step="translator" port="result"/>
                        </p:input>
                        <p:input port="parameters">
                            <p:empty/>
                        </p:input>
                    </p:xslt>
                </p:when>
                
                <p:when test="$translator-type='pipeline'">
                    <cx:eval>
                        <p:input port="pipeline">
                            <p:pipe step="translator" port="result"/>
                        </p:input>
                        <p:input port="options">
                            <p:empty/>
                        </p:input>
                    </cx:eval>
                </p:when>
                <p:otherwise>
                    <!-- Please provide an XSLT or an XProc! -->
                    <p:identity/>
                </p:otherwise>
            </p:choose>
        </p:viewport>
        
        <p:unwrap match="css:block"/>
        
    </p:group>
    
</p:declare-step>
