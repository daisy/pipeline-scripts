<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="px"
    type="px:zedai-to-pef.translation" name="zedai-to-pef.translation" version="1.0">

    <p:input port="source" primary="true" px:media-type="application/z3998-auth+xml"/>
    <p:output port="result" primary="true" px:media-type="application/z3998-auth+xml"/>
    
    <!-- flatten some elements -->
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/flatten.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- translate text nodes with liblouis -->
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/translate.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
