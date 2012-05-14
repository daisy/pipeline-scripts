<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="no"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/style-functions.xsl" />
    
    <xsl:variable name="INTEGER_NUMBER" select="'^(0|-?[1-9][0-9]*)$'"/>
    <xsl:variable name="NATURAL_NUMBER" select="'^(0|[1-9][0-9]*)$'"/>
    <xsl:variable name="POSITIVE_NUMBER" select="'^[1-9][0-9]*$'"/>

    <xsl:template match="/">
        
        <lblxml:config-file>
            <xsl:for-each select="//brl:style">
                <xsl:variable name="display" as="xs:string" select="brl:get-property-or-default(.,'display')"/>
                <xsl:if test="$display='block' or $display='list-item'">
                    <xsl:text>style </xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>&#xa;</xsl:text>
                    
                    <xsl:variable name="text-align" as="xs:string" select="brl:get-property-or-default(.,'text-align')"/>
                    <xsl:variable name="margin-left" as="xs:string" select="brl:get-property-or-default(.,'margin-left')"/>
                    <xsl:variable name="margin-right" as="xs:string" select="brl:get-property-or-default(.,'margin-right')"/>
                    <xsl:variable name="margin-top" as="xs:string" select="brl:get-property-or-default(.,'margin-top')"/>
                    <xsl:variable name="margin-bottom" as="xs:string" select="brl:get-property-or-default(.,'margin-bottom')"/>
                    <xsl:variable name="padding-top" as="xs:string" select="brl:get-property-or-default(.,'padding-top')"/>
                    <xsl:variable name="padding-bottom" as="xs:string" select="brl:get-property-or-default(.,'padding-bottom')"/>
                    <xsl:variable name="text-indent" as="xs:string" select="brl:get-property-or-default(.,'text-indent')"/>
                    <xsl:variable name="page-break-before" as="xs:string" select="brl:get-property-or-default(.,'page-break-before')"/>
                    <xsl:variable name="page-break-after" as="xs:string" select="brl:get-property-or-default(.,'page-break-after')"/>
                    <xsl:variable name="page-break-inside" as="xs:string" select="brl:get-property-or-default(.,'page-break-inside')"/>
                    <xsl:variable name="orphans" as="xs:string" select="brl:get-property-or-default(.,'orphans')"/>
                    
                    <!-- format -->
                    
                    <xsl:variable name="format" as="xs:string?">
                        <xsl:choose>
                            <xsl:when test="$text-align='left'">
                                <xsl:value-of select="'leftJustified'"/>
                            </xsl:when>
                            <xsl:when test="$text-align='right'">
                                <xsl:value-of select="'rightJustified'"/>
                            </xsl:when>
                            <xsl:when test="$text-align='center'">
                                <xsl:value-of select="'centered'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:if test="$format">
                        <xsl:value-of select="concat('   format ', $format, '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- leftMargin -->
                    
                    <xsl:if test="matches($margin-left, $INTEGER_NUMBER)">
                        <xsl:value-of select="concat('   leftMargin ', $margin-left, '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- rightMargin -->
                    
                    <xsl:if test="matches($margin-right, $INTEGER_NUMBER)">
                        <xsl:value-of select="concat('   rightMargin ', $margin-right, '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- linesBefore -->
                    
                    <xsl:variable name="linesBefore" as="xs:string"
                        select="format-number(number($margin-top) + number($padding-top), '0')"/>
                    <xsl:if test="matches($linesBefore, $POSITIVE_NUMBER)">
                        <xsl:value-of select="concat('   linesBefore ', $linesBefore, '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- linesAfter -->
                    
                    <xsl:variable name="linesAfter" as="xs:string"
                        select="format-number(number($margin-bottom) + number($padding-bottom), '0')"/>
                    <xsl:if test="matches($linesAfter, $POSITIVE_NUMBER)">
                        <xsl:value-of select="concat('   linesAfter ', $linesAfter, '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- firstLineIndent -->
                    
                    <xsl:if test="matches($text-indent, $INTEGER_NUMBER)">
                        <xsl:value-of select="concat('   firstLineIndent ', $text-indent, '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- newPageBefore -->
                    
                    <xsl:if test="$page-break-before='always'">
                        <xsl:value-of select="concat('   newPageBefore ', 'yes', '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- newPageAfter -->
                    
                    <xsl:if test="$page-break-after='always'">
                        <xsl:value-of select="concat('   newPageAfter ', 'yes', '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- rightHandPage -->
                    
                    <xsl:if test="$page-break-before='right'">
                        <xsl:value-of select="concat('   rightHandPage ', 'yes', '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- dontSplit -->
                    
                    <xsl:if test="$page-break-inside='avoid'">
                        <xsl:value-of select="concat('   dontSplit ', 'yes', '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- keepWithNext -->
                    <!-- FIXME: 'avoid page-break after' not entirely the same as 'keep with next sibling' -->
                    
                    <xsl:if test="$page-break-after='avoid'">
                        <xsl:value-of select="concat('   keepWithNext ', 'yes', '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- orphanControl -->
                    
                    <xsl:if test="matches($orphans, $POSITIVE_NUMBER)">
                        <xsl:value-of select="concat('   orphanControl ', $orphans, '&#xa;')"/>
                    </xsl:if>
                    
                    <xsl:text>&#xa;</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </lblxml:config-file>
    </xsl:template>
    
</xsl:stylesheet>