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
    
    <!-- Inline CSS -->
    
    <css:inline>
        <p:with-option name="default-stylesheet" select="$default-stylesheet"/>
    </css:inline>
    
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
