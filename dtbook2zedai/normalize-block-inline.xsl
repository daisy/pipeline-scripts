<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    exclude-result-prefixes="dtb" version="2.0">

    <!--Normalizes mixed block/inline content models.-->

    <xsl:output indent="yes" method="xml"/>

    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template
        match="dtb:annotation | dtb:div | dtb:prodnote | dtb:note | dtb:epigraph | dtb:li | dtb:th | dtb:caption | dtb:sidebar |
        dtb:address | dtb:covertitle | dtb:samp | dtb:td">

        <xsl:copy>

            <xsl:apply-templates select="@*"/>

            <!-- these tests represent a superset of inline and block elements of the elements that this template matches -->
            <xsl:variable name="hasInline"
                select="./dtb:a or ./dtb:abbr or ./dtb:acronym or ./dtb:annoref or ./dtb:bdo or ./dtb:dfn or
            ./dtb:em or ./dtb:line or ./dtb:noteref or ./dtb:sent or ./dtb:span or ./dtb:strong or ./dtb:sub or 
            ./dtb:sub or ./dtb:w or ./dtb:br or ./text()"/>

            <xsl:variable name="hasBlock"
                select="./dtb:code or ./dtb:samp or ./dtb:kbd or ./dtb:cite or ./dtb:img or ./dtb:imggroup or ./dtb:pagenum or
            dtb:prodnote or ./dtb:p or ./dtb:list or ./dtb:dl or ./dtb:div or ./dtb:linegroup or ./dtb:byline or ./dtb:dateline or ./dtb:epigraph or
            dtb:table or ./dtb:address or ./dtb:author or ./dtb:prodnote or ./dtb:sidebar or ./dtb:note or ./dtb:annotation or ./dtb:doctitle or 
            ./dtb:docauthor or
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


    <!-- zedai section elements must contain all block element children, so transform any inlines into blocks -->
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

    <!-- take the context element's children and wrap any inlines in p elements -->
    <xsl:template name="blockize">

        <xsl:for-each select="node()">
            <xsl:choose>

                <!-- inline elements get wrapped in a p element-->
                <xsl:when
                    test="local-name() = 'a' or local-name() = 'abbr' or local-name() = 'acronym' or 
                    local-name() = 'annoref' or local-name() = 'bdo' or 
                    local-name() = 'blockquote' or local-name() = 'br' or local-name() = 'dfn' or 
                    local-name() = 'em' or local-name() = 'line' or local-name() = 'noteref' or local-name() = 'q' or 
                    local-name() = 'sent' or local-name() = 'span' or local-name() = 'strong' or local-name() = 'sub' or 
                    local-name() = 'sub' or local-name() = 'w'">

                    <xsl:element name="p" namespace="http://www.daisy.org/z3986/2005/dtbook/">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                    </xsl:element>

                </xsl:when>

                <!-- trim text and wrap in a p element -->
                <xsl:when
                    test="self::text() and string-length(self::text()[normalize-space()]) &gt; 0">
                    <xsl:element name="p" namespace="http://www.daisy.org/z3986/2005/dtbook/">
                        <xsl:copy/>
                        <!-- TODO: should we trim the text here? -->
                    </xsl:element>
                </xsl:when>

                <!-- whitespace -->
                <xsl:when test="self::text() and string-length(self::text()[normalize-space()]) = 0">
                    <!-- TODO: ok to discard whitespace?-->
                </xsl:when>

                <!-- all other elements must be block, so just copy them -->
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="@*|node()"/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

    </xsl:template>
    
    

</xsl:stylesheet>
