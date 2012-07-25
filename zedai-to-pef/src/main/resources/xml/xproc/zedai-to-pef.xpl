<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
    xmlns:css="http://xmlcalabash.com/ns/extensions/braille-css"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:brlutls="http://xmlcalabash.com/ns/extensions/brailleutils"
    type="px:zedai-to-pef" name="zedai-to-pef" version="1.0">

    <p:documentation xd:target="parent">
        <h1 px:role="name">ZedAI to PEF</h1>
        <p px:role="desc">Transforms a ZedAI (DAISY 4 XML) document into an PEF.</p>
    </p:documentation>

    <p:input port="source" primary="true" px:name="source" px:media-type="application/z3998-auth+xml">
        <p:documentation>
            <h2 px:role="name">source</h2>
            <p px:role="desc">Path to input ZedAI.</p>
        </p:documentation>
    </p:input>
    
    <p:option name="output-dir" required="true" px:output="result" px:sequence="false" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">output-dir</h2>
            <p>Path to output directory for the PEF.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="temp-dir" required="true" px:output="temp" px:sequence="false" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">temp-dir</h2>
            <p>Path to directory for storing temporary files.</p>
        </p:documentation>
    </p:option>
    
    <!-- <p:option name="liblouis-tables"/> -->
    <!-- <p:option name="pef-rows"/> -->
    <!-- <p:option name="pef-columns"/> -->
    
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/liblouis-formatter/xproc/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/brailleutils-calabash/xproc/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille-css-calabash/xproc/library.xpl"/>
    
    <p:variable name="input-uri" select="base-uri(/)"/>
    
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
    
    <p:xslt name="temp-dir-uri">
        <p:with-param name="href" select="concat($temp-dir,'/')"/>
        <p:input port="source">
            <p:inline>
                <d:file/>
            </p:inline>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                    version="2.0">
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
        
        <p:variable name="output-dir-uri" select="/*/@href">
            <p:pipe port="result" step="output-dir-uri"/>
        </p:variable>
        
        <p:variable name="output-uri" select="concat($output-dir-uri,replace($input-uri,'^.*/([^/]*)\.[^/\.]*$','$1'),'.pef.xml')"/>
        
        <p:variable name="temp-dir-uri" select="/*/@href">
            <p:pipe port="result" step="temp-dir-uri"/>
        </p:variable>
        
        <!-- Create temporary directory -->
        
        <px:mkdir>
            <p:with-option name="href" select="$temp-dir-uri">
                <p:empty/>
            </p:with-option>
        </px:mkdir>
        
        <!-- add styling -->
        
        <css:apply-stylesheet>
            <p:input port="source">
                <p:pipe port="source" step="zedai-to-pef"/>
            </p:input>
            <!-- FIXME this is a very ugly solution -->
            <p:with-option name="stylesheet"
                select="concat(substring(base-uri(/), 0, string-length(base-uri(/))-25), 'css/test.css')">
                <p:document href="zedai-to-pef.xpl"/>
            </p:with-option>
        </css:apply-stylesheet>
        
        <!-- flatten some elements -->
        
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/flatten.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        
        <!-- translate text nodes with liblouis -->
        
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/translate.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        
        <!-- format with liblouisxml -->
        
        <louis:format>
            <p:with-option name="temp-dir" select="$temp-dir-uri"/>
        </louis:format>
        
        <!-- convert to pef with brailleutils -->
        
        <brlutls:text2pef name="text-to-pef">
            <p:with-option name="temp-dir" select="$temp-dir-uri"/>
        </brlutls:text2pef>
        
        <!-- store -->
        
        <p:store indent="true" encoding="utf-8">
            <p:with-option name="href" select="$output-uri"/>
        </p:store>
        
    </p:group>
    
</p:declare-step>
