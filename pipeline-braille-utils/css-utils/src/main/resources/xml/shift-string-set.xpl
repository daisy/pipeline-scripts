<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:shift-string-set"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <!--
        Remove @css:string-set attributes from non css:box elements and add them to the following
        css:box's @css:string-entry attribute.
    -->
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>
    
    <p:wrap-sequence wrapper="_"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="shift-string-set.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:filter select="/_/*"/>
    
</p:declare-step>
