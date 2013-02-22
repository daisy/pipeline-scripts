<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="xs css"
    version="2.0">

    <xsl:include href="supported-css.xsl"/>
    
    <xsl:function name="css:get-property-value" as="xs:string?">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="property-name" as="xs:string"/>
        <xsl:param name="concretize-inherit" as="xs:boolean"/>
        <xsl:param name="include-default" as="xs:boolean"/>
        <xsl:param name="validate" as="xs:boolean"/>
        
        <xsl:variable name="style" as="xs:string" select="string($element/@style)"/>
        <xsl:variable name="property-value" as="xs:string*"
            select="if (contains($style, $property-name))
                    then (for $property in tokenize($style,';')
                              [normalize-space(substring-before(.,':'))=$property-name]
                            return normalize-space(substring-after($property,':')))
                    else ()"/>
        <xsl:variable name="property-value-or-default" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$property-value[1]">
                    <xsl:if test="not($validate) or css:is-valid-property($property-name, $property-value)">
                        <xsl:sequence select="$property-value[1]"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="css:is-inherited-property($property-name)">
                    <xsl:sequence select="$INHERIT"/>
                </xsl:when>
                <xsl:when test="$include-default">
                    <xsl:sequence select="css:get-default-value($property-name)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$property-value-or-default">
            <xsl:choose>
                <xsl:when test="$property-value-or-default=$INHERIT and $concretize-inherit">
                    <xsl:choose>
                        <xsl:when test="$element/parent::*">
                            <xsl:sequence select="css:get-property-value($element/parent::*, $property-name, true(), $include-default, $validate)"/>
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
    </xsl:function>

    <xsl:function name="css:evaluate-content-list">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="content-list" as="xs:string"/>
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
    
    <xsl:function name="css:get-style" as="xs:string">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="property-names" as="xs:string*"/>
        <xsl:sequence select="string-join(
            for $name in $property-names return concat($name, ':', css:get-property-value($element, $name, true(), true(), true())),
            ';')"/>
    </xsl:function>
    
    <xsl:function name="css:remove-from-style" as="xs:string">
        <xsl:param name="style" as="xs:string"/>
        <xsl:param name="property-names" as="xs:string*"/>
        <xsl:sequence select="string-join(tokenize($style,';')[not(normalize-space(.)='')]
            [not(normalize-space(substring-before(.,':'))=$property-names)],';')"/>
    </xsl:function>

</xsl:stylesheet>
