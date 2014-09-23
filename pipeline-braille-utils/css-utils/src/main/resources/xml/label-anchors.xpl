<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:label-anchors"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <!--
        Add a @css:anchor attribute to elements that are references by a target-text, target-string
        or target-counter function. It is not impossible that two or more elements get the same
        anchor name.
    -->
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
    
    <px:xslt-for-each>
        <p:input port="stylesheet">
            <p:document href="label-anchors.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </px:xslt-for-each>
    
</p:declare-step>
