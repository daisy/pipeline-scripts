<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:its="http://www.w3.org/2005/11/its" 
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output indent="yes" method="xml"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- transform these elements to spans so that they will be normalized as if they were spans
        this works for elements with dtbook inline content models.
    -->

   <xsl:template match="dtb:lic">
       <xsl:message>LIC</xsl:message>
       <xsl:call-template name="element2span"/>
   </xsl:template>
    
    <xsl:template match="dtb:dd/dtb:p | dtb:dd/dtb:address">
        <xsl:call-template name="element2span"/>
    </xsl:template>
    <xsl:template match="dtb:dd/dtb:dateline">
        <span role="time">
            <xsl:call-template name="copy-attrs"/>
        </span>
    </xsl:template>
    <xsl:template match="dtb:dd/dtb:author">
        <span role="author">
            <xsl:call-template name="copy-attrs"/>
        </span>
    </xsl:template>
    
    <xsl:template match="dtb:abbr/dtb:code | dtb:acronym/dtb:code | dtb:dt/dtb:code | 
        dtb:sub/dtb:code | dtb:sup/dtb:code | dtb:w/dtb:code">
        <xsl:call-template name="element2span"/>
    </xsl:template>

    <xsl:template
        match="dtb:abbr/dtb:noteref | dtb:acronym/dtb:noteref | dtb:dt/dtb:noteref | 
        dtb:sub/dtb:noteref | dtb:sup/dtb:noteref | dtb:w/dtb:noteref">
        <!-- TODO: warn about loss of data -->
        <xsl:call-template name="element2span"/>
    </xsl:template>

    <xsl:template
        match="dtb:abbr/dtb:annoref | dtb:acronym/dtb:annoref | dtb:dt/dtb:annoref | 
        dtb:sub/dtb:annoref | dtb:sup/dtb:annoref | dtb:w/dtb:annoref">
        <!-- TODO: warn about loss of data -->
        <xsl:call-template name="element2span"/>
    </xsl:template>

    <xsl:template
        match="dtb:abbr/dtb:kbd | dtb:acronym/dtb:kbd | dtb:dt/dtb:kbd | 
        dtb:sub/dtb:kbd | dtb:sup/dtb:kbd | dtb:w/dtb:kbd">
        <xsl:call-template name="element2span"/>
    </xsl:template>
    

    <xsl:template match="dtb:abbr/dtb:q | dtb:acronym/dtb:q | dtb:dt/dtb:q | 
        dtb:sub/dtb:q | dtb:sup/dtb:q | dtb:w/dtb:q | dtb:strong/dtb:q">
        <xsl:call-template name="element2span"/>
    </xsl:template>

    <xsl:template match="dtb:abbr/dtb:sent | dtb:acronym/dtb:sent | dtb:dt/dtb:sent | 
        dtb:sub/dtb:sent | dtb:sup/dtb:sent">
        <span role="sentence">
            <xsl:call-template name="copy-attrs"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="dtb:sub/dtb:acronym | dtb:sup/dtb:acronym | dtb:w/dtb:acronym">
        <span>
            <xsl:choose>
                <xsl:when test="@pronounce = 'yes'">
                    <xsl:attribute name="role">acronym</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="role">initialism</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="copy-attrs"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="dtb:sub/dtb:abbr | dtb:sup/dtb:abbr | dtb:w/dtb:abbr">
        <span role="truncation">
            <xsl:call-template name="copy-attrs"/>
            <xsl:apply-templates/>    
        </span>
        
    </xsl:template>
    
    <xsl:template match="dtb:sub/dtb:w | dtb:sup/dtb:w">
        <span role="word">
            <xsl:call-template name="copy-attrs"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="dtb:a/dtb:samp | dtb:abbr/dtb:samp | dtb:acronym/dtb:samp | 
        dtb:author/dtb:samp | dtb:bdo/dtb:samp | dtb:bridgehead/dtb:samp | 
        dtb:byline/dtb:samp | 
        dtb:cite/dtb:samp | dtb:dateline/dtb:samp | dtb:dd/dtb:samp | dtb:dfn/dtb:samp | 
        dtb:dt/dtb:samp | 
        dtb:docauthor/dtb:samp | dtb:doctitle/dtb:samp | dtb:em/dtb:samp | dtb:h1/dtb:samp |
        dtb:h2/dtb:samp | dtb:h3/dtb:samp | dtb:h4/dtb:samp | dtb:h5/dtb:samp | 
        dtb:h6/dtb:samp | dtb:hd/dtb:samp | 
        dtb:line/dtb:samp | dtb:p/dtb:samp | dtb:q/dtb:samp | dtb:samp/dtb:samp | 
        dtb:sent/dtb:samp | dtb:span/dtb:samp | dtb:strong/dtb:samp | dtb:sub/dtb:samp |
        dtb:sup/dtb:samp | 
        dtb:title/dtb:samp | dtb:w/dtb:samp">
                <span role="example">
                    <xsl:call-template name="copy-attrs"/>
                    <xsl:apply-templates/>
                </span>
    </xsl:template>
    
    <xsl:template
        match="dtb:abbr/dtb:dfn | dtb:acronym/dtb:dfn | dtb:dt/dtb:dfn | 
        dtb:sub/dtb:dfn | dtb:sup/dtb:dfn | dtb:w/dtb:dfn">
        <xsl:call-template name="element2span"/>
    </xsl:template>
    
    <xsl:template
        match="dtb:abbr/dtb:a | dtb:acronym/dtb:a | dtb:dt/dtb:a | dtb:sub/dtb:a | 
        dtb:sup/dtb:a | dtb:w/dtb:a">
        <!-- TODO: warn about loss of data -->
        <xsl:call-template name="element2span"/>
    </xsl:template>
    
    <xsl:template match="dtb:bdo">
        <span its:dir="{@dir}">
            <xsl:call-template name="copy-attrs"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    
    <!-- TODO: check if we should check <em> too -->
    <!-- TODO: why did we use @property and not @role?  -->
    <xsl:template match="dtb:abbr/dtb:cite | dtb:acronym/dtb:cite | 
        dtb:dt/dtb:cite | dtb:sub/dtb:cite | dtb:sup/dtb:cite | dtb:w/dtb:cite | 
        dtb:strong/dtb:cite">
        <!-- generate an ID, we might need it -->
        <xsl:variable name="citeID" select="generate-id()"/>

        <span>
            <xsl:call-template name="copy-attrs"/>
            <!-- if no ID, then give a new ID -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="xml:id" select="$citeID"/>
            </xsl:if>
            
            <xsl:for-each select="child::node()">
                
                <xsl:choose>
                    <xsl:when test="local-name() = 'title'">
                        <span property="title">
                            <xsl:attribute name="about">
                                <xsl:choose>
                                    <xsl:when test="parent::node()/@id">
                                        <xsl:value-of select="parent::node()/@id"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$citeID"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>
                    <xsl:when test="local-name() = 'author'">
                        <span property="author">
                            <xsl:attribute name="about">
                                <xsl:choose>
                                    <xsl:when test="parent::node()/@id">
                                        <xsl:value-of select="parent::node()/@id"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$citeID"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </span>
    </xsl:template>

    <!-- change nested samps to spans -->
    <xsl:template match="dtb:samp[dtb:samp]">
        <xsl:element name="samp" namespace="http://www.daisy.org/z3986/2005/dtbook/">
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="local-name() = 'samp'">
                        <xsl:element name="span" namespace="http://www.daisy.org/z3986/2005/dtbook/">
                            <xsl:attribute name="role">example</xsl:attribute>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!-- generic conversion to span; no roles applied and no special treatment of child elements -->
    <xsl:template name="element2span">
        <span>
            <xsl:call-template name="copy-attrs"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template name="copy-attrs">
        <xsl:if test="@id">
            <xsl:attribute name="xml:id" select="@id"/>
        </xsl:if>
        <xsl:copy-of select="@xml:space"/>
        <xsl:copy-of select="@class"/>
        <xsl:copy-of select="@xml:lang"/>
        <xsl:if test="@dir">
            <xsl:attribute name="its:dir" select="@dir"/>
        </xsl:if>

    </xsl:template>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
