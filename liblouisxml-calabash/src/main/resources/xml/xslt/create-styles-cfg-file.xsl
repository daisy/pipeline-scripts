<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    exclude-result-prefixes="xs brl lblxml"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="no"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/style-functions.xsl" />
    
    <xsl:variable name="INTEGER_NUMBER" select="'^(0|-?[1-9][0-9]*)(\.0*)?$'"/>
    <xsl:variable name="NATURAL_NUMBER" select="'^(0|[1-9][0-9]*)(\.0*)?$'"/>
    <xsl:variable name="POSITIVE_NUMBER" select="'^[1-9][0-9]*(\.0*)?$'"/>

    <xsl:template match="/">
        <xsl:call-template name="create-config-file">
            <xsl:with-param name="display-values" select="('block', 'list-item', 'toc')"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="create-config-file">
        
        <xsl:param name="display-values" as="xs:string*"/>
        <xsl:param name="toc-title-style" as="xs:string" select="''"/>
        <xsl:param name="toc-item-styles" as="xs:string*"/>
        
        <lblxml:config-file>
            <xsl:for-each select="//brl:style">
                
                <xsl:variable name="display" as="xs:string" select="brl:get-property-or-default(.,'display')"/>
                <xsl:variable name="style-name" as="xs:string?">
                    <xsl:if test="index-of($display-values, $display)">
                        <xsl:choose>
                            <xsl:when test="$display='toc-title'">
                                <xsl:if test="concat('#', @name)=$toc-title-style">
                                    <xsl:sequence select="'contentsheader'"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="$display='toc-item'">
                                <xsl:variable name="index" select="index-of($toc-item-styles, concat('#', @name))" as="xs:integer?"/>
                                <xsl:if test="$index">
                                    <xsl:if test="$index &gt; 0 and $index &lt;= 10">
                                        <xsl:sequence select="concat('contents', $index)"/>
                                    </xsl:if>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="string(@name)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:variable>
                
                <xsl:if test="$style-name">
                    
                    <xsl:text>style </xsl:text>
                    <xsl:sequence select="$style-name"/>
                    <xsl:text>&#xa;</xsl:text>
                    
                    <xsl:variable name="text-align" as="xs:string" select="brl:get-property-or-default(.,'text-align')"/>
                    <xsl:variable name="margin-left-absolute" as="xs:string" select="brl:get-property-or-default(.,'margin-left-absolute')"/>
                    <xsl:variable name="margin-right-absolute" as="xs:string" select="brl:get-property-or-default(.,'margin-right-absolute')"/>
                    <xsl:variable name="margin-top" as="xs:string" select="brl:get-property-or-default(.,'margin-top')"/>
                    <xsl:variable name="margin-bottom" as="xs:string" select="brl:get-property-or-default(.,'margin-bottom')"/>
                    <xsl:variable name="text-indent" as="xs:string" select="brl:get-property-or-default(.,'text-indent')"/>
                    <xsl:variable name="page-break-before" as="xs:string" select="brl:get-property-or-default(.,'page-break-before')"/>
                    <xsl:variable name="page-break-after" as="xs:string" select="brl:get-property-or-default(.,'page-break-after')"/>
                    <xsl:variable name="page-break-inside" as="xs:string" select="brl:get-property-or-default(.,'page-break-inside')"/>
                    <xsl:variable name="orphans" as="xs:string" select="brl:get-property-or-default(.,'orphans')"/>
                    
                    <!-- format -->
                    
                    <xsl:variable name="format" as="xs:string?">
                        <xsl:choose>
                            <xsl:when test="$display='toc-item'">
                                <xsl:value-of select="'contents'"/>
                            </xsl:when>
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
                    
                    <xsl:if test="matches($margin-left-absolute, $NATURAL_NUMBER)">
                        <xsl:value-of select="concat('   leftMargin ', format-number(number($margin-left-absolute), '0'), '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- rightMargin -->
                    
                    <xsl:if test="matches($margin-right-absolute, $NATURAL_NUMBER)">
                        <xsl:value-of select="concat('   rightMargin ', format-number(number($margin-right-absolute), '0'), '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- linesBefore -->
                    
                    <xsl:if test="matches($margin-top, $POSITIVE_NUMBER)">
                        <xsl:value-of select="concat('   linesBefore ', format-number(number($margin-top), '0'), '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- linesAfter -->
                    
                    <xsl:if test="matches($margin-bottom, $POSITIVE_NUMBER)">
                        <xsl:value-of select="concat('   linesAfter ', format-number(number($margin-bottom), '0'), '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- firstLineIndent -->
                    
                    <xsl:if test="matches($text-indent, $INTEGER_NUMBER)">
                        <xsl:value-of select="concat('   firstLineIndent ', format-number(number($text-indent), '0'), '&#xa;')"/>
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
                        <xsl:value-of select="concat('   orphanControl ', format-number(number($orphans), '0'), '&#xa;')"/>
                    </xsl:if>
                    
                    <xsl:text>&#xa;</xsl:text>
                    
                </xsl:if>
            </xsl:for-each>
        </lblxml:config-file>
    </xsl:template>
    
</xsl:stylesheet>