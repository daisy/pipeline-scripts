<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:variable name="property-names" as="xs:string*"
        select="('text-align',
                 'margin-left',
                 'margin-right',
                 'margin-top',
                 'margin-bottom',
                 'text-indent',
                 'page-break-before',
                 'page-break-after',
                 'page-break-inside',
                 'orphans',
                 'widows',
                 'border-bottom',
                 'border-top',
                 'padding-bottom',
                 'padding-top')"/>
    
    <xsl:variable name="default-property-values" as="xs:string*"
        select="('inherit',
                 'inherit',
                 'inherit',
                 '0',
                 '0',
                 'inherit',
                 'auto',
                 'auto',
                 'inherit',
                 '0',
                 '0',
                 'none',
                 'none',
                 '0',
                 '0')"/>
    
    <xsl:function name="brl:style" as="element()">
        <xsl:param name="style-name" as="xs:string" />
        <!--<xsl:param name="base-style-string" as="xs:string" />-->
        <xsl:param name="style-string" as="xs:string" />
        <brl:style name="{$style-name}">
            <xsl:for-each select="$property-names">
                <xsl:variable name="property" select="brl:get-property($style-string, .)"/>
                <xsl:if test="$property">
                    <xsl:attribute name="{.}" select="$property"/>
                </xsl:if>
            </xsl:for-each>
        </brl:style>
    </xsl:function>
    
    <xsl:function name="brl:style-string" as="xs:string">
        <xsl:param name="style" as="element()" />
        <xsl:variable name="name-value-pairs" as="xs:string*">
            <xsl:for-each select="$property-names">
                <xsl:variable name="value" select="brl:get-property($style, ., ())" as="xs:string?"/>
                <xsl:if test="$value">
                    <xsl:if test="$value!=brl:get-default-property(.)">
                        <xsl:sequence select="concat(.,':',$value)"/>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($name-value-pairs,';')"/>
    </xsl:function>
    
    <xsl:function name="brl:get-property" as="xs:string?">
        <xsl:param name="style" as="element()" />
        <xsl:param name="property-name" as="xs:string"/>
        <xsl:param name="default-value" as="xs:string?"/>
        <xsl:variable name="value" as="xs:string?" select="$style/@*[name()=$property-name]"/>
        <xsl:choose>
            <xsl:when test="$value">
                <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:when test="$default-value">
                <xsl:value-of select="$default-value"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="brl:get-property" as="xs:string?">
        <xsl:param name="style-string" as="xs:string"/>
        <xsl:param name="property-name" as="xs:string"/>
        <xsl:variable name="value" as="xs:string?">
            <xsl:for-each select="tokenize($style-string,';')">
                <xsl:if test="normalize-space(substring-before(.,':'))=$property-name">
                    <xsl:value-of select="normalize-space(substring-after(.,':'))" />
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="$value">
            <xsl:value-of select="$value"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="brl:get-default-property" as="xs:string?">
        <xsl:param name="property-name" as="xs:string"/>
        <xsl:variable name="index" select="index-of($property-names, $property-name)" as="xs:integer?"/>
        <xsl:if test="$index">
            <xsl:value-of select="$default-property-values[$index]"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>