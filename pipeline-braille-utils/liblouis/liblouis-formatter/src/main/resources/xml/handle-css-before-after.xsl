<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[matches(string(@style), '::before|::after')]">
        <xsl:variable name="stylesheet" as="xs:string*" select="css:tokenize-stylesheet(string(@style))"/>
        <xsl:variable name="before_style" as="xs:string?" select="css:get-declarations($stylesheet, '::before')"/>
        <xsl:variable name="after_style" as="xs:string?" select="css:get-declarations($stylesheet, '::after')"/>
        <xsl:choose>
            <xsl:when test="$before_style or $after_style">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:if test="$before_style">
                        <xsl:element name="css:before">
                            <xsl:attribute name="style" select="$before_style"/>
                            <xsl:sequence select="for $declaration in css:filter-declaration(css:tokenize-declarations($before_style), 'content')
                                                  return css:eval-content-list(., substring-after($declaration, ':'))"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:apply-templates select="node()"/>
                    <xsl:if test="$after_style">
                        <xsl:element name="css:after">
                            <xsl:attribute name="style" select="$after_style"/>
                            <xsl:sequence select="for $declaration in css:filter-declaration(css:tokenize-declarations($after_style), 'content')
                                                  return css:eval-content-list(., substring-after($declaration, ':'))"/>
                        </xsl:element>
                    </xsl:if>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
