<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:re="regex-utils"
    exclude-result-prefixes="xs css"
    version="2.0">
    
    <xsl:import href="http://www.daisy.org/pipeline/modules/braille/css-core/xslt/supported-css.xsl"/>
    
    <xsl:function name="css:get-value" as="xs:string?">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="concretize-inherit" as="xs:boolean"/>
        <xsl:param name="include-default" as="xs:boolean"/>
        <xsl:param name="validate" as="xs:boolean"/>
        
        <xsl:variable name="declarations" as="xs:string?"
                      select="css:get-declarations(css:tokenize-stylesheet(string($element/@style)), ())"/>
        <xsl:variable name="value" as="xs:string*"
            select="if ($declarations and contains($declarations, $property))
                    then (for $declaration in css:filter-declaration(css:tokenize-declarations($declarations), $property)
                            return normalize-space(substring-after($declaration,':')))
                    else ()"/>
        <xsl:variable name="value-or-default" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$value[1]">
                    <xsl:if test="not($validate) or css:is-valid-declaration($property, $value)">
                        <xsl:sequence select="$value[1]"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="css:is-inheriting-property($property)">
                    <xsl:sequence select="$INHERIT"/>
                </xsl:when>
                <xsl:when test="$include-default">
                    <xsl:sequence select="css:get-default-value($property)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$value-or-default">
            <xsl:choose>
                <xsl:when test="$value-or-default=$INHERIT and $concretize-inherit">
                    <xsl:choose>
                        <xsl:when test="$element/parent::*">
                            <xsl:sequence select="css:get-value($element/parent::*, $property, true(), $include-default, $validate)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="$include-default">
                                <xsl:sequence
                                    select="css:get-default-value($property)"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$value-or-default"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:tokenize-stylesheet" as="xs:string*">
        <xsl:param name="stylesheet" as="xs:string"/>
        <xsl:variable name="rulesets" as="xs:string*">
            <xsl:analyze-string select="$stylesheet" regex="{$RULESET}">
                <xsl:matching-substring>
                    <xsl:sequence select="."/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="if (exists($rulesets)) then $rulesets else concat('{ ', $stylesheet, ' }')"/>
    </xsl:function>
    
    <xsl:function name="css:get-declarations" as="xs:string?">
        <xsl:param name="tokenized-stylesheet" as="xs:string*"/>
        <xsl:param name="selector" as="xs:string?"/>
        <xsl:sequence select="for $ruleset in $tokenized-stylesheet[starts-with(., if ($selector) then concat($selector,' ') else '{')][1]
                              return replace($ruleset, re:exact($RULESET), '$5')"/>
    </xsl:function>
    
    <xsl:function name="css:tokenize-declarations" as="xs:string*">
        <xsl:param name="declarations" as="xs:string?"/>
        <xsl:if test="$declarations">
            <xsl:sequence select="tokenize($declarations, ';')[not(normalize-space(.)='')]"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:filter-declaration" as="xs:string?">
        <xsl:param name="tokenized-declarations" as="xs:string*"/>
        <xsl:param name="property" as="xs:string"/>
        <xsl:sequence select="$tokenized-declarations[normalize-space(substring-before(.,':'))=$property][1]"/>
    </xsl:function>
    
    <xsl:function name="css:filter-declarations" as="xs:string*">
        <xsl:param name="tokenized-declarations" as="xs:string*"/>
        <xsl:param name="properties" as="xs:string*"/>
        <xsl:sequence select="$tokenized-declarations[normalize-space(substring-before(.,':'))=$properties]"/>
    </xsl:function>
    
    <xsl:function name="css:eval-content-list">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="content-list" as="xs:string"/>
        <xsl:analyze-string select="$content-list" regex="{$CONTENT}">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="matches(., concat('^', $STRING, '$'))">
                        <xsl:sequence select="substring(., 2, string-length(.)-2)"/>
                    </xsl:when>
                    <xsl:when test="matches(., '^attr\(.+?\)$')">
                        <xsl:variable name="attr"
                            select="normalize-space(substring(., 6, string-length(.)-6))"/>
                        <xsl:sequence select="string($element/@*[name()=$attr])"/>
                    </xsl:when>
                    <xsl:when test="matches(., '^content\(\)$')">
                        <xsl:sequence select="$element/child::node()"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="css:concretize-properties" as="xs:string">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="properties" as="xs:string*"/>
        <xsl:sequence select="string-join(
            for $property in $properties return concat($property, ':', css:get-value($element, $property, true(), true(), true())),
            '; ')"/>
    </xsl:function>
    
    <xsl:function name="css:remove-from-declarations" as="xs:string?">
        <xsl:param name="declarations" as="xs:string"/>
        <xsl:param name="properties" as="xs:string*"/>
        <xsl:variable name="remaining-declarations" as="xs:string*"
                      select="css:tokenize-declarations($declarations)[not(normalize-space(substring-before(.,':'))=$properties)]"/>
        <xsl:sequence select="if (exists($remaining-declarations))
                              then string-join($remaining-declarations, ';')
                              else ()"/>
    </xsl:function>

</xsl:stylesheet>
