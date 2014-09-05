<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <!--
        css-utils [2.0.0,3.0.0)
    -->
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:template match="@*|text()">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:sequence select="@*"/>
            <xsl:call-template name="apply-templates"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@style), 'white-space')]">
        <xsl:variable name="properties" as="element()*"
            select="css:specified-properties('#all white-space', true(), true(), true(), .)"/>
        <xsl:variable name="white-space" as="xs:string" select="$properties[@name='white-space']/@value"/>
        <xsl:copy>
            <xsl:sequence select="@*[not(name()='style')]"/>
            <xsl:sequence select="css:style-attribute(css:serialize-declaration-list(
                                    $properties[not(@name='white-space')]))"/>
            <xsl:call-template name="apply-templates">
                <xsl:with-param name="preserve" select="$white-space='pre'" tunnel="yes"/>
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
    
</xsl:stylesheet>
