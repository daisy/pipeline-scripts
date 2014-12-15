<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:parse-properties"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:option name="properties" select="'#all'"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="parse-properties.xsl"/>
        </p:input>
        <p:with-param name="property-names" select="$properties"/>
    </p:xslt>
    
</p:declare-step>
