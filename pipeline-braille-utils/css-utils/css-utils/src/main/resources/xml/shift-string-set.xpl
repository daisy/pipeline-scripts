<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:shift-string-set"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Move 'string-set' declarations to boxes.
    </p:documentation>
    
    <p:input port="source" sequence="true">
        <p:documentation>
            Boxes must be represented by css:box elements. 'string-set' properties must be declared
            in css:string-set attributes, and must conform to
            http://snaekobbi.github.io/braille-css-spec/#the-string-set-property.
        </p:documentation>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:documentation>
            For each non-css:box element in the input that is not a descendant of an inline css:box,
            if it has a css:string-set attribute it is moved to the first following css:box. If this
            css:box element already has a css:string-set attribute in the input, the 'string-set'
            declarations are prepended to it.
        </p:documentation>
    </p:output>
    
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    
    <p:wrap-sequence wrapper="_"/>
    
    <px:message message="[progress css:shift-string-set 100 shift-string-set.xsl]"/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="shift-string-set.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:filter select="/_/*"/>
    
</p:declare-step>
