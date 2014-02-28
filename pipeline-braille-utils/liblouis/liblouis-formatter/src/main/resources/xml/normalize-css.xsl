<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="xs louis css"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:variable name="liblouis-properties" as="xs:string*"
        select="('left',
                 'right',
                 'margin-top',
                 'margin-bottom',
                 'text-align',
                 'text-indent',
                 'page-break-before',
                 'page-break-after',
                 'page-break-inside',
                 'orphans')"/>
    
    <xsl:variable name="liblouis-defaults" as="xs:string*"
        select="('inherit',
                 'inherit',
                 '0.0',
                 '0.0',
                 'inherit',
                 'inherit',
                 'auto',
                 'auto',
                 'auto',
                 '0.0')"/>
    
    <xsl:template match="@*|text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="louis:border|
                         louis:line|
                         louis:print-page|
                         louis:running-header|
                         louis:running-footer|
                         louis:page-layout">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:variable name="this" as="element()" select="."/>
        <xsl:variable name="display" as="xs:string" select="(@css:display,'inline')[1]"/>
        <xsl:variable name="declarations" as="xs:string*">
            <xsl:for-each select="$liblouis-properties">
                <xsl:variable name="i" select="position()"/>
                <xsl:variable name="value" as="xs:string?">
                    <xsl:apply-templates select="$this" mode="property">
                        <xsl:with-param name="property" select="."/>
                        <xsl:with-param name="display" select="$display" tunnel="yes"/>
                        <xsl:with-param name="liblouis-default" select="$liblouis-defaults[$i]" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:if test="$value">
                    <xsl:sequence select="concat(., ': ', $value)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name()='style')]"/>
            <xsl:if test="exists($declarations)">
                <xsl:attribute name="style" select="string-join($declarations, '; ')"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" as="xs:string?" mode="property">
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="display" as="xs:string" select="'inline'" tunnel="yes"/>
        <xsl:param name="liblouis-default" as="xs:string" select="'inherit'" tunnel="yes"/>
        <xsl:param name="concretize-inherit" as="xs:boolean" select="false()" tunnel="yes"/>
        <xsl:if test="css:applies-to($property, $display)">
            <xsl:variable name="concretize-inherit" as="xs:boolean"
                          select="$concretize-inherit or $liblouis-default!='inherit'"/>
            <xsl:variable name="include-default" as="xs:boolean"
                          select="$liblouis-default!=css:get-default-value($property)"/>
            <xsl:variable name="value" as="xs:string?"
                          select="css:get-value(., $property, $concretize-inherit, $include-default, true())"/>
            <xsl:if test="$value and $value!=$liblouis-default">
                <xsl:sequence select="$value"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="louis:box" as="xs:string?" mode="property" priority="0.6">
        <xsl:param name="property" as="xs:string"/>
        <xsl:next-match>
            <xsl:with-param name="property" select="$property"/>
            <xsl:with-param name="display" select="'block'" tunnel="yes"/>
            <xsl:with-param name="concretize-inherit" select="true()" tunnel="yes"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="*[ancestor-or-self::louis:box]" as="xs:string?" mode="property" priority="0.7">
        <xsl:param name="property" as="xs:string"/>
        <xsl:if test="not($property=$css:paged-media-properties)">
            <xsl:next-match>
                <xsl:with-param name="property" select="$property"/>
            </xsl:next-match>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
