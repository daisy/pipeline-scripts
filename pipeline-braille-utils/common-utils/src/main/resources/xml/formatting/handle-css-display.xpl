<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="px:handle-css-display"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="handle-css-display-1.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="handle-css-display-2.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="handle-css-display-3.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
