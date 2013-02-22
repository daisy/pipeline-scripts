<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:translate-mathml" name="translate-mathml"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-inline-prefixes="#all"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true" px:media-type="application/mathml+xml"/>
    <p:option name="temp-dir" required="true"/>
    <p:output port="result" sequence="false" primary="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-calabash/xproc/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    
    <!-- (!) FIXME: The following doesn't work inside cx:eval because of p:value-available() -->
    <px:fileset-create name="lbx_files" base="http://www.daisy.org/pipeline/modules/braille/liblouis-mathml/"/>
    <px:fileset-add-entry name="styles" href="wiskunde.cfg"/>
    <p:sink/>
    
    <px:fileset-add-entry name="semantics" href="wiskunde.sem">
        <p:input port="source">
            <p:pipe step="lbx_files" port="result"/>
        </p:input>
    </px:fileset-add-entry>
    <p:sink/>
    
    <px:mkdir>
        <p:with-option name="href" select="$temp-dir"/>
    </px:mkdir>
    
    <louis:translate-file>
        <p:input port="source">
            <p:pipe step="translate-mathml" port="source"/>
        </p:input>
        <p:input port="styles">
            <p:pipe step="styles" port="result"/>
        </p:input>
        <p:input port="semantics">
            <p:pipe step="semantics" port="result"/>
        </p:input>
        <p:with-param name="page-width" port="page-layout" select="200.0"/>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </louis:translate-file>
    
</p:declare-step>
