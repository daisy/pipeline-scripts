<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="#all"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl" />
    
    <xsl:template match="/*">
        <xsl:variable name="page" select="css:get-value(., 'page', true(), true(), false())"/>
        <xsl:copy>
            <xsl:attribute name="css:page" select="$page"/>
            <xsl:apply-templates select="@*|node()">
                <xsl:with-param name="current-page" select="$page"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:param name="current-page"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()">
                <xsl:with-param name="current-page" select="$current-page"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@style), 'page')]">
        <xsl:param name="current-page"/>
        <xsl:variable name="page" select="css:get-value(., 'page', true(), true(), false())"/>
        <xsl:copy>
            <xsl:if test="$page!=$current-page">
                <xsl:attribute name="css:page" select="$page"/>
                <xsl:if test="not(@xml:id)">
                    <xsl:attribute name="xml:id" select="generate-id()"/>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="@*|node()">
                <xsl:with-param name="current-page" select="$page"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
