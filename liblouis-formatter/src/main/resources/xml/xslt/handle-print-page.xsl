<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-result-prefixes="xs css louis"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[css:string-set[@name='print-page']]">
        <xsl:element name="louis:print-page">
            <xsl:sequence select="string(css:string-set)"/>
        </xsl:element>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="css:string-set"/>
    
</xsl:stylesheet>
