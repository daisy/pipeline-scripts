<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-inline-prefixes="#all"
    type="px:zedai-to-pef.convert" name="convert" version="1.0">
    
    <p:input port="source" primary="true" px:media-type="application/z3998-auth+xml"/>
    <p:input port="translators" sequence="true"/>
    
    <p:output port="result" primary="true" px:media-type="application/x-pef+xml"/>

    <p:option name="temp-dir" required="true"/>
    <p:option name="default-stylesheet" required="false" select="''"/>

    <p:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/xproc/xml-to-pef.convert.xpl"/>

    <!-- ================ -->
    <!-- EXTRACT METADATA -->
    <!-- ================ -->
    
    <p:xslt name="metadata">
        <p:input port="stylesheet">
            <p:document href="http://www.daisy.org/pipeline/modules/metadata-utils/zedai-to-metadata.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <p:sink/>
    
    <!-- ============== -->
    <!-- CONVERT TO PEF -->
    <!-- ============== -->
    
    <px:xml-to-pef.convert name="xml-to-pef">
        <p:input port="source">
            <p:pipe step="convert" port="source"/>
        </p:input>
        <p:input port="translators">
            <p:pipe step="convert" port="translators"/>
        </p:input>
        <p:input port="metadata">
            <p:pipe step="metadata" port="result"/>
        </p:input>
        <p:with-option name="default-stylesheet" select="$default-stylesheet"/>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </px:xml-to-pef.convert>
    
</p:declare-step>
