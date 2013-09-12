<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-inline-prefixes="#all"
    type="px:dtbook-to-pef.convert" name="dtbook-to-pef.convert" version="1.0">
    
    <p:input port="source" primary="true" px:media-type="application/x-dtbook+xml"/>
    <p:input port="translators" sequence="true"/>
    
    <p:output port="result" primary="true" px:media-type="application/x-pef+xml"/>
    
    <p:option name="temp-dir" required="true"/>
    <p:option name="default-stylesheet" required="false" select="''"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/dtbook-load.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-to-zedai/dtbook-to-zedai.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-to-zedai/dtbook-to-zedai.store.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/zedai-to-pef/xproc/zedai-to-pef.convert.xpl"/>

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
    <px:dtbook-to-zedai-store>
        <p:input port="fileset.in">
            <p:pipe step="zedai" port="fileset.out"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe step="zedai" port="in-memory.out"/>
        </p:input>
    </px:dtbook-to-zedai-store>
    
    <!-- ============ -->
    <!-- ZEDAI TO PEF -->
    <!-- ============ -->
    
    <p:split-sequence>
        <p:input port="source">
            <p:pipe step="zedai" port="in-memory.out"/>
        </p:input>
        <p:with-option name="test"
                       select="concat('/*/@xml:base=&quot;',
                                      //d:file[@media-type='application/z3998-auth+xml'][1]/resolve-uri(@href, base-uri()),
                                      '&quot;')">
            <p:pipe step="zedai" port="fileset.out"/>
        </p:with-option>
    </p:split-sequence>
    <px:zedai-to-pef.convert>
        <p:input port="translators">
            <p:pipe step="dtbook-to-pef.convert" port="translators"/>
        </p:input>
        <p:with-option name="default-stylesheet" select="$default-stylesheet"/>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </px:zedai-to-pef.convert>
    
</p:declare-step>
