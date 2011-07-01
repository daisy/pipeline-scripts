<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:html="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="html:ol">
        <xsl:variable name="ol" select="."/>
        <xsl:for-each-group select="*" group-adjacent="count(child::html:a) &gt; 0">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <ol xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:apply-templates select="$ol/@*[not(local-name()='id')]"/>
                        <xsl:apply-templates select="current-group()"/>
                    </ol>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="current-group()">
                        <xsl:apply-templates select="html:ol"/>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>
