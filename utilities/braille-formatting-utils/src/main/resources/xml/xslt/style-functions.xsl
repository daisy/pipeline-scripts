<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    exclude-result-prefixes="xs brl"
    version="2.0">
    
    <xsl:variable name="property-names" as="xs:string*"
        select="('display',
                 'margin-left',
                 'margin-right',
                 'margin-top',
                 'margin-bottom',
                 'padding-left',
                 'padding-right',
                 'padding-bottom',
                 'padding-top',
                 'border-left',
                 'border-right',
                 'border-bottom',
                 'border-top',
                 'text-align',
                 'text-indent',
                 'page-break-before',
                 'page-break-after',
                 'page-break-inside',
                 'orphans',
                 'widows',
                 'list-style-type',
                 'margin-left-absolute',
                 'margin-right-absolute')"/>
    
    <xsl:variable name="default-property-values" as="xs:string*"
        select="('inline',
                 '0',
                 '0',
                 '0',
                 '0',
                 '0',
                 '0',
                 '0',
                 '0',
                 'none',
                 'none',
                 'none',
                 'none',
                 'inherit',
                 'inherit',
                 'auto',
                 'auto',
                 'inherit',
                 '0',
                 '0',
                 'inherit',
                 'inherit',
                 'inherit')"/>
    
    <xsl:function name="brl:get-default-property" as="xs:string?">
        <xsl:param name="property-name" as="xs:string"/>
        <xsl:variable name="index" select="index-of($property-names, $property-name)" as="xs:integer?"/>
        <xsl:if test="$index">
            <xsl:value-of select="$default-property-values[$index]"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="brl:get-property" as="xs:string?">
        <xsl:param name="style"/>
        <xsl:param name="property-name" as="xs:string"/>
        <xsl:param name="default-value" as="xs:string?"/>
        <xsl:variable name="value" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$style instance of xs:string">
                    <xsl:if test="contains($style, $property-name)">
                        <xsl:for-each select="tokenize($style,';')">
                            <xsl:if test="normalize-space(substring-before(.,':'))=$property-name">
                                <xsl:value-of select="normalize-space(substring-after(.,':'))" />
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$style instance of element() and $style[self::brl:style]">
                    <xsl:sequence select="string($style/@*[name()=$property-name])"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$value">
                <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:when test="$default-value">
                <xsl:value-of select="$default-value"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="brl:get-property-or-default" as="xs:string?">
        <xsl:param name="style"/>
        <xsl:param name="property-name" as="xs:string"/>
        <xsl:variable name="value" as="xs:string?"
            select="brl:get-property($style, $property-name, ())"/>
        <xsl:choose>
            <xsl:when test="$value">
                <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="default-value" as="xs:string?"
                    select="brl:get-default-property($property-name)"/>
                <xsl:if test="$default-value">
                    <xsl:value-of select="$default-value"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="brl:get-property-or-inherited" as="xs:string?">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="property-name" as="xs:string"/>
        <xsl:variable name="value"
            select="brl:get-property-or-default(string($element/@brl:style), $property-name)"/>
        <xsl:choose>
            <xsl:when test="$value='inherit' and $element/parent::*">
                <xsl:sequence select="brl:get-property-or-inherited($element/parent::*, $property-name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$value" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="brl:override-style" as="xs:string">
        <xsl:param name="base-style"/>
        <xsl:param name="override-with-style"/>
        <xsl:variable name="name-value-pairs" as="xs:string*">
            <xsl:for-each select="$property-names">
                <xsl:variable name="override-with-value"
                    select="brl:get-property($override-with-style, ., ())" as="xs:string?"/>
                <xsl:choose>
                    <xsl:when test="$override-with-value">
                        <xsl:sequence select="concat(.,':',$override-with-value)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="base-value"
                            select="brl:get-property($base-style, ., ())" as="xs:string?"/>
                        <xsl:if test="$base-value">
                            <xsl:sequence select="concat(.,':',$base-value)"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($name-value-pairs,';')"/>
    </xsl:function>
    
    <xsl:function name="brl:remove-style-values" as="xs:string">
        <xsl:param name="base-style"/>
        <xsl:param name="remove-values" as="xs:string*"/>
        <xsl:variable name="name-value-pairs" as="xs:string*">
            <xsl:for-each select="$property-names">
                <xsl:if test="not(index-of($remove-values, .))">
                    <xsl:variable name="base-value"
                        select="brl:get-property($base-style, ., ())" as="xs:string?"/>
                    <xsl:if test="$base-value">
                        <xsl:sequence select="concat(.,':',$base-value)"/>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($name-value-pairs,';')"/>
    </xsl:function>
    
    <xsl:function name="brl:style-element" as="element()">
        <xsl:param name="style-string" as="xs:string" />
        <xsl:param name="style-name" as="xs:string?" />
        <brl:style>
            <xsl:if test="$style-name">
                <xsl:attribute name="name" select="$style-name"/>
            </xsl:if>
            <xsl:for-each select="$property-names">
                <xsl:variable name="property" select="brl:get-property($style-string, ., ())"/>
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
                    <xsl:sequence select="concat(.,':',$value)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($name-value-pairs,';')"/>
    </xsl:function>
    
    <xsl:function name="brl:style-string-without-defaults" as="xs:string">
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
    
    <xsl:function name="brl:style-string-without-inherit" as="xs:string">
        <xsl:param name="element" as="element()"/>
        <xsl:variable name="name-value-pairs" as="xs:string*">
            <xsl:for-each select="$property-names">
                <xsl:sequence select="concat(.,':',brl:get-property-or-inherited($element, .))"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($name-value-pairs,';')"/>
    </xsl:function>
    
</xsl:stylesheet>