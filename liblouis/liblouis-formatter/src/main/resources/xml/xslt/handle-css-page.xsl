<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl" />
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@style), '@page')]">
        <xsl:param name="current_page_style" as="xs:string?" tunnel="yes"/>
        <xsl:variable name="page_style" as="xs:string?"
                      select="css:get-declarations(css:tokenize-stylesheet(string(@style)), '@page')"/>
        <xsl:choose>
            <xsl:when test="$page_style">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:if test="not($current_page_style=$page_style)">
                        <xsl:attribute name="css:page" select="$page_style"/>
                        <xsl:if test="not(@xml:id)">
                            <xsl:attribute name="xml:id" select="generate-id()"/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:apply-templates select="node()">
                        <xsl:with-param name="current_page_style" select="$page_style" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
