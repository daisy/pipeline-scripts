<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="2.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <c:result>
            <xsl:for-each select="//text">
                <xsl:variable name="src" select="tokenize(@src,'#')[1]"/>
                <xsl:if test="not(preceding::text/@src[tokenize(.,'#')[1]=$src])">
                    <c:file href="{$src}"/>
                </xsl:if>
            </xsl:for-each>
        </c:result>
    </xsl:template>

</xsl:stylesheet>
