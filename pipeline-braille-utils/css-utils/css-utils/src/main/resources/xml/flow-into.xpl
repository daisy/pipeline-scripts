<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:flow-into"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Channel elements into named flows.
    </p:documentation>
    
    <p:input port="source">
        <p:documentation>
            Elements in the input that participate in a named flow must be identified with css:flow
            attributes.
        </p:documentation>
    </p:input>
    
    <p:output port="result" primary="true">
        <p:documentation>
            The document on the 'result' port represents the normal flow. Elements that participate
            in a named flow are replaced with an empty css:_ element with a css:id attribute.
        </p:documentation>
        <p:pipe step="result" port="result"/>
    </p:output>
    
    <p:output port="flows" sequence="true">
        <p:documentation>
            All elements in the input document that participate in named flows are extracted,
            grouped according to flow, and inserted into documents on the 'flows' port, one document
            per flow. Elements within the same flow become siblings with a common css:_ parent
            element, which is the document node of that flow. Elements are ordered according to the
            original document order. The document node gets a css:flow attribute that identifies the
            flow. Other css:flow attributes are dropped. Elements get a css:anchor attribute that
            matches the css:id attribute of the css:_ replacement element in the normal flow, thus
            acting as a reference to the original position in the DOM. Style attributes are added in
            the output in such a way that for each element, its computed style at the output is
            equal to its computed style in the input.
        </p:documentation>
        <p:pipe step="result" port="secondary"/>
    </p:output>
    
    <p:xslt name="result">
        <p:input port="stylesheet">
            <p:document href="flow-into.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
