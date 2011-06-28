<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:epub="http://www.idpf.org/2007/ops"
    version="2.0">
    
    <xsl:template match="body|article|aside|nav|section">
        <xsl:copy>
            <xsl:attribute name="id" select="generate-id()"/>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="h1|h2|h3|h4|h5|h6|hgroup">
        <xsl:copy>
            <xsl:attribute name="id" select="generate-id()"/>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="*[@epub:type='pagebreak']">
        <!--TODO FIXME: epub:type can have several values-->
        <xsl:copy>
            <xsl:attribute name="id" select="generate-id()"/>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>