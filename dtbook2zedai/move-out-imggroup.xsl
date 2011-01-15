<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd dtb" version="2.0">

    <xd:doc>
        <xd:desc>Move imggroup out a level and split the element that used to contain it. Description of the
        issues surrounding this transformation can be found here:
        http://code.google.com/p/daisy-pipeline/wiki/DTBook2ZedAI_imggroup</xd:desc>
        
    </xd:doc>

    <xsl:output indent="yes" method="xml"/>

    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- these are all the elements that need imggroup moved before they can be turned into ZedAI elements -->
    <xsl:template match="dtb:a | dtb:abbr | dtb:acronym | dtb:author | dtb:bdo | dtb:bridgehead | dtb:byline | 
        dtb:cite | dtb:dateline | dtb:dd | dtb:dfn | dtb:docauthor | dtb:doctitle | dtb:em | dtb:h1 | dtb:h2 |
        dtb:h3 | dtb:h4 | dtb:h5 | dtb:h6 | dtb:hd | dtb:line | dtb:linegroup | dtb:p | dtb:q | dtb:sent |
        dtb:span | dtb:strong | dtb:sub | dtb:sup | dtb:title | dtb:w">
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name">imggroup</xsl:with-param>
            <xsl:with-param name="split-into-elem" select="name()"/>
        </xsl:call-template>
    </xsl:template>
    
        
    <xsl:template name="move-elem-out">
        <xsl:param name="elem-name"/>
        <xsl:param name="split-into-elem"/>
        
        <!-- the element to split out: boolean(self::dtb:$elem-name) -->
        <!-- want to use this param in group-adjacent -->
        <xsl:param name="group-name">
            <!--<xsl:value-of select="concat(concat('boolean(', concat('self::dtb:', $elem-name)), ')')" />-->
            <xsl:value-of select="concat('self::dtb:', $elem-name)"/>
        </xsl:param>
        
        <!-- save the parent element -->
        <xsl:variable name="elem" select="."/>

        <xsl:choose>
            
            <xsl:when test="./dtb:imggroup">                
                <!-- move imggroup -->
                <xsl:for-each-group select="*|text()[normalize-space()]" group-adjacent="boolean($group-name)">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key()">
                            <xsl:element name="imggroup"
                                namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                <xsl:apply-templates select="@*"/>
                                <xsl:apply-templates/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- split the parent element -->
                            <xsl:element name="{name($elem)}"
                                namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                <xsl:apply-templates select="$elem/@*"/>
                                <xsl:apply-templates select="current-group()"/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:element name="{name($elem)}" namespace="http://www.daisy.org/z3986/2005/dtbook/">
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates/>                        
                </xsl:element>
            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
