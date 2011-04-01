<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:param name="position" required="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@id]">
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name()='id')]"/>
            <xsl:attribute name="id" select="concat('mo',$position,'_',@id)"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
