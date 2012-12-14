<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-inline-prefixes="#all"
    type="px:xml-to-pef.convert" name="xml-to-pef" version="1.0">

    <p:input port="source" primary="true"/>
    <p:input port="metadata"/>
    <p:output port="result" primary="true" px:media-type="application/x-pef+xml"/>

    <p:option name="default-stylesheet" required="false" select="''"/>
    <p:option name="preprocessor" required="false" select="''"/>
    <p:option name="translator" required="false" select="''"/>
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="styling.xpl"/>
    <p:import href="preprocessing.xpl"/>
    <p:import href="translation.xpl"/>
    <p:import href="formatting.xpl"/>
    
    <!-- ======= -->
    <!-- STYLING -->
    <!-- ======= -->
    
    <pxi:styling name="styling">
        <p:with-option name="default-stylesheet" select="$default-stylesheet"/>
    </pxi:styling>
    
    <!-- ============= -->
    <!-- PREPROCESSING -->
    <!-- ============= -->
    
    <pxi:preprocessing>
        <p:with-option name="preprocessor" select="$preprocessor"/>
    </pxi:preprocessing>
    
    <!-- =========== -->
    <!-- TRANSLATION -->
    <!-- =========== -->
    
    <pxi:translation>
        <p:with-option name="translator" select="$translator"/>
        <p:with-option name="hyphenator" select="'none'"/>
    </pxi:translation>
    
    <!-- ========== -->
    <!-- FORMATTING -->
    <!-- ========== -->
    
    <pxi:formatting>
        <p:input port="metadata">
            <p:pipe step="xml-to-pef" port="metadata"/>
        </p:input>
        <p:input port="pages">
            <p:pipe step="styling" port="pages"/>
        </p:input>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </pxi:formatting>
    
</p:declare-step>
