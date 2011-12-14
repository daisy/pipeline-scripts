<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-to-zedai" type="px:dtbook-to-zedai" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
    exclude-inline-prefixes="#all">

    <p:documentation>
        <xd:short>DTBook to ZedAI</xd:short>
        <xd:detail>Transforms DTBook XML into ZedAI XML.</xd:detail>
        <xd:homepage>http://code.google.com/p/daisy-pipeline/wiki/DTBookToZedAI</xd:homepage>
        <xd:author>
            <xd:name>Marisa DeMeglio</xd:name>
            <xd:mailto>marisa.demeglio@gmail.com</xd:mailto>
            <xd:organization>DAISY</xd:organization>
        </xd:author>
    </p:documentation>
    
    <p:input port="source" primary="true" sequence="true" px:media-type="application/x-dtbook+xml">
        <p:documentation>
            <xd:short>DTBook file(s)</xd:short>
            <xd:detail>One or more DTBook files to be transformed. In the case of multiple files, a merge will be performed.</xd:detail>
        </p:documentation>
    </p:input>
    
    <p:import href="dtbook-to-zedai.load.xpl"/>
    <p:import href="dtbook-to-zedai.convert.xpl"/>
    <p:import href="dtbook-to-zedai.store.xpl"/>

    <p:option name="opt-output-dir" required="true" px:dir="output" px:type="anyDirURI">
        <p:documentation>
            <xd:short>Output directory</xd:short>
            <xd:detail>The directory to store the generated files in.</xd:detail>
        </p:documentation>
    </p:option>
    <p:option name="opt-zedai-filename" required="false" px:dir="output" px:type="string" select="''">
        <p:documentation>
            <xd:short>ZedAI filename</xd:short>
            <xd:detail>Filename for the generated ZedAI file</xd:detail>
        </p:documentation>
    </p:option>
    <p:option name="opt-mods-filename" required="false" px:dir="output" px:type="string" select="''">
        <p:documentation>
            <xd:short>MODS filename</xd:short>
            <xd:detail>Filename for the generated MODS file</xd:detail>
        </p:documentation>
    </p:option>
    <p:option name="opt-css-filename" required="false" px:dir="output" px:type="string" select="''">
        <p:documentation>
            <xd:short>CSS filename</xd:short>
            <xd:detail>Filename for the generated CSS file</xd:detail>
        </p:documentation>
    </p:option>
    <p:option name="opt-lang" required="false" px:dir="output" px:type="string" select="''">
        <p:documentation>
            <xd:short>Language code</xd:short>
            <xd:detail>Language code of the input document.</xd:detail>
        </p:documentation>
    </p:option>
    
    <px:dtbook-to-zedai-load name="load"/>

    <px:dtbook-to-zedai-convert name="convert">
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="load"/>
        </p:input>
        <p:with-option name="opt-output-dir" select="$opt-output-dir"/>
        <p:with-option name="opt-zedai-filename" select="$opt-zedai-filename"/>
        <p:with-option name="opt-mods-filename" select="$opt-mods-filename"/>
        <p:with-option name="opt-css-filename" select="$opt-css-filename"/>
        <p:with-option name="opt-lang" select="$opt-lang"/>
    </px:dtbook-to-zedai-convert>

    <px:dtbook-to-zedai-store name="store">
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="convert"/>
        </p:input>
    </px:dtbook-to-zedai-store>

</p:declare-step>
