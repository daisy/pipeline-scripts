<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd dtb" version="2.0">

    <xd:doc>
        <xd:desc>This stylesheet maps certain DTBook elements to a ZedAI block-or-inline content model.</xd:desc>
    </xd:doc>


    <!-- 
        
        Note: linegroup is a potential child element of some of the elements here.  It will have to be moved out, but since that's such a common case, 
        it might be handled separately.  It is not handled here.
        
    -->

    <xsl:output indent="yes" method="xml"/>

    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template
        match="dtb:annotation | dtb:div | dtb:prodnote | dtb:note | dtb:epigraph | dtb:li | dtb:th | dtb:caption | dtb:sidebar |
        dtb:address | dtb:covertitle | dtb:samp"
         >

        <xsl:copy>

            <xsl:apply-templates select="@*"/>

            <!-- these tests represent a superset of inline and block elements of the elements that this template matches -->
            <xsl:variable name="hasInline"
                select="./dtb:a or ./dtb:abbr or ./dtb:acronym or ./dtb:annoref or ./dtb:bdo or ./dtb:dfn or
            ./dtb:em or ./dtb:line or ./dtb:noteref or ./dtb:sent or ./dtb:span or ./dtb:strong or ./dtb:sub or 
            ./dtb:sub or ./dtb:w or ./text()"/>

            <xsl:variable name="hasBlock"
                select="./dtb:code or ./dtb:samp or ./dtb:kbd or ./dtb:cite or ./dtb:img or ./dtb:imggroup or ./dtb:br or ./dtb:pagenum or
            dtb:prodnote or ./dtb:p or ./dtb:list or ./dtb:dl or ./dtb:div or ./dtb:linegroup or ./dtb:byline or ./dtb:dateline or ./dtb:epigraph or
            dtb:table or ./dtb:address or ./dtb:author or ./dtb:prodnote or ./dtb:sidebar or ./dtb:note or ./dtb:annotation or ./dtb:doctitle or ./dtb:docauthor or
            dtb:covertitle or ./dtb:bridgehead"/>

            <xsl:choose>
                <!-- when there is a mix of block and inline children, we have to wrap the inlines in a block -->
                <xsl:when test="$hasInline and $hasBlock">
                    <xsl:call-template name="blockize"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:copy>
    </xsl:template>

    <xsl:template
        match="dtb:level1 | dtb:level2 | dtb:level3 | dtb:level4 | dtb:level5 | dtb:level6">

        <xsl:copy>

            <xsl:apply-templates select="@*"/>


            <xsl:variable name="hasInline"
                select="./dtb:a or ./dtb:abbr or ./dtb:acronym or ./dtb:annoref or ./dtb:bdo or ./dtb:dfn or
            ./dtb:em or ./dtb:line or ./dtb:noteref or ./dtb:sent or ./dtb:span or ./dtb:strong or ./dtb:sub or 
            ./dtb:sub or ./dtb:w"/>

            <xsl:choose>
                <xsl:when test="$hasInline">
                    <xsl:call-template name="blockize"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:copy>

    </xsl:template>
    
    <xsl:template name="blockize">
        <!-- TODO: also need to wrap text() in para elements. -->
        <xsl:for-each select="child::node()|text()">
            <xsl:choose>
                <xsl:when
                    test="name() = 'a' or name() = 'abbr' or name() = 'acronym' or name() = 'annoref' or name() = 'bdo' or 
                    name() = 'blockquote' or name() = 'dfn' or name() = 'em' or name() = 'line' or name() = 'noteref' or name() = 'q' or 
                    name() = 'sent' or name() = 'span' or name() = 'strong' or name() = 'sub' or name() = 'sub' or name() = 'w'">

                    <p>
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:apply-templates/>
                        </xsl:copy>
                    </p>


                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
           
        </xsl:for-each>
    </xsl:template>
    <!-- 
No adjustments required for these elements, although they fall into the same content model:

dtbook:img (empty) ==> object-block
dtbook:imggroup (prodnote, img, caption, pagenum) ==> block

-->

</xsl:stylesheet>
