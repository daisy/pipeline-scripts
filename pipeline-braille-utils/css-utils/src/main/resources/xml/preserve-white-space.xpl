<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:preserve-white-space"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Identify pieces of text that contain preserved white space.
    </p:documentation>
    
    <p:input port="source">
        <p:documentation>
            The 'white-space' properties of elements in the input must be declared in
            css:white-space attributes, and must conform to
            http://snaekobbi.github.io/braille-css-spec/#the-white-space-property.
        </p:documentation>
    </p:input>
    
    <p:output port="result">
        <p:documentation>
            Each text node whose parent element's white-space property has a computed value of 'pre'
            is wrapped in a css:white-space element.
        </p:documentation>
    </p:output>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="preserve-white-space.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
