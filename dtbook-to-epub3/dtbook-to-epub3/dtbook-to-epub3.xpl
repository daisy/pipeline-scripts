<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-to-epub3" type="px:dtbook-to-epub3" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:xd="http://www.daisy.org/ns/pipeline/doc" xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    xmlns:z="http://www.daisy.org/ns/z3986/authoring/" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-inline-prefixes="cx p c cxo px xd pxi z tmp">

    <p:input port="source" primary="true" sequence="true" px:media-type="application/x-dtbook+xml">
        <p:documentation>
            <xd:short>DTBook file(s)</xd:short>
            <xd:detail>One or more DTBook files to be transformed. In the case of multiple files, a merge will be performed.</xd:detail>
        </p:documentation>
    </p:input>

    <p:option name="language" required="false" px:dir="output" px:type="string" select="''">
        <p:documentation>
            <xd:short>Language code</xd:short>
            <xd:detail>Language code of the input document.</xd:detail>
        </p:documentation>
    </p:option>
    
    <p:option name="output-dir" required="true" px:dir="output" px:type="string">
        <p:documentation>
            <xd:short>Output directory</xd:short>
            <xd:detail>file: URI to the output directory where both temp-files and the resulting EPUB3 publication is stored.</xd:detail>
        </p:documentation>
    </p:option>
    
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-to-zedai/dtbook-to-zedai.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/zedai-to-epub3/xproc/zedai-to-epub3.xpl"/>
    
    <p:variable name="resolved-output-dir" select="p:resolve-uri(if (ends-with($output-dir,'/')) then $output-dir else concat($output-dir,'/'))"/>
    <!--<p:variable name="encoded-title" select="encode-for-uri(replace(//dtbook:meta[@name='dc:Title']/@content,'[/\\?%*:|&quot;&lt;&gt;]',''))"/> TODO: zedai-to-epub3 does not handle complex filenames as input yet. -->
    <p:variable name="encoded-title" select="'book'"/>
    
    <px:dtbook-to-zedai-load>
        <p:input port="source">
            <p:pipe port="source" step="dtbook-to-epub3"/>
        </p:input>
    </px:dtbook-to-zedai-load>
    
    <px:dtbook-to-zedai-convert>
        <p:with-option name="opt-output-dir" select="concat($resolved-output-dir,'zedai/')"/>
        <p:with-option name="opt-zedai-filename" select="concat($encoded-title,'.xml')"/>
    </px:dtbook-to-zedai-convert>
    
    <px:zedai-to-epub3-convert/>
    
    <px:zedai-to-epub3-store>
        <p:with-option name="output-dir" select="concat($resolved-output-dir,'epub/')"/>
    </px:zedai-to-epub3-store>
    
    <!-- The simple way:
    
    <px:dtbook-to-zedai name="dtbook-to-zedai">
        <p:input port="source">
            <p:pipe port="source" step="dtbook-to-epub3"/>
        </p:input>
        <p:with-option name="opt-output-dir" select="concat($resolved-output-dir,'zedai/')"/>
        <p:with-option name="opt-zedai-filename" select="concat($encoded-title,'.xml')"/>
    </px:dtbook-to-zedai>

    <p:load cx:depends-on="dtbook-to-zedai">
        <p:with-option name="href" select="concat($resolved-output-dir,'zedai/',concat($encoded-title,'.xml'))"/>
    </p:load>
    <px:zedai-to-epub3>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:with-option name="output-dir" select="concat($resolved-output-dir,'epub/')"/>
    </px:zedai-to-epub3>
    
    -->
    
</p:declare-step>
