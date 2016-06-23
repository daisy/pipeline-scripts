<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:eval-target-content"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Evaluate target-content() values.
    </p:documentation>
    
    <p:input port="source" sequence="true">
        <p:documentation>
            target-content() values in the input must be represented by css:content
            elements. Elements that are referenced by a target-content() value must be indicated
            with a css:id attribute that matches the css:content element's target attribute.
        </p:documentation>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:documentation>
            css:content elements are replaced by the child nodes of their target element (the
            element whose css:id attribute corresponds with the css:content element's target
            attribute). Elements get a css:anchor attribute that matches the xml:id attribute of the
            target element.
        </p:documentation>
    </p:output>
    
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    
    <p:wrap-sequence wrapper="css:_"/>
    
    <px:message message="[progress css:eval-target-content 100 eval-target-content.xsl]"/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="eval-target-content.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:filter select="/css:_/*"/>
    
</p:declare-step>
