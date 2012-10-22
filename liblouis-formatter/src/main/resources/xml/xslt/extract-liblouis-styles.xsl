<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="xs louis css"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:output method="xml" encoding="UTF-8" indent="yes" name="louis-styles"/>
    
    <xsl:variable name="root" select="/*"/>
    <xsl:key name="style-string" match="//*[@style]" use="string(@style)"/>
    
    <xsl:function name="louis:generate-style-name" as="xs:string">
        <xsl:param name="style-string" as="xs:string" />
        <xsl:value-of select="generate-id($root/key('style-string', $style-string)[1])"/>
    </xsl:function>
    
    <xsl:template match="@style">
        <xsl:variable name="display" select="louis:get-property-value(., 'display')"/>
        <xsl:attribute name="louis:style"
            select="if ($display='none') then 'skip' else concat('#', louis:generate-style-name(string()))"/>
    </xsl:template>
    
    <xsl:template match="@louis:style">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/">
        <xsl:apply-templates/>
        <xsl:result-document href="louis-styles.xml" format="louis-styles">
            <louis:styles>
                <xsl:choose>
                    <xsl:when test="/louis:toc">
                        <xsl:for-each select="distinct-values(//*[@css:toc-item]/@style/string())">
                            <xsl:variable name="i" select="position()"/>
                            <xsl:if test="$i &lt;= 10">
                                <xsl:call-template name="print-liblouis-style">
                                    <xsl:with-param name="style" select="."/>
                                    <xsl:with-param name="style-name" select="concat('contents', $i)"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="distinct-values(//*[not(@css:toc-item)]/@style/string())">
                            <xsl:variable name="display" select="louis:get-property-value(., 'display')"/>
                            <xsl:if test="$display=('block','list-item','toc')">
                                <xsl:call-template name="print-liblouis-style">
                                    <xsl:with-param name="style" select="."/>
                                    <xsl:with-param name="style-name" select="louis:generate-style-name(.)"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </louis:styles>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="print-liblouis-style">
        <xsl:param name="style" as="xs:string"/>
        <xsl:param name="style-name" as="xs:string"/>
        
        <xsl:text># --------------------------------------------------------------------------------------------------&#xa;</xsl:text>
        <xsl:text># </xsl:text>
        <xsl:value-of select="$style"/>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text># --------------------------------------------------------------------------------------------------&#xa;</xsl:text>
        
        <xsl:text>style </xsl:text>
        <xsl:sequence select="$style-name"/>
        <xsl:text>&#xa;</xsl:text>
        
        <xsl:variable name="display" select="louis:get-property-value(., 'display')"/>
        <xsl:variable name="text-align" select="louis:get-property-value(., 'text-align')"/>
        <xsl:variable name="louis-abs-margin-left" select="louis:get-property-value(., 'louis-abs-margin-left')"/>
        <xsl:variable name="louis-abs-margin-right" select="louis:get-property-value(., 'louis-abs-margin-right')"/>
        <xsl:variable name="margin-top" select="louis:get-property-value(., 'margin-top')"/>
        <xsl:variable name="margin-bottom" select="louis:get-property-value(., 'margin-bottom')"/>
        <xsl:variable name="text-indent" select="louis:get-property-value(., 'text-indent')"/>
        <xsl:variable name="page-break-before" select="louis:get-property-value(., 'page-break-before')"/>
        <xsl:variable name="page-break-after" select="louis:get-property-value(., 'page-break-after')"/>
        <xsl:variable name="page-break-inside" select="louis:get-property-value(., 'page-break-inside')"/>
        <xsl:variable name="orphans" select="louis:get-property-value(., 'orphans')"/>
        
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
        
    </xsl:template>
    
    <xsl:function name="louis:get-property-value">
        <xsl:param name="style" as="xs:string"/>
        <xsl:param name="property-name" as="xs:string"/>
        <xsl:variable name="property-value" as="xs:string*">
            <xsl:if test="contains($style, $property-name)">
                <xsl:for-each select="tokenize($style,';')">
                    <xsl:if test="normalize-space(substring-before(.,':'))=$property-name">
                        <xsl:sequence select="normalize-space(substring-after(.,':'))"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        <xsl:sequence select="string($property-value[1])"/>
    </xsl:function>
    
    <xsl:function name="louis:is-numeric" as="xs:boolean">
        <xsl:param name="value"/>
        <xsl:sequence select="matches($value, '^(0|-?[1-9][0-9]*)(\.0*)?$')"/>
    </xsl:function>
    
    <xsl:function name="louis:format-number" as="xs:string">
        <xsl:param name="value"/>
        <xsl:sequence select="format-number(number($value), '0')"/>
    </xsl:function>
    
</xsl:stylesheet>
