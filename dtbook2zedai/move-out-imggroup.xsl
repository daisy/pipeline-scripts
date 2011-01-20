<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd dtb" version="2.0">

    <xd:doc>
        <xd:desc>Move imggroup out a level and split the element that used to contain it.
            Description of the issues surrounding this transformation can be found here:
            http://code.google.com/p/daisy-pipeline/wiki/DTBook2ZedAI_imggroup</xd:desc>

    </xd:doc>

    <xsl:output indent="yes" method="xml"/>

    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- TODO: review element groupings below -->

    <!-- these are all the elements that need imggroup moved before they can be turned into ZedAI elements -->
    <xsl:template
        match="dtb:a[dtb:imggroup] | dtb:abbr[dtb:imggroup] | dtb:acronym[dtb:imggroup] | dtb:author[dtb:imggroup] |
        dtb:bdo[dtb:imggroup] | dtb:bridgehead[dtb:imggroup] | dtb:byline[dtb:imggroup] | 
        dtb:cite[dtb:imggroup] | dtb:dateline[dtb:imggroup] | dtb:dd[dtb:imggroup] | dtb:dfn[dtb:imggroup] | dtb:docauthor[dtb:imggroup] | 
        dtb:doctitle[dtb:imggroup] | dtb:em[dtb:imggroup]  | dtb:line[dtb:imggroup] | 
        dtb:linegroup[dtb:imggroup] | dtb:p[dtb:imggroup] | dtb:q[dtb:imggroup] | dtb:sent[dtb:imggroup] |
        dtb:span[dtb:imggroup] | dtb:strong[dtb:imggroup] | dtb:sub[dtb:imggroup] | dtb:sup[dtb:imggroup] | dtb:title[dtb:imggroup] |
        dtb:w[dtb:imggroup]">
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name-to-move">imggroup</xsl:with-param>
            <xsl:with-param name="split-into-elem" select="local-name()"/>
        </xsl:call-template>
    </xsl:template>

    <!-- these elements have to be split into one instance of themselves and one or more instance of another block-level element;
         that is to say, there cannot be many of these elements as siblings to each other
    -->
    <xsl:template
        match="dtb:h1[dtb:imggroup] | dtb:h2[dtb:imggroup] |
        dtb:h3[dtb:imggroup] | dtb:h4[dtb:imggroup] | dtb:h5[dtb:imggroup] | dtb:h6[dtb:imggroup] | 
        dtb:hd[dtb:imggroup]">
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name-to-move">imggroup</xsl:with-param>
            <xsl:with-param name="split-into-elem" select="'p'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="move-elem-out">
        <xsl:param name="elem-name-to-move"/>
        <xsl:param name="split-into-elem"/>

        <!-- save the parent element -->
        <xsl:variable name="elem" select="."/>
        <xsl:variable name="first-child" select="child::node()[1]"/>
        <!-- move the element out a level -->
        <xsl:for-each-group select="*|text()[normalize-space()]"
            group-adjacent="local-name() = $elem-name-to-move">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:copy-of select="current-group()"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- split the parent element -->
                    <xsl:choose>
                        <!-- split into many of the same element -->
                        <xsl:when test="local-name($elem) = $split-into-elem">
                            <xsl:element name="{local-name($elem)}"
                                namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                <xsl:apply-templates select="$elem/@*"/>
                                <xsl:apply-templates select="current-group()"/>
                            </xsl:element>
                        </xsl:when>
                        <!-- split into a different element type than the original -->
                        <xsl:otherwise>
                            <xsl:choose>
                                <!-- for the first group, use the original element name -->
                                <xsl:when test="position() = 1 or local-name($first-child) = $elem-name-to-move">
                                    <xsl:element name="{local-name($elem)}"
                                        namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                        <xsl:apply-templates select="$elem/@*"/>
                                        <xsl:apply-templates select="current-group()"/>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:element name="{$split-into-elem}"
                                        namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                        <xsl:apply-templates select="$elem/@*"/>
                                        <xsl:apply-templates select="current-group()"/>
                                    </xsl:element>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>

    </xsl:template>
</xsl:stylesheet>
