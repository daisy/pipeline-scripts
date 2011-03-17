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
        <xsl:element name="c:body">
            <xsl:for-each select="child::*">
                <xsl:variable name="href" select="tokenize(child::h:a/@href,'#')[1]"/>
                <xsl:if
                    test="not(preceding-sibling::*/descendant::h:a[tokenize(@href,'#')[1]=$href])">
                    <xsl:element name="c:file">
                        <xsl:attribute name="href" select="$href"/>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
