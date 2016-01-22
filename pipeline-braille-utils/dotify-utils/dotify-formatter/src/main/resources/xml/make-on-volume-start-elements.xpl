<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                type="pxi:make-on-volume-start-elements"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:input port="source"/>
    <p:output port="result" sequence="true"/>
    
    <p:xslt name="xslt">
        <p:input port="stylesheet">
            <p:document href="make-on-volume-start-elements.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="xslt" port="result"/>
            <p:pipe step="xslt" port="secondary"/>
        </p:input>
    </p:identity>
    
</p:declare-step>
