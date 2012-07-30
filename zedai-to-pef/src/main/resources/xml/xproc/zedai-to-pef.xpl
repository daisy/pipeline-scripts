<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-inline-prefixes="px d"
    type="px:zedai-to-pef" name="zedai-to-pef" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">ZedAI to PEF</h1>
        <p px:role="desc">Transforms a ZedAI (DAISY 4 XML) document into an PEF.</p>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Bert Frees</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.sbs-online.ch/">SBS</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:bertfrees@gmail.com">bertfrees@gmail.com</a></dd>
        </dl>
    </p:documentation>

    <p:input port="source" primary="true" px:name="source" px:media-type="application/z3998-auth+xml">
        <p:documentation>
            <h2 px:role="name">source</h2>
            <p px:role="desc">Input ZedAI.</p>
        </p:documentation>
    </p:input>
    
    <p:option name="output-dir" required="true" px:output="result" px:sequence="false" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Path to output directory for the PEF.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="temp-dir" required="true" px:output="temp" px:sequence="false" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">temp-dir</h2>
            <p px:role="desc">Path to directory for storing temporary files.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="default-stylesheet" required="false" px:type="string" select="'bana.css'">
        <p:documentation>
            <h2 px:role="name">default-stylesheet</h2>
            <p px:role="desc">The default css stylesheet to apply when there aren't any provided with the input file.</p>
            <pre><code class="example">bana.css</code></pre>
        </p:documentation>
    </p:option>
    
    <p:import href="zedai-to-pef.styling.xpl"/>
    <p:import href="zedai-to-pef.translation.xpl"/>
    <p:import href="zedai-to-pef.formatting.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    
    <!-- ======= -->
    <!-- STYLING -->
    <!-- ======= -->
    
    <px:zedai-to-pef.styling name="styling">
        <p:input port="source">
            <p:pipe port="source" step="zedai-to-pef"/>
        </p:input>
        <p:with-option name="default-stylesheet" select="$default-stylesheet">
            <p:empty/>
        </p:with-option>
    </px:zedai-to-pef.styling>
    
    <!-- =========== -->
    <!-- TRANSLATION -->
    <!-- =========== -->
    
    <px:zedai-to-pef.translation name="translation">
        <p:input port="source">
            <p:pipe port="result" step="styling"/>
        </p:input>
    </px:zedai-to-pef.translation>
    
    <!-- ========== -->
    <!-- FORMATTING -->
    <!-- ========== -->
    
    <px:zedai-to-pef.formatting name="formatting">
        <p:with-option name="temp-dir" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </px:zedai-to-pef.formatting>
    
    <!-- Store -->
    
    <p:xslt name="output-dir-uri">
        <p:with-param name="href" select="concat($output-dir,'/')"/>
        <p:input port="source">
            <p:inline>
                <d:file/>
            </p:inline>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pf="http://www.daisy.org/ns/pipeline/functions" version="2.0">
                    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
                    <xsl:param name="href" required="yes"/>
                    <xsl:template match="/*">
                        <xsl:copy>
                            <xsl:attribute name="href" select="pf:file-uri-ify($href)"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:sink/>
    
    <p:group>
        <p:variable name="input-uri" select="base-uri(/)">
            <p:pipe step="zedai-to-pef" port="source"/>
        </p:variable>
        <p:variable name="output-dir-uri" select="/*/@href">
            <p:pipe step="output-dir-uri" port="result"/>
        </p:variable>
        
        <p:store indent="true" encoding="utf-8">
            <p:input port="source">
                <p:pipe step="formatting" port="result"/>
            </p:input>
            <p:with-option name="href" select="concat($output-dir-uri,replace($input-uri,'^.*/([^/]*)\.[^/\.]*$','$1'),'.pef.xml')">
                <p:empty/>
            </p:with-option>
        </p:store>
    </p:group>
    
</p:declare-step>
