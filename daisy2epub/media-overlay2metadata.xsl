<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:smil="http://www.w3.org/ns/SMIL" version="2.0">
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/*">
        <c:metadata>
            <!-- is there really any metadata that should be carried on from the SMILs at all? -->
        </c:metadata>
    </xsl:template>
    
</xsl:stylesheet>
