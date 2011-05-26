<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:z="http://www.daisy.org/ns/z3986/authoring/"
    exclude-result-prefixes="xs z" version="2.0">
    
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:template match="//z:annotation[not(@ref)]">
        <xsl:copy>
            <xsl:attribute name="ref" select="ancestor::z:section/@xml:id"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>
    
    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
    
