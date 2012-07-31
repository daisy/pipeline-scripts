<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-inline-prefixes="px css"
    type="px:zedai-to-pef.translation" name="zedai-to-pef.translation" version="1.0">

    <p:input port="source" primary="true" px:media-type="application/z3998-auth+xml"/>
    <p:output port="result" primary="true" px:media-type="application/z3998-auth+xml"/>

    <!-- Identify blocks -->
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/identify-blocks.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- Translate each block -->
    
    <p:viewport match="css:block">
        
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/simple-translate.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        
    </p:viewport>
    
    <p:unwrap match="css:block"/>
    
</p:declare-step>
