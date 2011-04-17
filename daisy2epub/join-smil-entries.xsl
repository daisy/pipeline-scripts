<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all"
    version="2.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="/c:manifest/c:entry[not(@reverse-media-overlay) or not(@reverse-media-overlay=preceding-sibling::c:entry/@reverse-media-overlay)]">
                <xsl:variable name="reverse-media-overlay" select="@reverse-media-overlay"/>
                <xsl:copy>
                    <xsl:apply-templates select="@*[not(name()='original-href')]"/>
                    <xsl:if test="not(following-sibling::c:entry[@reverse-media-overlay and @reverse-media-overlay=$reverse-media-overlay])">
                        <xsl:apply-templates select="@original-href"/>
                    </xsl:if>
                    <xsl:copy-of select="child::*"/>
                    <xsl:for-each select="following-sibling::c:entry[@reverse-media-overlay and @reverse-media-overlay=$reverse-media-overlay]">
                        <xsl:copy-of select="child::*"/>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
