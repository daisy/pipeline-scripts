<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    exclude-inline-prefixes="px cx"
    type="px:zedai-to-pef.preprocessing" name="zedai-to-pef.preprocessing" version="1.0">

    <p:input port="source" primary="true" px:media-type="application/z3998-auth+xml"/>
    <p:output port="result" primary="true" px:media-type="application/x-pef+xml"/>
    <p:option name="preprocessor" required="false" select="''"/>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <!-- Number lists -->
    
    <p:xslt name="number-lists">
        <p:input port="stylesheet">
            <p:document href="http://www.daisy.org/pipeline/modules/braille/utilities/xslt/number-lists.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- Custom preprocessor -->
    
    <p:choose>
        <p:when test="not($preprocessor='')">
            
            <p:load name="preprocessor">
                <p:with-option name="href" select="$preprocessor">
                    <p:empty/>
                </p:with-option>
            </p:load>
            
            <cx:eval>
                <p:input port="pipeline">
                    <p:pipe step="preprocessor" port="result"/>
                </p:input>
                <p:input port="source">
                    <p:pipe step="number-lists" port="result"/>
                </p:input>
                <p:input port="options">
                    <p:empty/>
                </p:input>
            </cx:eval>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
