<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output method="text" encoding="UTF-8" name="styles-cfg-output"/>
    <xsl:output method="text" encoding="UTF-8" name="styles-sem-output"/>
    
    <xsl:param name="styles-cfg-output-uri" as="xs:string" />
    <xsl:param name="styles-sem-output-uri" as="xs:string" />
        
    <xsl:variable name="this" select="document('')/xsl:stylesheet" />
    
    <xsl:variable name="supported-property-names" as="xs:string*"
        select="('text-align',
                 'margin-left',
                 'margin-right',
                 'margin-top',
                 'margin-bottom',
                 'text-indent',
                 'page-break-before',
                 'page-break-after',
                 'page-break-inside',
                 'orphans')"/>
    
    <xsl:variable name="INTEGER_NUMBER" select="'^(0|-?[1-9][0-9]*)$'"/>
    <xsl:variable name="NATURAL_NUMBER" select="'^(0|[1-9][0-9]*)$'"/>
    <xsl:variable name="POSITIVE_NUMBER" select="'^([1-9][0-9]*)$'"/>
    
    <xsl:variable name="supported-property-values" as="xs:string*"
        select="('^(left|right|center)$',
                 $NATURAL_NUMBER,
                 $NATURAL_NUMBER,
                 $POSITIVE_NUMBER,
                 $POSITIVE_NUMBER,
                 $INTEGER_NUMBER,
                 '^(always|right)$',
                 '^(always|avoid)$',
                 '^avoid$',
                 $POSITIVE_NUMBER)"/>
    
    <xsl:variable name="liblouisxml-property-names" as="xs:string*"
        select="('format',
                 'leftMargin',
                 'rightMargin',
                 'linesBefore',
                 'linesAfter',
                 'firstLineIndent',
                 '?',
                 '?',
                 'dontSplit',
                 'orphanControl')"/>

    <xsl:template match="/">
        
        <!-- Configuration file -->
        
        <xsl:result-document href="{$styles-cfg-output-uri}" format="styles-cfg-output">
            <xsl:for-each select="//brl:style">
                <xsl:value-of select="@name"/>
                <xsl:text>&#xa;</xsl:text>
                <xsl:for-each select="@*[name()!='name']">
                    <xsl:variable name="property-name" select="name(.)"/>
                    <xsl:variable name="property-value" select="string(.)"/>
                    <xsl:variable name="index" select="index-of($supported-property-names, $property-name)"/>
                    <xsl:if test="$index and matches($property-value, $supported-property-values[$index])">
                        <xsl:variable name="liblouisxml-name">
                            <xsl:choose>
                                <xsl:when test="$liblouisxml-property-names[$index]!='?'">
                                    <xsl:value-of select="$liblouisxml-property-names[$index]"/>
                                </xsl:when>
                                <xsl:when test="$property-name='page-break-before'">
                                    <xsl:choose>
                                        <xsl:when test="$property-value='always'">
                                            <xsl:value-of select="'newPageBefore'"/>
                                        </xsl:when>
                                        <xsl:when test="$property-value='right'">
                                            <xsl:value-of select="'rightHandPage'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$property-name='page-break-after'">
                                    <xsl:choose>
                                        <xsl:when test="$property-value='always'">
                                            <xsl:value-of select="'newPageAfter'"/>
                                        </xsl:when>
                                        <xsl:when test="$property-value='avoid'">
                                            <xsl:value-of select="'keepWithNext'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="liblouisxml-value">
                            <xsl:choose>
                                <xsl:when test="$supported-property-values[$index]=$INTEGER_NUMBER
                                             or $supported-property-values[$index]=$NATURAL_NUMBER
                                             or $supported-property-values[$index]=$POSITIVE_NUMBER">
                                    <xsl:value-of select="$property-value"/>
                                </xsl:when>
                                <xsl:when test="$property-name='text-align'">
                                    <xsl:choose>
                                        <xsl:when test="$property-value='left'">
                                            <xsl:value-of select="'leftJustified'"/>
                                        </xsl:when>
                                        <xsl:when test="$property-value='right'">
                                            <xsl:value-of select="'rightJustified'"/>
                                        </xsl:when>
                                        <xsl:when test="$property-value='center'">
                                            <xsl:value-of select="'centered'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$property-name='page-break-before'
                                             or $property-name='page-break-after'
                                             or $property-name='page-break-inner'">
                                    <xsl:value-of select="'yes'"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:text>   </xsl:text>
                        <xsl:value-of select="$liblouisxml-name"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$liblouisxml-value"/>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
        
        <!-- Semantic action file -->
        
        <xsl:result-document href="{$styles-sem-output-uri}" format="styles-sem-output">
            <xsl:text>namespaces brl=</xsl:text>
            <xsl:value-of select="$this/namespace::brl"/>
            <xsl:text>&#xa;&#xa;</xsl:text>
            <xsl:for-each select="//brl:style">
                <xsl:value-of select="@name"/>
                <xsl:text> xpath(//*[@brl:style='#</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>'])&#xa;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>