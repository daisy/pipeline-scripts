<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:sequence select="@*"/>
            <xsl:call-template name="apply-templates"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@css:white-space]">
        <xsl:copy>
            <xsl:sequence select="@* except @css:white-space"/>
            <xsl:call-template name="apply-templates">
                <xsl:with-param name="preserve" select="@css:white-space='pre'" tunnel="yes"/>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="apply-templates">
        <xsl:param name="preserve" as="xs:boolean" select="false()" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$preserve">
                <xsl:for-each-group select="*|text()" group-adjacent="boolean(self::*)">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key()">
                            <xsl:for-each select="current-group()">
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="string-join(current-group()/string(.), '')!=''">
                            <xsl:element name="css:white-space">
                                <xsl:sequence select="current-group()"/>
                            </xsl:element>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:sequence select="."/>
    </xsl:template>
    
</xsl:stylesheet>
