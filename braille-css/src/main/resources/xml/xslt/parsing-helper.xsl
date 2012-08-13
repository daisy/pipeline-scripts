<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css" exclude-result-prefixes="xs css"
    version="2.0">

    <xsl:include href="supported-css.xsl"/>

    <xsl:function name="css:get-property-value" as="xs:string?">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="property-name" as="xs:string"/>
        <xsl:param name="concretize-inherit" as="xs:boolean"/>
        <xsl:param name="include-default" as="xs:boolean"/>
        <xsl:param name="validate" as="xs:boolean"/>

        <xsl:if test="not($validate) or css:is-property($property-name)">
            <xsl:choose>
                <xsl:when test="not($validate) or css:applies-to($property-name, css:get-property-value($element, 'display', true(), true(), false()))">
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
                    <xsl:variable name="property-value-or-default" as="xs:string?">
                        <xsl:choose>
                            <xsl:when test="$property-value[1]">
                                <xsl:if test="not($validate) or css:is-valid-property($property-name, $property-value)">
                                    <xsl:sequence select="$property-value[1]"/>
                                </xsl:if>
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
                            <xsl:when
                                test="$property-value-or-default='inherit' and $concretize-inherit">
                                <xsl:choose>
                                    <xsl:when test="$element/parent::*">
                                        <xsl:sequence
                                            select="css:get-property-value($element/parent::*, $property-name, true(), $include-default, $validate)"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="$include-default">
                                            <xsl:sequence
                                              select="css:get-default-value($property-name)"/>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="$property-value-or-default"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$include-default">
                        <xsl:sequence select="css:get-default-value($property-name)"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>

    <xsl:function name="css:evaluate-content-list">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="content-list" as="xs:string"/>
        <xsl:variable name="STRING">'.+?'|".+?"</xsl:variable>
        <xsl:variable name="CONTENT">content\(\)</xsl:variable>
        <xsl:variable name="ATTR">attr\(.+?\)</xsl:variable>
        <xsl:analyze-string select="$content-list"
            regex="{concat('(', $STRING, '|', $CONTENT, '|', $ATTR, ')')}">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="matches(., concat('^', $STRING, '$'))">
                        <xsl:sequence select="substring(., 2, string-length(.)-2)"/>
                    </xsl:when>
                    <xsl:when test="matches(., concat('^', $ATTR, '$'))">
                        <xsl:variable name="attr"
                            select="normalize-space(substring(., 6, string-length(.)-6))"/>
                        <xsl:sequence select="string($element/@*[name()=$attr])"/>
                    </xsl:when>
                    <xsl:when test="matches(., concat('^', $CONTENT, '$'))">
                        <xsl:sequence select="$element/child::node()"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:function name="css:remove-properties" as="xs:string">
        <xsl:param name="style" as="xs:string"/>
        <xsl:param name="remove" as="xs:string*"/>
        <xsl:variable name="name-value-pairs" as="xs:string*">
            <xsl:for-each select="tokenize($style,';')">
                <xsl:if test="not(index-of($remove, normalize-space(substring-before(.,':'))))">
                    <xsl:sequence select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="string-join($name-value-pairs,';')"/>
    </xsl:function>

</xsl:stylesheet>
