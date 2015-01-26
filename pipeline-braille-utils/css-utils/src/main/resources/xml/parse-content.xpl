<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:parse-content"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Insert generated content from 'content' properties.
    </p:documentation>
    
    <p:input port="source">
        <p:documentation>
            The 'content' properties of elements in the input must be declared in css:content
            attributes, and must conform to
            http://snaekobbi.github.io/braille-css-spec/#the-content-property.
        </p:documentation>
    </p:input>
    
    <p:output port="result">
        <p:documentation>
            For each element in the input with a css:content attribute, the content list in that
            attribute is parsed, partly evaluated, and inserted in the output in place of the
            element's original content. String values and attr() values are evaluated to
            text. target-text(), target-string(), target-counter() and leader() values are inserted
            as css:target-string, css:target-text, css:target-counter and css:leader
            elements. string() and counter() values are invalid.
        </p:documentation>
    </p:output>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="parse-content.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
