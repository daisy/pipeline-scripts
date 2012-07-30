<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="xs css"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille-css/xslt/parsing-helper.xsl" />
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@style), 'list-item')]">
        <xsl:variable name="display" as="xs:string"
            select="css:get-property-value(., 'display', true(), true(), false())"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="$display='list-item'">
                <xsl:variable name="list-style-type" as="xs:string"
                    select="css:get-property-value(., 'list-style-type', true(), true(), false())"/>
                <xsl:if test="$list-style-type!='none'">
                    <xsl:element name="css:marker">
                        <xsl:attribute name="style" select="'display:inline'"/>
                        <xsl:choose>
                            <xsl:when test="$list-style-type='decimal'">
                                <xsl:number value="count(preceding-sibling::*) + 1" format="1"/>
                                <xsl:text>. </xsl:text>
                            </xsl:when>
                            <xsl:when test="$list-style-type='lower-alpha'">
                                <xsl:number value="count(preceding-sibling::*) + 1" format="a"/>
                                <xsl:text>. </xsl:text>
                            </xsl:when>
                            <xsl:when test="$list-style-type='upper-alpha'">
                                <xsl:number value="count(preceding-sibling::*) + 1" format="A"/>
                                <xsl:text>. </xsl:text>
                            </xsl:when>
                            <xsl:when test="$list-style-type='lower-roman'">
                                <xsl:number value="count(preceding-sibling::*) + 1" format="i"/>
                                <xsl:text>. </xsl:text>
                            </xsl:when>
                            <xsl:when test="$list-style-type='upper-roman'">
                                <xsl:number value="count(preceding-sibling::*) + 1" format="I"/>
                                <xsl:text>. </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="concat($list-style-type, ' ')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>