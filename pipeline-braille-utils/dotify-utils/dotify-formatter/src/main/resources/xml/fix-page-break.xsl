<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl" />
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@css:page-break-before|
                         @css:page-break-after|
                         @css:page-break-inside"/>
    
    <xsl:template match="css:box[@type='block']" priority="0.7">
        <xsl:param name="force-break-before" as="xs:boolean" select="false()"/>
        <xsl:param name="force-break-after" as="xs:boolean" select="false()"/>
        <xsl:param name="avoid-break-before" as="xs:boolean" select="false()"/>
        <xsl:param name="avoid-break-after" as="xs:boolean" select="false()"/>
        <xsl:param name="avoid-break-inside" as="xs:boolean" select="false()"/>
        <xsl:next-match>
            <xsl:with-param name="force-break-before"
                            select="$force-break-before or @css:page-break-before=('always','right','left')"/>
            <xsl:with-param name="force-break-after"
                            select="$force-break-after or @css:page-break-after=('always','right','left')"/>
            <xsl:with-param name="avoid-break-before"
                            select="$avoid-break-before or @css:page-break-before='avoid'"/>
            <xsl:with-param name="avoid-break-after"
                            select="$avoid-break-after or @css:page-break-after='avoid'"/>
            <xsl:with-param name="avoid-break-inside"
                            select="$avoid-break-inside or @css:page-break-inside='avoid'"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']">
        <xsl:param name="force-break-before" as="xs:boolean"/>
        <xsl:param name="force-break-after" as="xs:boolean"/>
        <xsl:param name="avoid-break-before" as="xs:boolean"/>
        <xsl:param name="avoid-break-after" as="xs:boolean"/>
        <xsl:param name="avoid-break-inside" as="xs:boolean"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="count(child::css:box)=1">
                    <xsl:apply-templates select="child::css:box">
                        <xsl:with-param name="force-break-before" select="$force-break-before"/>
                        <xsl:with-param name="force-break-after" select="$force-break-after"/>
                        <xsl:with-param name="avoid-break-before" select="$avoid-break-before"/>
                        <xsl:with-param name="avoid-break-after" select="$avoid-break-after"/>
                        <xsl:with-param name="avoid-break-inside" select="$avoid-break-inside"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="child::css:box[1]">
                        <xsl:with-param name="force-break-before" select="$force-break-before"/>
                        <xsl:with-param name="avoid-break-before" select="$avoid-break-before"/>
                        <xsl:with-param name="avoid-break-after" select="$avoid-break-inside"/>
                        <xsl:with-param name="avoid-break-inside" select="$avoid-break-inside"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="child::css:box[position()&gt;1 and position()&lt;last()]">
                        <xsl:with-param name="avoid-break-before" select="$avoid-break-inside"/>
                        <xsl:with-param name="avoid-break-after" select="$avoid-break-inside"/>
                        <xsl:with-param name="avoid-break-inside" select="$avoid-break-inside"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="child::css:box[last()]">
                        <xsl:with-param name="force-break-before" select="false()"/>
                        <xsl:with-param name="force-break-after" select="$force-break-after"/>
                        <xsl:with-param name="avoid-break-before" select="$avoid-break-inside"/>
                        <xsl:with-param name="avoid-break-after" select="$avoid-break-after"/>
                        <xsl:with-param name="avoid-break-inside" select="$avoid-break-inside"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block'][not(child::css:box[@type='block'])]" priority="0.6">
        <xsl:param name="force-break-before" as="xs:boolean"/>
        <xsl:param name="force-break-after" as="xs:boolean"/>
        <xsl:param name="avoid-break-before" as="xs:boolean"/>
        <xsl:param name="avoid-break-after" as="xs:boolean"/>
        <xsl:param name="avoid-break-inside" as="xs:boolean"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="$force-break-before">
                <xsl:attribute name="css:page-break-before" select="'always'"/>
            </xsl:if>
            <xsl:if test="$force-break-after">
                <xsl:attribute name="css:page-break-after" select="'always'"/>
            </xsl:if>
            <xsl:if test="not($force-break-before) and $avoid-break-before">
                <xsl:attribute name="css:page-break-before" select="'avoid'"/>
            </xsl:if>
            <xsl:if test="not($force-break-after) and $avoid-break-after">
                <xsl:attribute name="css:page-break-after" select="'avoid'"/>
            </xsl:if>
            <xsl:if test="$avoid-break-inside">
                <xsl:attribute name="css:page-break-inside" select="'avoid'"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
