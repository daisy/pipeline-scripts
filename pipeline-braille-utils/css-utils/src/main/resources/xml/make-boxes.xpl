<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:make-boxes"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <!--
        Generate boxes from elements, based on their @css:display attribute. Elements that don't
        generate boxes but still have information attached (e.g. @css:page, @css: or anchor
        @css:string-set) become "css:_" elements.
    -->
    
    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="make-boxes.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
