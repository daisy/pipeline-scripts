<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:variable name="properties" as="xs:string*"
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
                 'text-indent',
                 'list-style-type',
                 'text-align',
                 'page-break-before',
                 'page-break-after',
                 'page-break-inside',
                 'orphans',
                 'widows',
                 'page',
                 'font-style',
                 'font-weight',
                 'text-decoration',
                 'color')"/>

    <xsl:variable name="ATTR" select="'attr\(.+?\)'"/>
    <xsl:variable name="COLOR" select="'#[0-9A-F]{6}'"/>
    <xsl:variable name="CONTENT" select="'content\(\)'"/>
    <xsl:variable name="DOT_PATTERN" select="'\p{IsBraillePatterns}'"/>
    <xsl:variable name="IDENT" select="'\p{L}|_(\p{L}|_|-)*'"/>
    <xsl:variable name="INHERIT" select="'inherit'"/>
    <xsl:variable name="INTEGER" select="'(0|-?[1-9][0-9]*)(\.0*)?'"/>
    <xsl:variable name="NATURAL_NUMBER" select="'(0|[1-9][0-9]*)(\.0*)?'"/>
    <xsl:variable name="STRING">'.+?'|".+?"</xsl:variable>
    
    <xsl:variable name="valid-properties" as="xs:string*"
        select="(concat('^(', 'block|inline|list-item|none|toc|toc-item|page-break', ')$'),
                 concat('^(', $INTEGER, ')$'),
                 concat('^(', $INTEGER, ')$'),
                 concat('^(', $NATURAL_NUMBER, ')$'),
                 concat('^(', $NATURAL_NUMBER, ')$'),
                 concat('^(', $NATURAL_NUMBER, ')$'),
                 concat('^(', $NATURAL_NUMBER, ')$'),
                 concat('^(', $NATURAL_NUMBER, ')$'),
                 concat('^(', $NATURAL_NUMBER, ')$'),
                 concat('^(', $DOT_PATTERN, '|', 'none', ')$'),
                 concat('^(', $DOT_PATTERN, '|none', ')$'),
                 concat('^(', $DOT_PATTERN, '|none', ')$'),
                 concat('^(', $DOT_PATTERN, '|none', ')$'),
                 concat('^(', $INTEGER, '|', $INHERIT, ')$'),
                 concat('^(', $DOT_PATTERN, '|demical|lower-alpha|lower-roman|none|upper-alpha|upper-roman|', $INHERIT, ')$'),
                 concat('^(', 'center|justify|left|right|', $INHERIT, ')$'),
                 concat('^(', 'always|auto|avoid|left|right|', $INHERIT, ')$'),
                 concat('^(', 'always|auto|avoid|left|right|', $INHERIT, ')$'),
                 concat('^(', 'auto|avoid|', $INHERIT, ')$'),
                 concat('^(', $INTEGER, '|', $INHERIT, ')$'),
                 concat('^(', $INTEGER, '|', $INHERIT, ')$'),
                 concat('^(', $IDENT, '|auto', ')$ '),
                 concat('^(', 'normal|italic|oblique|', $INHERIT, ')$ '),
                 concat('^(', 'normal|bold|100|200|300|400|500|600|700|800|900|', $INHERIT, ')$ '),
                 concat('^(', 'none|underline|overline|line-through|blink', $INHERIT, ')$ '),
                 concat('^(', $COLOR, '|', $INHERIT, ')$ '))"/>
    
    <xsl:variable name="applies-to" as="xs:string*"
        select="('.*',
                 '^(block|list-item|toc|toc-item)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc|toc-item)$',
                 '^(list-item)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^(block|list-item|toc)$',
                 '^inline$',
                 '^inline$',
                 '^inline$',
                 '^inline$')"/>
    
    <xsl:variable name="default-values" as="xs:string*"
        select="('inline',
                 '0.0',
                 '0.0',
                 '0.0',
                 '0.0',
                 '0.0',
                 '0.0',
                 '0.0',
                 '0.0',
                 'none',
                 'none',
                 'none',
                 'none',
                 '0.0',
                 'none',
                 'left',
                 'auto',
                 'auto',
                 'auto',
                 '2.0',
                 '2.0',
                 'auto',
                 'normal',
                 'normal',
                 'none',
                 '#000000')"/>
    
    <xsl:variable name="media" as="xs:string*"
        select="('embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'print',
                 'print',
                 'print',
                 'print')"/>
    
    <xsl:variable name="inherited-properties" as="xs:string*"
        select="('-brl-text-indent',
                 '-brl-list-style-type',
                 'text-align',
                 'orphans',
                 'widows',
                 'page',
                 'font-style',
                 'font-weight',
                 'text-decoration',
                 'color')"/>
    
    <xsl:variable name="paged-properties" as="xs:string*"
        select="('page-break-before',
                 'page-break-after',
                 'page-break-inside',
                 'orphans',
                 'widows')"/>

    <xsl:function name="css:get-properties" as="xs:string*">
        <xsl:sequence select="$properties"/>
    </xsl:function>

    <xsl:function name="css:is-property" as="xs:boolean">
        <xsl:param name="property" as="xs:string"/>
        <xsl:sequence select="boolean(index-of($properties, $property))"/>
    </xsl:function>

    <xsl:function name="css:is-valid-property" as="xs:boolean">
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:variable name="index" select="pxi:index-of($properties, $property)"/>
        <xsl:sequence select="if ($index) then matches($value, $valid-properties[$index]) else false()"/>
    </xsl:function>

    <xsl:function name="css:get-default-value" as="xs:string?">
        <xsl:param name="property" as="xs:string"/>
        <xsl:variable name="index" select="pxi:index-of($properties, $property)"/>
        <xsl:if test="$index">
            <xsl:sequence select="$default-values[$index]"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:is-inherited-property" as="xs:boolean">
        <xsl:param name="property" as="xs:string"/>
        <xsl:sequence select="boolean(pxi:index-of($inherited-properties, $property))"/>
    </xsl:function>
    
    <xsl:function name="css:applies-to" as="xs:boolean">
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="display" as="xs:string"/>
        <xsl:variable name="index" select="pxi:index-of($properties, $property)"/>
        <xsl:sequence select="if ($index) then matches($display, $applies-to[$index]) else false()"/>
    </xsl:function>
    
    <xsl:function name="pxi:index-of" as="xs:integer?">
        <xsl:param name="sequence"/>
        <xsl:param name="property"/>
        <xsl:choose>
            <xsl:when test="index-of($sequence, $property)">
                <xsl:sequence select="index-of($sequence, $property)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="index-of($sequence, concat('-brl-', $property))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
