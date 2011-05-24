<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    xmlns:rend="http://www.daisy.org/ns/z3986/authoring/features/rend/"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    xmlns="http://www.daisy.org/ns/z3986/authoring/"
    exclude-result-prefixes="xs rend its xlink tmp">
    
    <xsl:output indent="yes" method="xml"/>
    
    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- discard these attributes -->
    <xsl:template match="@tmp:height"/>
    <xsl:template match="@tmp:width"/>
    <xsl:template match="@tmp:border"/>
    <xsl:template match="@tmp:cellspacing"/>
    <xsl:template match="@tmp:cellpadding"/>
    <xsl:template match="@tmp:align"/>
    <xsl:template match="@tmp:valign"/>
    
</xsl:stylesheet>
