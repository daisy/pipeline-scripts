<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="2.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <c:manifest>
            <xsl:for-each select="//c:entry[not(@href=preceding-sibling::*/@href)]">
                <c:entry>
                    <xsl:apply-templates select="@*"/>
                </c:entry>
            </xsl:for-each>
        </c:manifest>
    </xsl:template>

</xsl:stylesheet>
