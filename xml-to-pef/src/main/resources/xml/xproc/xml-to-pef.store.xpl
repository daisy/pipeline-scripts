<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    exclude-inline-prefixes="#all"
    type="px:xml-to-pef.store" name="xml-to-pef.store" version="1.0">

    <p:input port="source" primary="true" px:media-type="application/x-pef+xml"/>

    <p:option name="output-dir" required="true"/>
    <p:option name="name" required="true"/>

    <p:option name="preview" required="false" select="'false'"/>
    <p:option name="brf" required="false" select="'false'"/>
    <p:option name="brf-table" required="false" select="'org.daisy.braille.table.DefaultTableProvider.TableType.EN_US'"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-to-html/xproc/pef-to-html.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-calabash/xproc/library.xpl"/>
    
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
                            <xsl:attribute name="href" select="pf:normalize-uri($href)"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:sink/>
    
    <p:group>
        <p:variable name="output-dir-uri" select="/*/@href">
            <p:pipe step="output-dir-uri" port="result"/>
        </p:variable>

        <!-- ============ -->
        <!-- STORE AS PEF -->
        <!-- ============ -->

        <p:store indent="true" encoding="utf-8" omit-xml-declaration="false">
            <p:input port="source">
                <p:pipe step="xml-to-pef.store" port="source"/>
            </p:input>
            <p:with-option name="href" select="concat($output-dir-uri, $name, '.pef.xml')">
                <p:empty/>
            </p:with-option>
        </p:store>

        <!-- ============ -->
        <!-- STORE AS BRF -->
        <!-- ============ -->
        
        <p:identity>
            <p:input port="source">
                <p:pipe step="xml-to-pef.store" port="source"/>
            </p:input>
        </p:identity>
        <p:choose>
            <p:when test="$brf='true'">
                <pef:pef2text breaks="DEFAULT" pad="BOTH">
                    <p:with-option name="href" select="concat($output-dir-uri, $name, '.brf')">
                        <p:empty/>
                    </p:with-option>
                    <p:with-option name="table" select="$brf-table"/>
                </pef:pef2text>
            </p:when>
            <p:otherwise>
                <p:sink/>
            </p:otherwise>
        </p:choose>
        
        <!-- ==================== -->
        <!-- STORE AS PEF PREVIEW -->
        <!-- ==================== -->
        
        <p:identity>
            <p:input port="source">
                <p:pipe step="xml-to-pef.store" port="source"/>
            </p:input>
        </p:identity>
        <p:choose>
            <p:when test="$preview='true'">
                <px:pef-to-html.convert>
                    <p:with-option name="table" select="$brf-table"/>
                </px:pef-to-html.convert>
                <p:store indent="true" encoding="utf-8" method="xhtml" omit-xml-declaration="false"
                    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
                    <p:with-option name="href" select="concat($output-dir-uri, $name, '.pef.html')">
                        <p:empty/>
                    </p:with-option>
                </p:store>
            </p:when>
            <p:otherwise>
                <p:sink/>
            </p:otherwise>
        </p:choose>
    </p:group>
    
</p:declare-step>
