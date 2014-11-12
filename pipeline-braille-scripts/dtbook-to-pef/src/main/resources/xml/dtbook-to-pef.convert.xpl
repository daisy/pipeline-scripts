<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:dtbook-to-pef.convert" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-inline-prefixes="#all"
                name="main">
    
    <p:input port="source" px:media-type="application/x-dtbook+xml"/>
    <p:output port="result" px:media-type="application/x-pef+xml"/>
    
    <p:option name="default-stylesheet" required="false" select="''"/>
    <p:option name="transform" required="false" select="''"/>
    
    <!-- Empty temporary directory dedicated to this conversion -->
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-to-zedai/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/zedai-to-pef/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    
    <!-- =============== -->
    <!-- DTBOOK TO ZEDAI -->
    <!-- =============== -->
    
    <px:dtbook-load name="load"/>
    <px:dtbook-to-zedai-convert name="zedai">
        <p:input port="in-memory.in">
            <p:pipe step="load" port="in-memory.out"/>
        </p:input>
        <p:with-option name="opt-output-dir" select="$temp-dir"/>
    </px:dtbook-to-zedai-convert>
    <p:sink/>
    <px:fileset-store>
        <p:input port="fileset.in">
            <p:pipe step="zedai" port="fileset.out"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe step="zedai" port="in-memory.out"/>
        </p:input>
    </px:fileset-store>
    
    <!-- ============ -->
    <!-- ZEDAI TO PEF -->
    <!-- ============ -->
    
    <p:split-sequence>
        <p:input port="source">
            <p:pipe step="zedai" port="in-memory.out"/>
        </p:input>
        <p:with-option name="test"
                       select="concat('/*/@xml:base=&quot;',
                                      //d:file[@media-type='application/z3998-auth+xml'][1]/resolve-uri(@href, base-uri(.)),
                                      '&quot;')">
            <p:pipe step="zedai" port="fileset.out"/>
        </p:with-option>
    </p:split-sequence>
    <px:zedai-to-pef.convert>
        <p:with-option name="default-stylesheet" select="$default-stylesheet"/>
        <p:with-option name="transform" select="$transform"/>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </px:zedai-to-pef.convert>
    
</p:declare-step>
