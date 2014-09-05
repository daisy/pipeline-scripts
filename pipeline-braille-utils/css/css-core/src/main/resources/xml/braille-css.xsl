<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:re="regex-utils"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="base.xsl"/>
    
    <!-- ==================== -->
    <!-- Property Definitions -->
    <!-- ==================== -->
    
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
                 'content',
                 'white-space',
                 'typeform-indication',
                 'font-style',
                 'font-weight',
                 'text-decoration',
                 'color')"/>
    
    <xsl:variable name="css:values" as="xs:string*"
        select="(re:exact(re:or(('block','inline','list-item','none','page-break'))),
                 re:exact(re:or(($css:NON_NEGATIVE_INTEGER_RE,'auto'))),
                 re:exact(re:or(($css:NON_NEGATIVE_INTEGER_RE,'auto'))),
                 re:exact($css:INTEGER_RE),
                 re:exact($css:INTEGER_RE),
                 re:exact($css:NON_NEGATIVE_INTEGER_RE),
                 re:exact($css:NON_NEGATIVE_INTEGER_RE),
                 re:exact($css:NON_NEGATIVE_INTEGER_RE),
                 re:exact($css:NON_NEGATIVE_INTEGER_RE),
                 re:exact($css:NON_NEGATIVE_INTEGER_RE),
                 re:exact($css:NON_NEGATIVE_INTEGER_RE),
                 re:exact(re:or(($css:BRAILLE_CHAR_RE,'none'))),
                 re:exact(re:or(($css:BRAILLE_CHAR_RE,'none'))),
                 re:exact(re:or(($css:BRAILLE_CHAR_RE,'none'))),
                 re:exact(re:or(($css:BRAILLE_CHAR_RE,'none'))),
                 re:exact($css:INTEGER_RE),
                 re:exact(re:or(($css:BRAILLE_CHAR_RE,'demical','lower-alpha','lower-roman','none','upper-alpha','upper-roman'))),
                 re:exact(re:or(('center','justify','left','right'))),
                 re:exact(re:or(('always','auto','avoid','left','right'))),
                 re:exact(re:or(('always','auto','avoid','left','right'))),
                 re:exact(re:or(('auto','avoid'))),
                 re:exact($css:INTEGER_RE),
                 re:exact($css:INTEGER_RE),
                 re:exact(re:or(($css:IDENT_RE,'auto'))),
                 re:exact(re:or(('none',re:comma-separated($css:STRING_SET_PAIR_RE)))),
                 re:exact(re:or(('none',re:space-separated($css:COUNTER_RESET_PAIR_RE)))),
                 re:exact(re:or(('none',$css:CONTENT_LIST_RE))),
                 re:exact(re:or(('default','pre'))),
                 re:exact(re:or(($css:IDENT_LIST_RE,'none'))),
                 re:exact(re:or(('normal','italic','oblique'))),
                 re:exact(re:or(('normal','bold','100','200','300','400','500','600','700','800','900'))),
                 re:exact(re:or(('none','underline','overline','line-through','blink'))),
                 re:exact($css:COLOR_RE))"/>
    
    <xsl:variable name="css:applies-to" as="xs:string*"
        select="('.*',
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
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '^(block|list-item)$',
                 '.*',
                 '.*',
                 '.*',
                 '^(::before|::after|@top-left|@top-center|@top-right|@bottom-left|@bottom-center|@bottom-right)$',
                 '.*',
                 '.*',
                 '.*',
                 '.*',
                 '.*',
                 '.*')"/>
    
    <xsl:variable name="css:initial-values" as="xs:string*"
        select="('inline',
                 'auto',
                 'auto',
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
                 'default',
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
                 'embossed',
                 'embossed',
                 'print',
                 'print',
                 'print',
                 'print')"/>
    
    <xsl:variable name="css:inherited-properties" as="xs:string*"
        select="('text-indent',
                 'list-style-type',
                 'text-align',
                 'orphans',
                 'widows',
                 'page',
                 'white-space',
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
    
    <xsl:function name="css:is-property" as="xs:boolean">
        <xsl:param name="property" as="xs:string"/>
        <xsl:sequence select="boolean($property=$css:properties)"/>
    </xsl:function>
    
    <xsl:function name="css:is-valid" as="xs:boolean">
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:variable name="index" select="index-of($css:properties, $property)"/>
        <xsl:sequence select="if ($index) then $value=('inherit', 'initial') or matches($value, $css:values[$index], 'x') else false()"/>
    </xsl:function>
    
    <xsl:function name="css:initial-value" as="xs:string?">
        <xsl:param name="property" as="xs:string"/>
        <xsl:variable name="index" select="index-of($css:properties, $property)"/>
        <xsl:if test="$index">
            <xsl:sequence select="$css:initial-values[$index]"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:is-inherited" as="xs:boolean">
        <xsl:param name="property" as="xs:string"/>
        <xsl:sequence select="boolean(index-of($css:inherited-properties, $property))"/>
    </xsl:function>
    
    <xsl:function name="css:applies-to" as="xs:boolean">
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="display" as="xs:string"/>
        <xsl:variable name="index" select="index-of($css:properties, $property)"/>
        <xsl:sequence select="if ($index) then matches($display, $css:applies-to[$index]) else false()"/>
    </xsl:function>
    
</xsl:stylesheet>
