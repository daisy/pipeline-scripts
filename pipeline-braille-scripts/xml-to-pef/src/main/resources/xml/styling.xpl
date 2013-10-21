<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:css="http://xmlcalabash.com/ns/extensions/braille-css"
    exclude-inline-prefixes="#all"
    type="pxi:styling" name="styling" version="1.0">
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    
    <p:option name="default-stylesheet" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
    
    <p:choose>
        <p:when test="$default-stylesheet!=''">
            <p:add-attribute match="/link" attribute-name="href" name="link">
                <p:input port="source">
                    <p:inline>
                        <link rel="stylesheet" media="embossed" type="text/css"/>
                    </p:inline>
                </p:input>
                <p:with-option name="attribute-value" select="$default-stylesheet"/>
            </p:add-attribute>
            <p:insert match="//*[name()='head'][1]" position="first-child">
                <p:input port="source">
                    <p:pipe port="source" step="styling"/>
                </p:input>
                <p:input port="insertion">
                    <p:pipe step="link" port="result"/>
                </p:input>
            </p:insert>
        </p:when>
        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:pipe port="source" step="styling"/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    
    <!-- Inline CSS -->
    
    <css:inline/>
    
    <!-- Number lists -->
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="handle-list-item.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
