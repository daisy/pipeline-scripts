<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-inline-prefixes="#all"
    type="px:zedai-to-pef.convert" name="zedai-to-pef.convert" version="1.0">
    
    <p:input port="source" primary="true" px:media-type="application/z3998-auth+xml"/>
    <p:output port="result" primary="true" px:media-type="application/x-pef+xml"/>

    <p:option name="temp-dir" required="true"/>
    <p:option name="stylesheet" required="false" select="''"/>
    <p:option name="preprocessor" required="false" select="''"/>
    <p:option name="translator" required="false" select="''"/>

    <p:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/xproc/xml-to-pef.convert.xpl"/>

    <!-- ================ -->
    <!-- EXTRACT METADATA -->
    <!-- ================ -->
    
    <p:xslt name="metadata">
        <p:input port="stylesheet">
            <p:document href="../xslt/zedai-to-metadata.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- ============== -->
    <!-- CONVERT TO PEF -->
    <!-- ============== -->
    
    <px:xml-to-pef.convert name="xml-to-pef">
        <p:input port="source">
            <p:pipe port="source" step="zedai-to-pef.convert"/>
        </p:input>
        <p:input port="metadata">
            <p:pipe port="result" step="metadata"/>
        </p:input>
        <p:with-option name="default-stylesheet" select="if ($stylesheet!='') then $stylesheet
            else 'http://www.daisy.org/pipeline/modules/braille/zedai-to-pef/css/bana.css'">
            <p:empty/>
        </p:with-option>
        <p:with-option name="preprocessor" select="$preprocessor">
            <p:empty/>
        </p:with-option>
        <p:with-option name="translator" select="$translator">
            <p:empty/>
        </p:with-option>
        <p:with-option name="temp-dir" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </px:xml-to-pef.convert>
    
</p:declare-step>
