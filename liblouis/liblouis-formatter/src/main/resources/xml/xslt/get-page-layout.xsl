<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    exclude-result-prefixes="xs css c louis"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl" />
    
    <xsl:variable name="pages" select="collection()[2]"/>
    
    <xsl:variable name="SIZE_REGEX" select="concat('^', $NATURAL_NUMBER, '\s', $NATURAL_NUMBER, '$')"/>
    <xsl:variable name="PRINT_PAGE_REGEX" select="'string\(\s*print-page\s*\)'"/>
    <xsl:variable name="BRAILLE_PAGE_REGEX" select="concat('counter\(\s*braille-page\s*(,\s*', $IDENT, '\s*)?\)')"/>
    
    <xsl:template match="/*">
        <xsl:variable name="page-name" select="css:get-property-value(., 'page', true(), true(), false())"/>
        <xsl:variable name="page"
            select="$pages/css:pages/css:page[not(@position)]
                        [string(@name)=$page-name or (not(@name) and $page-name='auto')][1]"/>
        <xsl:variable name="size"
            select="(for $property in tokenize($page/@style, ';')
                         [normalize-space(substring-before(.,':'))='size']
                       return normalize-space(substring-after($property,':'))
                    )[matches(., $SIZE_REGEX)][1]"/>
        <xsl:variable name="top-right-content"
            select="(for $property in tokenize($page/css:top-right[1]/@style, ';')
                         [normalize-space(substring-before(.,':'))='content']
                       return normalize-space(substring-after($property,':'))
                    )[1]"/>
        <xsl:variable name="bottom-right-content"
            select="(for $property in tokenize($page/css:bottom-right[1]/@style, ';')
                         [normalize-space(substring-before(.,':'))='content']
                       return normalize-space(substring-after($property,':'))
                    )[1]"/>
        <xsl:variable name="print-page-position"
            select="if (matches($top-right-content, $PRINT_PAGE_REGEX)) then 'top-right'
                    else if (matches($bottom-right-content, $PRINT_PAGE_REGEX)) then 'bottom-right'
                    else 'none'"/>
        <xsl:variable name="braille-page-position"
            select="if (matches($top-right-content, $BRAILLE_PAGE_REGEX)) then 'top-right'
                    else if (matches($bottom-right-content, $BRAILLE_PAGE_REGEX)) then 'bottom-right'
                    else 'none'"/>
        <xsl:element name="c:param-set">
            <xsl:element name="c:param">
                <xsl:attribute name="name" select="'page-width'"/>
                <xsl:attribute name="value" select="if ($size) then tokenize($size, '\s+')[1] else '40'"/>
            </xsl:element>
            <xsl:element name="c:param">
                <xsl:attribute name="name" select="'page-height'"/>
                <xsl:attribute name="value" select="if ($size) then tokenize($size, '\s+')[2] else '25'"/>
            </xsl:element>
            <xsl:element name="c:param">
                <xsl:attribute name="name" select="'print-page-position'"/>
                <xsl:attribute name="value" select="$print-page-position"/>
            </xsl:element>
            <xsl:element name="c:param">
                <xsl:attribute name="name" select="'braille-page-position'"/>
                <xsl:attribute name="value" select="$braille-page-position"/>
            </xsl:element>
            <xsl:if test="$braille-page-position!='none'">
                <xsl:variable name="format"
                    select="replace(if ($braille-page-position='top-right') then $top-right-content
                                    else $bottom-right-content,
                                concat('^.*', $BRAILLE_PAGE_REGEX, '.*$'), '$1')"/>
                <xsl:element name="c:param">
                    <xsl:attribute name="name" select="'braille-page-format'"/>
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
                <xsl:attribute name="name" select="'page-break-separator'"/>
                <xsl:attribute name="value"
                    select="if (//louis:print-page[@break='true'] and not(//louis:print-page[@break='false']))
                              then 'true' else 'false'"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
