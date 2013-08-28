<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-inline-prefixes="#all"
    type="pxi:translation" name="translation" version="1.0">
    
    <p:input port="source" primary="true"/>
    <p:input port="translators" sequence="true"/>
    <p:output port="result" primary="true">
        <p:pipe step="translate" port="result"/>
    </p:output>
    
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="utils/eval-steps.xpl"/>
    
    <p:try name="translate">
        <p:group>
            <p:output port="result"/>
            <pxi:eval-steps>
                <p:input port="steps">
                    <p:pipe step="translation" port="translators"/>
                </p:input>
                <p:with-option name="temp-dir" select="$temp-dir"/>
            </pxi:eval-steps>
        </p:group>
        <p:catch name="translate-catch">
            <p:output port="result"/>
            <p:insert match="/message" position="last-child" name="translate-error">
                <p:input port="source">
                    <p:inline><message>Translation failed: </message></p:inline>
                </p:input>
                <p:input port="insertion">
                    <p:pipe step="translate-catch" port="error"/>
                </p:input>
            </p:insert>
            <p:error code="px:brl03">
                <p:input port="source">
                    <p:pipe step="translate-error" port="result"/>
                </p:input>
            </p:error>
        </p:catch>
    </p:try>
    
</p:declare-step>
