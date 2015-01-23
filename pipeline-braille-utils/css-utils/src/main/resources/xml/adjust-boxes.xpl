<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:adjust-boxes"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Adjust the shape and position of boxes so that their content fits within their edges.
    </p:documentation>
    
    <p:input port="source">
        <p:documentation>
            The input is assumed to be a tree-of-boxes representation of a document that consists of
            only css:box elements and text nodes (and css:_ elements if they are document
            elements). Text and inline boxes must not have sibling block boxes.  Computed values of
            'margin-left', 'margin-right', 'border-left', 'border-top', 'border-right',
            'border-bottom' and 'text-indent' properties must be declared in css:margin-left,
            css:margin-right, css:border-left, css:border-top, css:border-right, css:border-bottom
            and css:text-indent attributes. Boxes must have no padding.
        </p:documentation>
    </p:input>
    
    <p:output port="result">
        <p:documentation>
            Block boxes are repositioned and reshaped in such a way that their content (including
            the first line box) does not overflow the left and right margin edges (i.e. the left and
            right content edges of the container box), and does not overflow the left and right
            border edges if a left or right border is present. While the edges of boxes may be
            adjusted, the text content and borders remain at their original position unless it would
            break the constraints above.
        </p:documentation>
    </p:output>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="adjust-boxes.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
