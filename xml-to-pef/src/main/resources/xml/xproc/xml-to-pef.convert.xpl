<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-inline-prefixes="#all"
    type="px:xml-to-pef.convert" name="convert" version="1.0">
    
    <p:input port="source" primary="true"/>
    <p:input port="translators" sequence="true"/>
    <p:input port="metadata"/>
    
    <p:output port="result" primary="true" px:media-type="application/x-pef+xml"/>
    
    <p:option name="default-stylesheet" required="false" select="''"/>
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="styling.xpl"/>
    <p:import href="translation.xpl"/>
    <p:import href="formatting.xpl"/>
    <p:import href="add-metadata.xpl"/>
    <p:import href="utils/tempdir.xpl"/>
    
    <!-- ======== -->
    <!-- TEMP DIR -->
    <!-- ======== -->
    
    <pxi:tempdir name="temp-dir">
        <p:with-option name="href" select="$temp-dir"/>
    </pxi:tempdir>
    
    <!-- ======= -->
    <!-- STYLING -->
    <!-- ======= -->
    
    <pxi:styling name="styling">
        <p:input port="source">
            <p:pipe step="convert" port="source"/>
        </p:input>
        <p:with-option name="default-stylesheet" select="$default-stylesheet"/>
    </pxi:styling>
    
    <!-- =========== -->
    <!-- TRANSLATION -->
    <!-- =========== -->
    
    <pxi:translation>
        <p:input port="translators">
            <p:pipe step="convert" port="translators"/>
        </p:input>
        <p:with-option name="temp-dir" select="string(/c:result)">
            <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
    </pxi:translation>
    
    <!-- ========== -->
    <!-- FORMATTING -->
    <!-- ========== -->
    
    <pxi:formatting>
        <p:with-option name="temp-dir" select="string(/c:result)">
            <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
    </pxi:formatting>
    
    <!-- ======== -->
    <!-- METADATA -->
    <!-- =========-->
    
    <pxi:add-metadata>
        <p:input port="metadata">
            <p:pipe step="convert" port="metadata"/>
        </p:input>
    </pxi:add-metadata>
    
</p:declare-step>
