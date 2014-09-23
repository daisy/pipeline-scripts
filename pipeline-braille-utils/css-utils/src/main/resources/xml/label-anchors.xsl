<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@xml:id]" priority="0.6">
        <xsl:call-template name="try-anchor">
            <xsl:with-param name="name" select="replace(@xml:id,'^#','')"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="*[@id]">
        <xsl:call-template name="try-anchor">
            <xsl:with-param name="name" select="replace(@id,'^#','')"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="try-anchor">
        <xsl:param name="name" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="collection()//*[self::css:target-text-fn or
                                            self::css:target-string-fn or
                                            self::css:target-counter-fn]
                                           [replace(@target,'^#','')=$name]">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:attribute name="css:anchor" select="$name"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:target-text-fn/@target|
                         css:target-string-fn/@target|
                         css:target-counter-fn/@target">
        <xsl:attribute name="target" select="replace(.,'^#','')"/>
    </xsl:template>
    
</xsl:stylesheet>
