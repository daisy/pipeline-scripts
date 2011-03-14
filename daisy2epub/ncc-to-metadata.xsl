<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:html="http://www.w3.org/1999/xhtml" version="2.0">
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/*">
        <opf:metadata>
            <xsl:for-each select="//html:head/*">
                <xsl:element name="opf:{local-name()}">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:element>
            </xsl:for-each>
        </opf:metadata>
    </xsl:template>
    
</xsl:stylesheet>
