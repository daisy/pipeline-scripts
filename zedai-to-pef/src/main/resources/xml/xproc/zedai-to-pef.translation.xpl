<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-inline-prefixes="px css"
    type="px:zedai-to-pef.translation" name="zedai-to-pef.translation" version="1.0">

    <p:input port="source" primary="true" px:media-type="application/z3998-auth+xml"/>
    <p:output port="result" primary="true" px:media-type="application/z3998-auth+xml"/>
    <p:option name="translator-xslt" required="true"/>

    <!-- Identify blocks -->
    
    <p:xslt name="blocks">
        <p:input port="stylesheet">
            <p:document href="../xslt/identify-blocks.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <!-- Load translator from URL -->
    
    <p:load name="stylesheet">
        <p:with-option name="href" select="$translator-xslt">
            <p:empty/>
        </p:with-option>
    </p:load>

    <!-- Translate each block -->
    
    <p:viewport match="css:block">
        <p:viewport-source>
            <p:pipe step="blocks" port="result"/>
        </p:viewport-source>
        
        <p:xslt>
            <p:input port="stylesheet">
                <p:pipe step="stylesheet" port="result"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:viewport>
    
    <p:unwrap match="css:block"/>
    
</p:declare-step>
