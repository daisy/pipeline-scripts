<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-result-prefixes="xs css pxi"
    version="2.0">
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@css:display='toc-item']">
        <xsl:variable name="ref" as="attribute()?" select="@ref"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="$ref and collection()//*[@xml:id=string($ref)]">
                    <xsl:apply-templates select="@ref|@style|@css:display"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*"/>
                    <xsl:attribute name="css:display" select="'block'"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@xml:id]">
        <xsl:variable name="id" select="string(@xml:id)"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="some $ref in collection()//*[@ref=$id] satisfies $ref/@css:display='toc-item'">
                <xsl:attribute name="css:target" select="'true'"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
