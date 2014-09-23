<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:make-anonymous-block-boxes"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <!--
        Group inline boxes that have one or more sibling block boxes, or that have no block box
        ancestor, inside anonymous block boxes.
        See http://snaekobbi.github.io/braille-css-spec/#anonymous-boxes.
    -->
    
    <!--
        Assumptions:
        - no block boxes inside inline boxes
        - all content inside inline boxes
        - no css:_ left
    -->
    
    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:wrap match="css:box[@type='inline'][parent::css:root or
                                           preceding-sibling::css:box[@type='block'] or
                                           following-sibling::css:box[@type='block']]"
            group-adjacent="true()"
            wrapper="css:_box_"/>
    
    <p:add-attribute match="css:_box_" attribute-name="type" attribute-value="block"/>
    
    <p:rename match="css:_box_" new-name="css:box"/>
    
</p:declare-step>
