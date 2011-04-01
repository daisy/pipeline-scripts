<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:opf="http://www.idpf.org/2007/opf" exclude-result-prefixes="#all" version="2.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <opf:spine>
            <xsl:for-each
                select="child::*[@media-type='application/xhtml+xml' and not(@href='navigation.xhtml')]">
                <itemref idref="{@id}"/>
            </xsl:for-each>
        </opf:spine>
    </xsl:template>

</xsl:stylesheet>
