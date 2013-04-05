<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-inline-prefixes="#all"
    type="px:dtbook-to-pef" name="dtbook-to-pef" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DTBook to PEF</h1>
        <p px:role="desc">Transforms a DTBook (DAISY 3 XML) document into a PEF.</p>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Bert Frees</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.sbs-online.ch/">SBS</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:bertfrees@gmail.com">bertfrees@gmail.com</a></dd>
        </dl>
    </p:documentation>

    <p:input port="source" primary="true" px:name="source" px:media-type="application/x-dtbook+xml">
        <p:documentation>
            <h2 px:role="name">source</h2>
            <p px:role="desc">Input DTBook.</p>
        </p:documentation>
    </p:input>
    
    <p:option name="include-preview" required="false" px:type="boolean" select="''">
        <p:documentation>
            <h2 px:role="name">include-preview</h2>
            <p px:role="desc">Whether or not to include a preview of the PEF in HTML (true or false).</p>
        </p:documentation>
    </p:option>
    
    <p:option name="include-brf" required="false" px:type="boolean" select="''">
        <p:documentation>
            <h2 px:role="name">include-brf</h2>
            <p px:role="desc">Whether or not to include an ASCII version of the PEF (true or false).</p>
        </p:documentation>
    </p:option>
    
    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Directory for storing result files.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="temp-dir" required="false" px:output="temp" px:type="anyDirURI" select="''">
        <p:documentation>
            <h2 px:role="name">temp-dir</h2>
            <p px:role="desc">Directory for storing temporary files.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="translator" required="false" px:type="string" select="''">
        <p:documentation>
            <h2 px:role="name">translator</h2>
            <p px:role="desc">The translator(s) (XSLT/XProc step or liblouis/libhyphen table) to be used. Must be a comma separated list of identifiers (URLs). Defaults to a simple liblouis-based translator.</p>
            <pre><code class="example">http://www.daisy.org/pipeline/modules/braille/utilities/xproc/generic-translate.xpl</code></pre>
        </p:documentation>
    </p:option>
    
    <p:option name="default-stylesheet" required="false" px:type="string" select="''">
        <p:documentation>
            <h2 px:role="name">default-stylesheet</h2>
            <p px:role="desc">The default CSS stylesheet to apply.</p>
            <pre><code class="example">http://www.daisy.org/pipeline/modules/braille/zedai-to-pef/css/bana.css</code></pre>
        </p:documentation>
    </p:option>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/dtbook-to-pef/xproc/dtbook-to-pef.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/xproc/xml-to-pef.load-translator.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/xproc/xml-to-pef.store.xpl"/>
    
    <!-- =============== -->
    <!-- LOAD COMPONENTS -->
    <!-- =============== -->
    
    <px:xml-to-pef.load-translator name="translator">
        <p:with-option name="translator" select="if ($translator!='') then $translator else
            'http://www.daisy.org/pipeline/modules/braille/utilities/xslt/generic-liblouis-translate.xsl'"/>
    </px:xml-to-pef.load-translator>
    <p:sink/>
    
    <!-- ============= -->
    <!-- DTBOOK TO PEF -->
    <!-- ============= -->
    
    <px:dtbook-to-pef.convert>
        <p:input port="source">
            <p:pipe step="dtbook-to-pef" port="source"/>
        </p:input>
        <p:input port="translators">
            <p:pipe step="translator" port="result"/>
        </p:input>
        <p:with-option name="default-stylesheet" select="$default-stylesheet"/>
        <p:with-option name="temp-dir" select="if ($temp-dir!='') then $temp-dir else $output-dir"/>
    </px:dtbook-to-pef.convert>
    
    <!-- ========= -->
    <!-- STORE PEF -->
    <!-- ========= -->
    
    <px:xml-to-pef.store>
        <p:with-option name="output-dir" select="$output-dir"/>
        <p:with-option name="name" select="replace(p:base-uri(/),'^.*/([^/]*)\.[^/\.]*$','$1')">
            <p:pipe step="dtbook-to-pef" port="source"/>
        </p:with-option>
        <p:with-option name="include-preview" select="$include-preview"/>
        <p:with-option name="include-brf" select="$include-brf"/>
    </px:xml-to-pef.store>
    
</p:declare-step>
