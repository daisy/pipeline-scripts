<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    xmlns:brlutls="http://xmlcalabash.com/ns/extensions/brailleutils"
    type="px:zedai-to-pef" name="zedai-to-pef" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>zedai-to-pef</xd:short>
        <xd:detail>Transforms a ZedAI (DAISY 4 XML) document into an PEF.</xd:detail>
    </p:documentation>
    
    <p:input port="source" primary="true" px:name="source" px:media-type="application/z3998-auth+xml">
        <p:documentation>
            <xd:short>source</xd:short>
            <xd:detail>Path to input ZedAI.</xd:detail>
        </p:documentation>
    </p:input>
    
    <p:option name="output-dir" required="true" px:output="result" px:sequence="false" px:type="anyDirURI">
        <p:documentation>
            <xd:short>output-dir</xd:short>
            <xd:detail>Path to output directory for the PEF.</xd:detail>
        </p:documentation>
    </p:option>
    
    <p:option name="temp-dir" required="true" px:output="temp" px:sequence="false" px:type="anyDirURI"/>
    
    <!-- <p:option name="liblouis-tables"/> -->
    <!-- <p:option name="pef-rows"/> -->
    <!-- <p:option name="pef-columns"/> -->
    
    <p:import href="http://www.daisy.org/pipeline/modules/liblouisxml-calabash/xproc/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/brailleutils-calabash/xproc/library.xpl"/>
    
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
        
        <p:variable name="output-dir-uri" select="/*/@href">
            <p:pipe port="result" step="output-dir-uri"/>
        </p:variable>
        
        <p:variable name="output-uri" select="concat($output-dir-uri,replace($input-uri,'^.*/([^/]*)\.[^/\.]*$','$1'),'.pef.xml')"/>
        
        <p:variable name="temp-dir-uri" select="/*/@href">
            <p:pipe port="result" step="temp-dir-uri"/>
        </p:variable>
        
        <!-- flatten some elements -->
        
        <p:xslt>
            <p:input port="source">
                <p:pipe port="source" step="zedai-to-pef"/>
            </p:input>
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
        
        <!-- add styling -->
        
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/add-styling.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        
        <!-- format with liblouisxml -->
        
        <lblxml:format>
            <p:with-option name="temp-dir" select="$temp-dir-uri"/>
        </lblxml:format>
        
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
