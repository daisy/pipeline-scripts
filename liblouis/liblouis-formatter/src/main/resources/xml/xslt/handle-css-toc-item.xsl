<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="xs louis css"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl" />
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@style), 'toc-item')]">
        <xsl:variable name="display" as="xs:string"
            select="css:get-value(., 'display', true(), true(), false())"/>
        <xsl:variable name="ref" as="attribute()?" select="@ref"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="$display='toc-item' and $ref and collection()//*[@xml:id=string($ref)]">
                    <xsl:apply-templates select="@ref|@style"/>
                    <xsl:attribute name="css:toc-item" select="'true'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- Flatten elements that are referenced in a toc-item -->
    <xsl:template match="*[@xml:id]">
        <xsl:variable name="id" select="string(@xml:id)"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="some $ref in collection()//*[@ref=$id] satisfies
                    (css:get-value($ref, 'display', true(), true(), false())='toc-item')">
                    <xsl:apply-templates select="@*|node()" mode="flatten"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="element()" mode="flatten">
        <xsl:apply-templates select="node()" mode="flatten"/>
    </xsl:template>
    
    <xsl:template match="@*|text()|comment()|processing-instruction()" mode="flatten">
        <xsl:copy/>
    </xsl:template>
    
</xsl:stylesheet>
