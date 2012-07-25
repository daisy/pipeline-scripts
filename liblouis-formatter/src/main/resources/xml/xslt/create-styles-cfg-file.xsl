<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-result-prefixes="xs louis"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/">
        <xsl:call-template name="create-config-file">
            <xsl:with-param name="display-values" select="('block', 'list-item', 'toc')"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="create-config-file">
        
        <xsl:param name="display-values" as="xs:string*"/>
        <xsl:param name="toc-title-style" as="xs:string" select="''"/>
        <xsl:param name="toc-item-styles" as="xs:string*"/>
        
        <louis:config-file>
            <xsl:for-each select="//louis:style[@display]">
                
                <xsl:variable name="display" as="xs:string?" select="string(@display)"/>
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
                    
                    <xsl:variable name="text-align" as="xs:string" select="string(@text-align)"/>
                    <xsl:variable name="louis-abs-margin-left" as="xs:string" select="string(@louis-abs-margin-left)"/>
                    <xsl:variable name="louis-abs-margin-right" as="xs:string" select="string(@louis-abs-margin-right)"/>
                    <xsl:variable name="margin-top" as="xs:string" select="string(@margin-top)"/>
                    <xsl:variable name="margin-bottom" as="xs:string" select="string(@margin-bottom)"/>
                    <xsl:variable name="text-indent" as="xs:string" select="string(@text-indent)"/>
                    <xsl:variable name="page-break-before" as="xs:string" select="string(@page-break-before)"/>
                    <xsl:variable name="page-break-after" as="xs:string" select="string(@page-break-after)"/>
                    <xsl:variable name="page-break-inside" as="xs:string" select="string(@page-break-inside)"/>
                    <xsl:variable name="orphans" as="xs:string" select="string(@orphans)"/>
                    
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
                    
                    <xsl:if test="louis:is-numeric($louis-abs-margin-left)">
                        <xsl:value-of select="concat('   leftMargin ', louis:format-number($louis-abs-margin-left), '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- rightMargin -->
                    
                    <xsl:if test="louis:is-numeric($louis-abs-margin-right)">
                        <xsl:value-of select="concat('   rightMargin ', louis:format-number($louis-abs-margin-right), '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- linesBefore -->
                    
                    <xsl:if test="louis:is-numeric($margin-top)">
                        <xsl:value-of select="concat('   linesBefore ', louis:format-number($margin-top), '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- linesAfter -->
                    
                    <xsl:if test="louis:is-numeric($margin-bottom)">
                        <xsl:value-of select="concat('   linesAfter ', louis:format-number($margin-bottom), '&#xa;')"/>
                    </xsl:if>
                    
                    <!-- firstLineIndent -->
                    
                    <xsl:if test="louis:is-numeric($text-indent)">
                        <xsl:value-of select="concat('   firstLineIndent ', louis:format-number($text-indent), '&#xa;')"/>
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
                    
                    <xsl:if test="louis:is-numeric($orphans)">
                        <xsl:value-of select="concat('   orphanControl ', louis:format-number($orphans), '&#xa;')"/>
                    </xsl:if>
                    
                    <xsl:text>&#xa;</xsl:text>
                    
                </xsl:if>
            </xsl:for-each>
        </louis:config-file>
    </xsl:template>
    
    <xsl:function name="louis:is-numeric" as="xs:boolean">
        <xsl:param name="value"/>
        <xsl:sequence select="matches($value, '^(0|-?[1-9][0-9]*)(\.0*)?$')"/>
    </xsl:function>
    
    <xsl:function name="louis:format-number" as="xs:string">
        <xsl:param name="value"/>
        <xsl:sequence select="format-number(number($value), '0')"/>
    </xsl:function>
    
</xsl:stylesheet>