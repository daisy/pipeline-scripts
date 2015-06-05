<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:padding-to-margin"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Convert padding into non-collapsing margins
        (http://snaekobbi.github.io/braille-css-spec/#collapsing-margins).
    </p:documentation>
    
    <p:input port="source">
        <p:documentation>
            The input is assumed to be a tree-of-boxes representation of a document, where boxes are
            represented by css:box elements. The 'padding' and 'margin' properties of boxes must be
            declared in css:padding-left, css:padding-top, css:padding-right, css:padding-bottom,
            css:margin-left, css:margin-top, css:margin-right and css:margin-bottom attributes.
        </p:documentation>
    </p:input>
    
    <p:output port="result">
        <p:documentation>
            For each box with 'padding' properties, the box's content is wrapped in an anonymous
            block box. The box's css:padding-* attributes are moved to the anonymous box and renamed
            to css:margin-*. A css:collapsing-margins attribute with value 'no' is added to the
            anonymous box. Any 'inherit' values of non-inheriting properties (specified in style
            attributes) of the box's child boxes are concretized.
        </p:documentation>
    </p:output>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="padding-to-margin.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
