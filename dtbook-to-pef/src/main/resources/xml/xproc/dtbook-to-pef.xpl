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
    
    <p:option name="result" required="true" px:sequence="false" px:type="anyFileURI">
        <p:documentation>
            <h2 px:role="name">result</h2>
            <p px:role="desc">File where your PEF will be stored.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="preview" required="false" px:sequence="false" px:type="anyFileURI" select="''">
        <p:documentation>
            <h2 px:role="name">preview</h2>
            <p px:role="desc">File where an HTML preview of the PEF will be stored. If left blank, no preview is generated.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="brf" required="false" px:sequence="false" px:type="anyFileURI" select="''">
        <p:documentation>
            <h2 px:role="name">brf</h2>
            <p px:role="desc">File where a BRF version of the PEF will be stored. If left blank, no BRF is generated.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="temp-dir" required="true" px:output="temp" px:sequence="false" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">temp-dir</h2>
            <p px:role="desc">Directory for storing temporary files.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="stylesheet" required="false" px:type="string" select="''">
        <p:documentation>
            <h2 px:role="name">stylesheet</h2>
            <p px:role="desc">The default css stylesheet to apply.</p>
            <pre><code class="example">http://www.daisy.org/pipeline/modules/braille/zedai-to-pef/css/bana.css</code></pre>
        </p:documentation>
    </p:option>
    
    <p:option name="translator" required="false" px:type="string" select="''">
        <p:documentation>
            <h2 px:role="name">translator</h2>
            <p px:role="desc">The translator(s) (XSLT/XProc step or liblouis/libhyphen table) to be used. Must be a comma separated list of identifiers (URLs). Defaults to a simple generic liblouis-based translator.</p>
            <pre><code class="example">http://www.sbs.ch/pipeline/modules/braille/sbs-translator/xslt/translator.xsl</code></pre>
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
        <p:with-option name="stylesheet" select="$stylesheet"/>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </px:dtbook-to-pef.convert>
    
    <!-- ========= -->
    <!-- STORE PEF -->
    <!-- ========= -->
    
    <px:xml-to-pef.store>
        <p:with-option name="result" select="$result"/>
        <p:with-option name="preview" select="$preview"/>
        <p:with-option name="brf" select="$brf"/>
    </px:xml-to-pef.store>
    
</p:declare-step>
