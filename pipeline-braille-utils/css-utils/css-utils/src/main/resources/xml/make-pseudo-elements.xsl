<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@css:before or @css:after]">
        <xsl:copy>
            <xsl:sequence select="@* except (@css:before|@css:after)"/>
            <xsl:apply-templates select="@css:before"/>
            <xsl:apply-templates/>
            <xsl:apply-templates select="@css:after"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@css:before">
        <css:before style="{string(.)}"/>
    </xsl:template>
    
    <xsl:template match="@css:after">
        <css:after style="{string(.)}"/>
    </xsl:template>
    
</xsl:stylesheet>
