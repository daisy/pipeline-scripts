<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                type="px:css-eval-string-set"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="css-eval-string-set.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
