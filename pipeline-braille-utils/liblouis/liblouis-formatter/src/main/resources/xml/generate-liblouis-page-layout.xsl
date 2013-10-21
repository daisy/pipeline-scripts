<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:variable name="SIZE_REGEX" select="concat('^\s*', $NATURAL_NUMBER, '\s+', $NATURAL_NUMBER, '\s*$')"/>
    <xsl:variable name="PRINT_PAGE_REGEX" select="'\s*string\(\s*print-page\s*\)\s*'"/>
    <xsl:variable name="RUNNING_HEADER_REGEX" select="'\s*string\(\s*running-header\s*\)\s*'"/>
    <xsl:variable name="RUNNING_FOOTER_REGEX" select="'\s*string\(\s*running-footer\s*\)\s*'"/>
    <xsl:variable name="BRAILLE_PAGE_REGEX" select="concat('\s*counter\(\s*braille-page\s*(,\s*(', $IDENT, ')\s*)?\)\s*')"/>
    
    <xsl:template match="/*">
        <xsl:variable name="page_stylesheet" as="xs:string" select="string(@css:page)"/>
        <xsl:variable name="margin-rulesets" as="xs:string*">
            <xsl:analyze-string select="$page_stylesheet" regex="{$RULESET}">
                <xsl:matching-substring>
                    <xsl:sequence select="."/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="other-declarations" as="xs:string*"
                      select="css:tokenize-declarations(replace($page_stylesheet, $RULESET, ''))"/>
        <xsl:variable name="size"
                      select="(for $declaration in css:filter-declaration($other-declarations, 'size')
                                return normalize-space(substring-after($declaration,':')))[matches(., $SIZE_REGEX)]"/>
        <xsl:variable name="top-right-content"     select="pxi:get-margin-content($margin-rulesets, '@top-right')"/>
        <xsl:variable name="bottom-right-content"  select="pxi:get-margin-content($margin-rulesets, '@bottom-right')"/>
        <xsl:variable name="top-center-content"    select="pxi:get-margin-content($margin-rulesets, '@top-center')"/>
        <xsl:variable name="bottom-center-content" select="pxi:get-margin-content($margin-rulesets, '@bottom-center')"/>
        <xsl:variable name="print-page-position"
                      select="if (matches($top-right-content, $PRINT_PAGE_REGEX)) then 'top-right'
                              else if (matches($bottom-right-content, $PRINT_PAGE_REGEX)) then 'bottom-right'
                              else 'none'"/>
        <xsl:variable name="braille-page-position"
                      select="if (matches($top-right-content, $BRAILLE_PAGE_REGEX)) then 'top-right'
                              else if (matches($bottom-right-content, $BRAILLE_PAGE_REGEX)) then 'bottom-right'
                              else 'none'"/>
        <xsl:element name="louis:page-layout">
            <xsl:element name="c:param-set">
                <xsl:element name="c:param">
                    <xsl:attribute name="name" select="'louis:page-width'"/>
                    <xsl:attribute name="value" select="if ($size) then tokenize($size, ' ')[1] else '40'"/>
                </xsl:element>
                <xsl:element name="c:param">
                    <xsl:attribute name="name" select="'louis:page-height'"/>
                    <xsl:attribute name="value" select="if ($size) then tokenize($size, ' ')[2] else '25'"/>
                </xsl:element>
                <xsl:element name="c:param">
                    <xsl:attribute name="name" select="'louis:print-page-position'"/>
                    <xsl:attribute name="value" select="$print-page-position"/>
                </xsl:element>
                <xsl:element name="c:param">
                    <xsl:attribute name="name" select="'louis:braille-page-position'"/>
                    <xsl:attribute name="value" select="$braille-page-position"/>
                </xsl:element>
                <xsl:if test="$braille-page-position!='none'">
                    <xsl:variable name="format"
                                  select="replace(if ($braille-page-position='top-right') then $top-right-content else $bottom-right-content,
                                                  concat('^.*', $BRAILLE_PAGE_REGEX, '.*$'), '$2')"/>
                    <xsl:element name="c:param">
                        <xsl:attribute name="name" select="'louis:braille-page-format'"/>
                        <xsl:attribute name="value">
                            <xsl:choose>
                                <xsl:when test="$format=('lower-roman','upper-roman')">
                                    <xsl:value-of select="'lower-roman'"/>
                                </xsl:when>
                                <xsl:when test="$format='prefix-p'">
                                    <xsl:value-of select="'prefix-p'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'decimal'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="c:param">
                    <xsl:attribute name="name" select="'louis:page-break-separator'"/>
                    <xsl:attribute name="value"
                                   select="if (//louis:print-page[@break='true'] and not(//louis:print-page[@break='false']))
                                           then 'true' else 'false'"/>
                </xsl:element>
                <xsl:element name="c:param">
                    <xsl:attribute name="name" select="'louis:running-header'"/>
                    <xsl:attribute name="value" select="if (matches($top-center-content, $RUNNING_HEADER_REGEX))
                                                        then 'true' else 'false'"/>
                </xsl:element>
                <xsl:element name="c:param">
                    <xsl:attribute name="name" select="'louis:running-footer'"/>
                    <xsl:attribute name="value" select="if (matches($bottom-center-content, $RUNNING_FOOTER_REGEX))
                                                        then 'true' else 'false'"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:function name="pxi:get-margin-content" as="xs:string">
        <xsl:param name="margin-rulesets" as="xs:string*"/>
        <xsl:param name="selector" as="xs:string"/>
        <xsl:sequence select="string(
                                for $declaration in css:filter-declaration(css:tokenize-declarations(
                                                      css:get-declarations($margin-rulesets, $selector)), 'content')
                                  return substring-after($declaration, ':'))"/>
    </xsl:function>
    
</xsl:stylesheet>
