<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>
    <xsl:output method="xml" encoding="UTF-8" indent="no" name="automatic-styles-output"/>
    
    <xsl:include href="braille-style-utils.xsl" />
    
    <xsl:param name="automatic-styles-output-uri" as="xs:string" />
   
    <xsl:key name="style-string" match="//*[@brl:style and not(starts-with(@brl:style,'#'))]" use="string(@brl:style)"/>
   
    <xsl:template match="/">
        <xsl:result-document href="{$automatic-styles-output-uri}" format="automatic-styles-output">
            <brl:styles>
                <xsl:for-each select="//*[@brl:style and not(starts-with(@brl:style,'#'))]">
                    <xsl:variable name="style-string" select="string(@brl:style)"/>
                    <xsl:variable name="style-name" select="brl:generate-style-name(.)"/>
                    <xsl:if test="$style-name=brl:generate-style-name(key('style-string', $style-string)[1])">
                        <xsl:sequence select="brl:style($style-name, $style-string)"/>
                    </xsl:if>
                </xsl:for-each>
            </brl:styles>
        </xsl:result-document>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@brl:style[not(starts-with(.,'#'))]">
        <xsl:variable name="style-string" select="string(.)"/>
        <xsl:attribute name="brl:style" select="concat('#', brl:generate-style-name(key('style-string', $style-string)[1]))"/>
    </xsl:template>
    
    <xsl:function name="brl:generate-style-name" as="xs:string">
        <xsl:param name="element" as="element()" />
        <xsl:value-of select="concat('style_', generate-id($element))"/>
    </xsl:function>
    
</xsl:stylesheet>