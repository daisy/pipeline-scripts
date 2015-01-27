<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:include href="library.xsl"/>
    
    <!--
        override template in order to prevent already parsed properties to be serialized again
    -->
    <xsl:template match="@css:*" mode="css:attribute-as-property"/>
    
    <xsl:template match="/">
        <xsl:variable name="root" as="element()" select="/*"/>
        <xsl:for-each select="distinct-values(//*/@css:flow)[not(.='normal')]">
            <xsl:variable name="flow" as="xs:string" select="."/>
            <xsl:result-document href="{$flow}">
                <css:_ css:flow="{$flow}">
                    <xsl:for-each select="$root//*[@css:flow=$flow]">
                        <xsl:copy>
                            <xsl:sequence select="@* except (@style|@css:flow|@css:id)"/>
                            <xsl:sequence select="css:style-attribute(css:serialize-declaration-list(
                                                  css:specified-properties($css:properties, true(), false(), false(), .)
                                                  [not(@value='initial')]))"/>
                            <xsl:attribute name="css:anchor" select="if (@css:id) then string(@css:id) else generate-id(.)"/>
                            <xsl:apply-templates/>
                        </xsl:copy>
                    </xsl:for-each>
                </css:_>
            </xsl:result-document>
        </xsl:for-each>
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@css:flow"/>
    
    <xsl:template match="*[@css:flow[not(.='normal')]]">
        <css:_ css:id="{if (@css:id) then string(@css:id) else generate-id(.)}"/>
    </xsl:template>
    
    <xsl:template match="*[not(descendant-or-self::*/@css:flow)]">
        <xsl:sequence select="."/>
    </xsl:template>
    
</xsl:stylesheet>
