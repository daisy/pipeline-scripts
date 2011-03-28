<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:h="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" version="2.0"
    exclude-result-prefixes="#all">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="h:html">
        <xsl:apply-templates select="child::h:body"/>
    </xsl:template>

    <xsl:template match="h:body">
        <c:manifest>
            <xsl:for-each select="distinct-values(*/h:a/tokenize(@href,'#')[1])">
                <xsl:if test="matches(.,'smil$')">
                    <c:entry href="{.}" media-type="application/smil+xml"/>
                </xsl:if>
            </xsl:for-each>
        </c:manifest>
    </xsl:template>

</xsl:stylesheet>
