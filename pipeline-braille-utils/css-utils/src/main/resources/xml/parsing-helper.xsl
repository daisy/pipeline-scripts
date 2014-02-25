<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:re="regex-utils"
    exclude-result-prefixes="xs css"
    version="2.0">
    
    <xsl:import href="http://www.daisy.org/pipeline/modules/braille/css-core/supported-css.xsl"/>
    
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
            <xsl:sequence select="for $declaration
                                  in tokenize($declarations, ';')[not(normalize-space(.)='')]
                                  return replace($declaration, '(^\s+|\s+$)', '')"/>
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
    
    <xsl:variable name="IDENT_RE" select="'(\p{L}|_)(\p{L}|_|-)*'"/>
    <!--
        <string>
    -->
    <xsl:variable name="STRING_RE">('.*?'|".*?")</xsl:variable>
    <!--
        content()
    -->
    <xsl:variable name="CONTENT_FN_RE" select="'content\(\)'"/>
    <!--
        attr(<name>)
    -->
    <xsl:variable name="ATTR_FN_RE" select="concat('attr\(\s*(',$IDENT_RE,')\s*\)')"/>
    <!--
        string(<identifier>)
    -->
    <xsl:variable name="STRING_FN_RE" select="concat('string\(\s*(',$IDENT_RE,')\s*\)')"/>
    <!--
        counter(<identifier>,<style>?)
    -->
    <xsl:variable name="COUNTER_FN_RE" select="concat('counter\(\s*(',$IDENT_RE,')\s*(,\s*(',$IDENT_RE,')\s*)?\)')"/>
    <!--
        $1: <string>
        $3: content()
        $4: attr(<name>)
        $5:      <name>
        $8: string(<identifier>)
        $9:        <identifier>
        $12: counter(<identifier>,<style>?)
        $13:         <identifier>
        $16:                      <style>
    -->
    <xsl:variable name="CONTENT_RE" select="concat('(',$STRING_RE,')|
                                                    (',$CONTENT_FN_RE,')|
                                                    (',$ATTR_FN_RE,')|
                                                    (',$STRING_FN_RE,')|
                                                    (',$COUNTER_FN_RE,')')"/>
    
    <xsl:function name="css:eval-content-list">
        <xsl:param name="context" as="element()"/>
        <xsl:param name="content-list" as="xs:string"/>
        <xsl:analyze-string select="$content-list" regex="{$CONTENT_RE}" flags="x">
            <xsl:matching-substring>
                <xsl:choose>
                    <!--
                        <string>
                    -->
                    <xsl:when test="regex-group(1)!=''">
                        <xsl:variable name="string" as="xs:string"
                                      select="substring(regex-group(1), 2, string-length(regex-group(1))-2)"/>
                        <xsl:sequence select="$string"/>
                    </xsl:when>
                    <!--
                        content()
                    -->
                    <xsl:when test="regex-group(3)!=''">
                        <xsl:if test="$context">
                            <xsl:sequence select="$context/child::node()"/>
                        </xsl:if>
                    </xsl:when>
                    <!--
                        attr(<name>)
                    -->
                    <xsl:when test="regex-group(4)!=''">
                        <xsl:if test="$context">
                            <xsl:variable name="name" as="xs:string" select="regex-group(5)"/>
                            <xsl:sequence select="string($context/@*[name()=$name])"/>
                        </xsl:if>
                    </xsl:when>
                    <!--
                        string(<identifier>)
                    -->
                    <xsl:when test="regex-group(8)!=''">
                        <xsl:variable name="identifier" as="xs:string" select="regex-group(9)"/>
                        <xsl:element name="css:string">
                            <xsl:attribute name="identifier" select="$identifier"/>
                        </xsl:element>
                    </xsl:when>
                    <!--
                        counter(<identifier>,<style>?)
                    -->
                    <xsl:when test="regex-group(12)!=''">
                        <xsl:variable name="identifier" as="xs:string" select="regex-group(13)"/>
                        <xsl:variable name="style" as="xs:string" select="regex-group(16)"/>
                        <xsl:element name="css:counter">
                            <xsl:attribute name="identifier" select="$identifier"/>
                            <xsl:if test="$style!=''">
                                <xsl:attribute name="style" select="$style"/>
                            </xsl:if>
                        </xsl:element>
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
