<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="px"
    type="px:xml-to-pef.convert" name="xml-to-pef" version="1.0">

    <p:input port="source" primary="true"/>
    <p:input port="metadata"/>
    <p:output port="result" primary="true" px:media-type="application/x-pef+xml"/>

    <p:option name="default-stylesheet" required="false" select="''"/>
    <p:option name="preprocessor" required="false" select="''"/>
    <p:option name="translator" required="false" select="''"/>
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="xml-to-pef.styling.xpl"/>
    <p:import href="xml-to-pef.preprocessing.xpl"/>
    <p:import href="xml-to-pef.translation.xpl"/>
    <p:import href="xml-to-pef.formatting.xpl"/>
    
    <!-- ======= -->
    <!-- STYLING -->
    <!-- ======= -->
    
    <px:xml-to-pef.styling>
        <p:with-option name="default-stylesheet" select="$default-stylesheet">
            <p:empty/>
        </p:with-option>
    </px:xml-to-pef.styling>
    
    <!-- ============= -->
    <!-- PREPROCESSING -->
    <!-- ============= -->
    
    <px:xml-to-pef.preprocessing>
        <p:with-option name="preprocessor" select="$preprocessor">
            <p:empty/>
        </p:with-option>
    </px:xml-to-pef.preprocessing>
    
    <!-- =========== -->
    <!-- TRANSLATION -->
    <!-- =========== -->
    
    <px:xml-to-pef.translation>
        <p:with-option name="translator" select="$translator">
            <p:empty/>
        </p:with-option>
    </px:xml-to-pef.translation>
    
    <!-- ========== -->
    <!-- FORMATTING -->
    <!-- ========== -->
    
    <px:xml-to-pef.formatting>
        <p:input port="metadata">
            <p:pipe port="metadata" step="xml-to-pef"/>
        </p:input>
        <p:with-option name="temp-dir" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </px:xml-to-pef.formatting>
    
</p:declare-step>
