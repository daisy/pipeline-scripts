<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:opf="http://www.idpf.org/2007/opf" xmlns:c="http://www.w3.org/ns/xproc-step" version="2.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <opf:manifest>
            <xsl:for-each select="child::*">
                <item>
                    <xsl:apply-templates select="@id | @href | @media-type"/>
                    <xsl:variable name="original-href" select="@original-href"/>
                    <xsl:variable name="media-overlay"
                        select="//c:entry[@reverse-media-overlay=$original-href]/@id"/>
                    <xsl:if test="$media-overlay">
                        <xsl:attribute name="media-overlay" select="$media-overlay"/>
                    </xsl:if>
                </item>
            </xsl:for-each>
        </opf:manifest>
    </xsl:template>

</xsl:stylesheet>
