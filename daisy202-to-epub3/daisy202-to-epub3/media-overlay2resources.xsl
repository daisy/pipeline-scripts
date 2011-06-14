<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:smil="http://www.w3.org/ns/SMIL" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:template match="/*">
        <c:manifest>
            <xsl:attribute name="xml:base" select="replace(@xml:base,'^(.+/)[^/]*','$1')"/>
            <xsl:for-each select="distinct-values(//smil:audio/@src)">
                <c:entry href="{.}"/>
            </xsl:for-each>
        </c:manifest>
    </xsl:template>

</xsl:stylesheet>
