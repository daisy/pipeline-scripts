<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:make-anonymous-block-boxes"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Wrap inline boxes that have sibling block boxes in anonymous block boxes.
        (http://snaekobbi.github.io/braille-css-spec/#anonymous-boxes).
    </p:documentation>
    
    <p:input port="source">
        <p:documentation>
            The input is assumed to be a tree-of-boxes representation of a document that consists of
            only a css:root document node, css:box elements and text nodes. There should be no block
            boxes inside inline boxes, and there should be no css:_ elements.
        </p:documentation>
    </p:input>
    
    <p:output port="result">
        <p:documentation>
            Adjacent inline boxes with one or more sibling block boxes are grouped and wrapped in an
            anonymous block box. Inline boxes that are not already contained in a block box
            are wrapped in an anonymous block box as well.
        </p:documentation>
    </p:output>
    
    <p:wrap match="css:box[@type='inline'][parent::css:root or
                                           preceding-sibling::css:box[@type='block'] or
                                           following-sibling::css:box[@type='block']]"
            group-adjacent="true()"
            wrapper="css:_box_"/>
    
    <p:add-attribute match="css:_box_" attribute-name="type" attribute-value="block"/>
    
    <p:rename match="css:_box_" new-name="css:box"/>
    
</p:declare-step>
