<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:re="regex-utils"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="regex-utils.xsl"/>
    
    <xsl:variable name="css:properties" as="xs:string*"
        select="('display',
                 'left',
                 'right',
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
                 'string-set',
                 'counter-reset',
                 'typeform-indication',
                 'font-style',
                 'font-weight',
                 'text-decoration',
                 'color')"/>
    
    <xsl:variable name="COLOR" select="'#[0-9A-F]{6}'"/>
    <xsl:variable name="DOT_PATTERN" select="'\p{IsBraillePatterns}'"/>
    <xsl:variable name="IDENT" select="'(\p{L}|_)(\p{L}|_|-)*'"/>
    <xsl:variable name="IDENT_LIST" select="re:space-separated($IDENT)"/>
    <xsl:variable name="INHERIT" select="'inherit'"/>
    <xsl:variable name="INTEGER" select="'(0|-?[1-9][0-9]*)(\.0*)?'"/>
    <xsl:variable name="NATURAL_NUMBER" select="'(0|[1-9][0-9]*)(\.0*)?'"/>
    <xsl:variable name="STRING">('.+?'|".+?")</xsl:variable>
    <xsl:variable name="CONTENT" select="re:or(($STRING,'content\(\)','attr\(.+?\)'))"/>
    <xsl:variable name="CONTENT_LIST" select="re:space-separated($CONTENT)"/>
    
    <xsl:variable name="DECLARATIONS_BLOCK">\{(([^'"\{\}]+|'.+?'|".+?"|\{([^'"\{\}]+|'.+?'|".+?")*\})*)\}</xsl:variable>
    
    <xsl:variable name="RULESET" select="re:concat(('((@|::)',$IDENT,'\s+)?',$DECLARATIONS_BLOCK))"/>
    
    <xsl:variable name="css:valid-declarations" as="xs:string*"
        select="(re:exact(re:or(('block','inline','list-item','none','toc-item','page-break'))),
                 re:exact($NATURAL_NUMBER),
                 re:exact($NATURAL_NUMBER),
                 re:exact($INTEGER),
                 re:exact($INTEGER),
                 re:exact($NATURAL_NUMBER),
                 re:exact($NATURAL_NUMBER),
                 re:exact($NATURAL_NUMBER),
                 re:exact($NATURAL_NUMBER),
                 re:exact($NATURAL_NUMBER),
                 re:exact($NATURAL_NUMBER),
                 re:exact(re:or(($DOT_PATTERN,'none'))),
                 re:exact(re:or(($DOT_PATTERN,'none'))),
                 re:exact(re:or(($DOT_PATTERN,'none'))),
                 re:exact(re:or(($DOT_PATTERN,'none'))),
                 re:exact(re:or(($INTEGER,$INHERIT))),
                 re:exact(re:or(($DOT_PATTERN,'demical','lower-alpha','lower-roman','none','upper-alpha','upper-roman',$INHERIT))),
                 re:exact(re:or(('center','justify','left','right',$INHERIT))),
                 re:exact(re:or(('always','auto','avoid','left','right', $INHERIT))),
                 re:exact(re:or(('always','auto','avoid','left','right', $INHERIT))),
                 re:exact(re:or(('auto','avoid',$INHERIT))),
                 re:exact(re:or(($INTEGER,$INHERIT))),
                 re:exact(re:or(($INTEGER,$INHERIT))),
                 re:exact(re:or(($IDENT,'auto'))),
                 re:exact(re:comma-separated(re:join(($IDENT,$CONTENT_LIST), '\s+'))),
                 re:exact(re:space-separated(re:concat(($IDENT,'(\s+',$INTEGER,')?')))),
                 re:exact(re:or(($IDENT_LIST,'none'))),
                 re:exact(re:or(('normal','italic','oblique',$INHERIT))),
                 re:exact(re:or(('normal','bold','100','200','300','400','500','600','700','800','900',$INHERIT))),
                 re:exact(re:or(('none','underline','overline','line-through','blink',$INHERIT))),
                 re:exact(re:or(($COLOR,$INHERIT))))"/>
    
    <xsl:variable name="css:applies-to" as="xs:string*"
        select="('.*',
                 '^(block|list-item|toc-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item|toc-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item|toc-item)$',
                 '^(list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '.*',
                 '.*',
                 '.*',
                 '.*',
                 '.*',
                 '.*',
                 '.*')"/>
    
    <xsl:variable name="css:default-values" as="xs:string*"
        select="('inline',
                 '0.0',
                 '0.0',
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
                 'none',
                 'none',
                 'none',
                 'normal',
                 'normal',
                 'none',
                 '#000000')"/>
    
    <xsl:variable name="css:media" as="xs:string*"
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
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'embossed',
                 'print',
                 'print',
                 'print',
                 'print')"/>
    
    <xsl:variable name="css:inheriting-properties" as="xs:string*"
        select="('left',
                 'right',
                 'text-indent',
                 'list-style-type',
                 'text-align',
                 'orphans',
                 'widows',
                 'page',
                 'font-style',
                 'font-weight',
                 'text-decoration',
                 'color')"/>
    
    <xsl:variable name="css:paged-media-properties" as="xs:string*"
        select="('page-break-before',
                 'page-break-after',
                 'page-break-inside',
                 'orphans',
                 'widows')"/>
    
    <xsl:function name="css:get-properties" as="xs:string*">
        <xsl:sequence select="$css:properties"/>
    </xsl:function>

    <xsl:function name="css:is-property" as="xs:boolean">
        <xsl:param name="property" as="xs:string"/>
        <xsl:sequence select="boolean(index-of($css:properties, $property))"/>
    </xsl:function>
    
    <xsl:function name="css:is-valid-declaration" as="xs:boolean">
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:variable name="index" select="index-of($css:properties, $property)"/>
        <xsl:sequence select="if ($index) then matches($value, $css:valid-declarations[$index]) else false()"/>
    </xsl:function>

    <xsl:function name="css:get-default-value" as="xs:string?">
        <xsl:param name="property" as="xs:string"/>
        <xsl:variable name="index" select="index-of($css:properties, $property)"/>
        <xsl:if test="$index">
            <xsl:sequence select="$css:default-values[$index]"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:is-inheriting-property" as="xs:boolean">
        <xsl:param name="property" as="xs:string"/>
        <xsl:sequence select="boolean(index-of($css:inheriting-properties, $property))"/>
    </xsl:function>
    
    <xsl:function name="css:applies-to" as="xs:boolean">
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="display" as="xs:string"/>
        <xsl:variable name="index" select="index-of($css:properties, $property)"/>
        <xsl:sequence select="if ($index) then matches($display, $css:applies-to[$index]) else false()"/>
    </xsl:function>
    
</xsl:stylesheet>
