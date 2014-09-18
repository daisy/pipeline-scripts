<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="/*">
        <css:root>
            <xsl:next-match/>
        </css:root>
    </xsl:template>
    
    <xsl:template match="*[@css:display]">
        <xsl:choose>
            <xsl:when test="@css:display='none'">
                <xsl:element name="css:_">
                    <xsl:if test="descendant-or-self::*[@css:string-set]">
                        <xsl:attribute name="css:string-set"
                                       select="string-join(descendant-or-self::*/@css:string-set/string(.), ', ')"/>
                    </xsl:if>
                    <xsl:if test="descendant-or-self::*[@css:counter-reset]">
                        <xsl:attribute name="css:counter-reset"
                                       select="string-join(descendant-or-self::*/@css:counter-reset/string(.), ' ')"/>
                    </xsl:if>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="css:box">
                    <xsl:attribute name="type" select="if (@css:display=('block','list-item')) then 'block' else 'inline'"/>
                    <xsl:attribute name="name" select="name()"/>
                    <xsl:sequence select="@style|(@css:* except @css:display)"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:element name="css:box">
            <xsl:attribute name="type" select="'inline'"/>
            <xsl:attribute name="name" select="name()"/>
            <xsl:sequence select="@style|@css:*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:sequence select="."/>
    </xsl:template>
    
</xsl:stylesheet>
