<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="px:css-shift-counter-reset"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <!--
        Remove @css:counter-reset attributes from non css:box elements and add them to the following
        css:box's @css:counter-entry attribute.
    -->
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>
    
    <p:wrap-sequence wrapper="_"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="css-shift-counter-reset.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:unwrap match="css:_[not(@*)]"/>
    
    <p:filter select="/_/*"/>
    
</p:declare-step>
