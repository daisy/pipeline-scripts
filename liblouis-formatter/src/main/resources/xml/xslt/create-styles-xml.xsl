<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-result-prefixes="xs louis"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:output method="xml" encoding="UTF-8" indent="yes" name="louis-styles-output"/>
   
    <xsl:key name="style-string" match="//*[@style]" use="string(@style)"/>
   
    <xsl:template match="/">
        <xsl:result-document href="louis-styles.xml" format="louis-styles-output">
            <louis:styles>
                <xsl:for-each select="//*[@style]">
                    <xsl:variable name="style" select="string(@style)"/>
                    <xsl:variable name="style-name" select="louis:generate-style-name(.)"/>
                    <xsl:if test="$style-name=louis:generate-style-name(key('style-string', $style)[1])">
                        <xsl:sequence select="louis:create-style-element($style, $style-name)"/>
                    </xsl:if>
                </xsl:for-each>
            </louis:styles>
        </xsl:result-document>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@louis:style">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="@style">
        <xsl:attribute name="louis:style" select="concat('#', louis:generate-style-name(key('style-string', string(.))[1]))"/>
    </xsl:template>

    <xsl:function name="louis:create-style-element" as="element()">
        <xsl:param name="style" as="xs:string" />
        <xsl:param name="style-name" as="xs:string" />
        <louis:style>
            <xsl:attribute name="name" select="$style-name"/>
            <xsl:for-each select="tokenize($style,';')">
                <xsl:variable name="key" select="normalize-space(substring-before(.,':'))"/>
                <xsl:variable name="value" select="normalize-space(substring-after(.,':'))"/>
                <xsl:if test="$key!='' and $value!=''">
                    <xsl:attribute name="{$key}">
                        <xsl:sequence select="$value"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:for-each>
        </louis:style>
    </xsl:function>

    <xsl:function name="louis:generate-style-name" as="xs:string">
        <xsl:param name="element" as="element()" />
        <xsl:value-of select="generate-id($element)"/>
    </xsl:function>
    
</xsl:stylesheet>
