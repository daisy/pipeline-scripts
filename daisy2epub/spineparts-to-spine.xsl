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
            <xsl:for-each select="//c:file">
                <xsl:variable name="href" select="tokenize(@href,'#')[1]"/>
                <xsl:if test="not(preceding::c:file/@href[tokenize(.,'#')[1]=$href])">
                    <c:file href="{$href}"/>
                </xsl:if>
            </xsl:for-each>
        </c:result>
    </xsl:template>

</xsl:stylesheet>
