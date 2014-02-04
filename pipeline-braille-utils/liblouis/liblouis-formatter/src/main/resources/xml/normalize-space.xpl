<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:normalize-space"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-inline-prefixes="xsl"
    version="1.0">
    
    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:unwrap match="/*//*[not(ancestor::louis:semantics or ancestor::louis:styles or ancestor::louis:page-layout) and
                               not(self::louis:*) and
                               not(@louis:*) and
                               not(@xml:space) and
                               not(@css:target)]"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="normalize-space.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
