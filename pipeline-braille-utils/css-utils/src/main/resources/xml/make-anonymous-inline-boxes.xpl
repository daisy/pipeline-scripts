<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:make-anonymous-inline-boxes"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Break inline boxes around contained block boxes and create anonymous inline boxes
        (http://snaekobbi.github.io/braille-css-spec/#anonymous-boxes).
    </p:documentation>
    
    <p:input port="source">
        <p:documentation>
            The input is assumed to be a tree-of-boxes representation of a document. In other words,
            the input should consist of only css:root, css:box and css:_ elements and text nodes.
        </p:documentation>
    </p:input>
    
    <p:output port="result">
        <p:documentation>
            Inline boxes that have descendant block boxes are either unwrapped, or if the element
            has one or more css:* attributes, renamed to css:_. For such elements, the inherited
            properties (specified in the element's style attribute) are moved to the next preserved
            descendant box, and 'inherit' values on the next preserved descendant box are
            concretized. css:root and css:_ elements are retained. All adjacent text that is not
            already contained in an inline box is wrapped into one.
        </p:documentation>
    </p:output>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="make-anonymous-inline-boxes.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
