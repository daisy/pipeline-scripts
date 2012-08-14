<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:pef="http://xmlcalabash.com/ns/extensions/pef"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-inline-prefixes="px d louis pef dc"
    type="px:zedai-to-pef.formatting" name="zedai-to-pef.formatting" version="1.0">

    <p:input port="source" primary="true" px:media-type="application/z3998-auth+xml"/>
    <p:input port="metadata"/>
    <p:output port="result" primary="true" px:media-type="application/x-pef+xml"/>
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-formatter/xproc/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-calabash/xproc/library.xpl"/>
    
    <!-- Create temporary directory -->
    
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
    
    <px:mkdir>
        <p:with-option name="href" select="/*/@href">
            <p:pipe port="result" step="temp-dir-uri"/>
        </p:with-option>
    </px:mkdir>
        
    <!-- Format with liblouisxml -->
    
    <louis:format>
        <p:input port="source">
            <p:pipe step="zedai-to-pef.formatting" port="source"/>
        </p:input>
        <p:with-option name="temp-dir" select="/*/@href">
            <p:pipe port="result" step="temp-dir-uri"/>
        </p:with-option>
    </louis:format>
    
    <!-- Convert to pef with brailleutils -->
    
    <pef:text2pef name="text-to-pef">
        <p:with-option name="temp-dir" select="/*/@href">
            <p:pipe port="result" step="temp-dir-uri"/>
        </p:with-option>
        <p:with-option name="title" select="string(/*/dc:title)">
            <p:pipe step="zedai-to-pef.formatting" port="metadata"/>
        </p:with-option>
        <p:with-option name="creator" select="string(/*/*[@property='dc:creator'])">
            <p:pipe step="zedai-to-pef.formatting" port="metadata"/>
        </p:with-option>
    </pef:text2pef>
    
</p:declare-step>
