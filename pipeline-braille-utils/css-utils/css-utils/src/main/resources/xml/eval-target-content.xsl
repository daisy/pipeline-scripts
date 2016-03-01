<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="css:content[@target]">
        <xsl:variable name="target" select="@target"/>
        <css:box type="inline" css:anchor="{@target}">
            <xsl:sequence select="//*[@css:id=$target][1]/child::node()"/>
        </css:box>
    </xsl:template>
    
</xsl:stylesheet>
