<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="xs css"
    version="2.0">
    
    <xsl:include href="supported-css.xsl" />
    
    <xsl:function name="css:get-property-value" as="xs:string?">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="property-name" as="xs:string"/>
        <xsl:param name="concretize-inherit" as="xs:boolean"/>
        <xsl:param name="include-default" as="xs:boolean"/>
        <xsl:param name="validate" as="xs:boolean"/>
        
        <xsl:if test="not($validate) or css:is-property($property-name)">
            <xsl:variable name="style" as="xs:string" select="string($element/@style)"/>
            <xsl:variable name="property-value" as="xs:string*">
                <xsl:if test="contains($style, $property-name)">
                    <xsl:for-each select="tokenize($style,';')">
                        <xsl:if test="normalize-space(substring-before(.,':'))=$property-name">
                            <xsl:sequence select="normalize-space(substring-after(.,':'))"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:variable>
            <xsl:if test="not($validate) or css:is-valid-property($property-name, $property-value)">
                <xsl:variable name="property-value-or-default" as="xs:string?">
                    <xsl:choose>
                        <xsl:when test="$property-value[1]">
                            <xsl:sequence select="$property-value[1]"/>
                        </xsl:when>
                        <xsl:when test="css:is-inherited-property($property-name)">
                            <xsl:sequence select="'inherit'"/>
                        </xsl:when>
                        <xsl:when test="$include-default">
                            <xsl:sequence select="css:get-default-value($property-name)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="$property-value-or-default">
                    <xsl:choose>
                        <xsl:when test="$property-value-or-default='inherit' and $concretize-inherit">
                            <xsl:choose>
                                <xsl:when test="$element/parent::*">
                                    <xsl:sequence select="css:get-property-value($element/parent::*, $property-name, true(), $include-default, $validate)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="$include-default">
                                        <xsl:sequence select="css:get-default-value($property-name)"/>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$property-value-or-default"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>
