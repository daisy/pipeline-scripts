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
            The input is assumed to be a tree-of-boxes representation of a document where boxes are
            represented by css:box elements. The document root must be a box or a css:_ element. The
            parent of a box must be another box (or a css:_ element if it's the document
            root). Inline boxes must not have non-inline descendant boxes. Table-cell boxes must
            have a parent table box and table boxes must have only table-cell child boxes. All other
            nodes must have at least one inline box ancestor.
        </p:documentation>
    </p:input>
    
    <p:output port="result">
        <p:documentation>
            Adjacent inline boxes with one or more sibling block or table boxes are grouped and
            wrapped in an anonymous block box.
        </p:documentation>
    </p:output>
    
    <p:wrap match="css:box[@type='inline'][preceding-sibling::css:box[@type=('block','table')] or
                                           following-sibling::css:box[@type=('block','table')]]"
            group-adjacent="true()"
            wrapper="css:_box_"/>
    
    <p:add-attribute match="css:_box_" attribute-name="type" attribute-value="block"/>
    
    <p:rename match="css:_box_" new-name="css:box"/>
    
</p:declare-step>
