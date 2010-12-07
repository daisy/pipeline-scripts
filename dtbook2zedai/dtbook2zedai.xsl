<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:rend="http://www.daisy.org/ns/z3986/authoring/features/rend/"
    xmlns:its="http://www.w3.org/2005/11/its" 
    xmlns="http://www.daisy.org/ns/z3986/authoring/">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Aug 16, 2010</xd:p>
            <xd:p><xd:b>Author:</xd:b> marisa</xd:p>
            <xd:p>Take as input a dtbook 2005-3 document and produce zedai</xd:p>
        </xd:desc>
    </xd:doc>

    
    <xsl:output method="xml"/>

    <xsl:template match="/">
        <!-- just for testing: insert the oxygen stylesheet -->
        <!-- this way, the oxygen editor validates.  however, this doesn't mean much until you save the document, because it's a relative path.
            so, when the main xproc's p:store step gets sorted out, then this will be meaningful -->
        <xsl:processing-instruction name="oxygen">
            <xsl:text>RNGSchema="./schema/zedai_bookprofile_v0.7/z3986a-book.rng" type="xml"</xsl:text>
        </xsl:processing-instruction>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="dtb:dtbook">
        <!-- convenience: use the same dublin core namespace as dtbook documents use -->
        <document 
            xmlns:z3986="http://www.daisy.org/z3986/2011/vocab/decl/#"           
            xmlns:dc="http://purl.org/dc/terms/"
            profile="http://www.daisy.org/z3986/2011/vocab/profiles/default/">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </document>
    </xsl:template>


    <!-- a common set of attributes -->
    <xsl:template name="attrs">
        <xsl:copy-of select="@name"/>
        <xsl:copy-of select="@dir"/>
        <xsl:if test="@id">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="@xml:space"/>
        <xsl:copy-of select="@class"/>
        <xsl:copy-of select="@xml:lang"/>
        <xsl:if test="@dir">
            <xsl:attribute name="its:dir">
                <xsl:value-of select="@dir"/>
            </xsl:attribute>
        </xsl:if>
        
        <!-- TODO: @title: defined as a core attribute in dtbook; does not exist in zedai -->
        
    </xsl:template>

    <xsl:template match="dtb:head">
        <head>
            <xsl:call-template name="attrs"/>
            
            <!-- TODO: is it ok to hard-code the zedai 'book' profile for dtbook transformation? -->
            <meta rel="z3986:profile"
                resource="http://www.daisy.org/z3986/2011/auth/profiles/book/0.7/"/>

            <!-- TODO: import namespaces for non-DC metadata items -->
            <xsl:for-each select="dtb:meta">
                <meta property="{@name}" content="{@content}"/>
            </xsl:for-each>

        </head>

    </xsl:template>

    <xsl:template match="dtb:book">
        <body>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </body>
    </xsl:template>

    <xsl:template match="dtb:frontmatter">
        <frontmatter>
            <xsl:call-template name="attrs"/>
            <section>
                <xsl:apply-templates select="dtb:doctitle"/>
                <xsl:apply-templates select="dtb:covertitle"/>
                <xsl:apply-templates select="dtb:docauthor"/>
            </section>
            <xsl:apply-templates/>
        </frontmatter>
    </xsl:template>

    <xsl:template match="dtb:docauthor">
        <p property="dc:author">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="dtb:doctitle">
        <h property="dc:title">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </h>
    </xsl:template>

    <xsl:template
        match="dtb:level1|dtb:level2|dtb:level3|dtb:level4|dtb:level5|dtb:level6|dtb:level">
        <section>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </section>
    </xsl:template>


    <xsl:template match="dtb:h1|dtb:h2|dtb:h3|dtb:h4|dtb:h5|dtb:h6">
        <h>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </h>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="dtb:bridgehead|dtb:hd">
        <hd>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </hd>
    </xsl:template>

    <xsl:template match="dtb:em|dtb:strong">
        <emph>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </emph>
    </xsl:template>

    <xsl:template match="dtb:list">
        <list>
            <xsl:call-template name="attrs"/>

            <xsl:copy-of select="@start"/>
            <xsl:copy-of select="@depth"/>

            <xsl:if test="@enum = '1'">
                <xsl:attribute name="rend:prefix">decimal</xsl:attribute>
            </xsl:if>
            <xsl:if test="@enum = 'a'">
                <xsl:attribute name="rend:prefix">lower-alpha</xsl:attribute>
            </xsl:if>
            <xsl:if test="@enum = 'A'">
                <xsl:attribute name="rend:prefix">upper-alpha</xsl:attribute>
            </xsl:if>
            <xsl:if test="@enum = 'i'">
                <xsl:attribute name="rend:prefix">lower-roman</xsl:attribute>
            </xsl:if>
            <xsl:if test="@enum = 'I'">
                <xsl:attribute name="rend:prefix">upper-roman</xsl:attribute>
            </xsl:if>

            <xsl:if test="@type = 'pl'">
                <xsl:attribute name="rend:prefix">none</xsl:attribute>
            </xsl:if>
            <xsl:if test="@type = 'ul'">
                <xsl:attribute name="type">unordered</xsl:attribute>
            </xsl:if>
            <xsl:if test="@type = 'ol'">
                <xsl:attribute name="type">ordered</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>

        </list>
    </xsl:template>

    <xsl:template match="dtb:li">
        <item>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </item>
    </xsl:template>

    <xsl:template match="dtb:img">
        <object>
            <xsl:call-template name="attrs"/>
            <xsl:copy-of select="@src"/>
            <!-- TODO:  @height, @width; not found in ZedAI -->
            <!-- dtb @longdesc is a URI which resolves to a prodnote elsewhere the book -->
            <!-- zedai does not currently have a description equivalent to @alt/@longdesc, so this 'short' value is made-up
                 however, it's an issue under consideration in the zedai group -->
            <description role="short">
                <xsl:value-of select="@alt"/>
            </description>
        </object>
    </xsl:template>

    <xsl:template match="dtb:imggroup">
        <block>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </block>
    </xsl:template>

    <xsl:template match="dtb:caption">
        <xsl:choose>
            <xsl:when test="@imgref">
                <caption ref="{@imgref}">
                    <xsl:call-template name="attrs"/>
                    <xsl:apply-templates/>
                </caption>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="parent::imggroup">
                        <!-- get the id of the image in the imggroup and use it as a ref -->
                        <caption ref="{../dtb:img/@id}">
                            <xsl:call-template name="attrs"/>
                            <xsl:apply-templates/>
                        </caption>
                    </xsl:when>

                    <xsl:otherwise>
                        <caption>
                            <xsl:call-template name="attrs"/>
                            <xsl:apply-templates/>
                        </caption>
                    </xsl:otherwise>

                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="dtb:annotation">
        <annotation>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </annotation>
    </xsl:template>

    <xsl:template match="dtb:prodnote">
        <!-- TODO: translate attribute @render = required | optional -->
        <xsl:choose>
            <xsl:when test="@imgref">
                <annotation by="republisher" ref="{@imgref}">
                    <xsl:call-template name="attrs"/>
                    <xsl:apply-templates/>
                </annotation>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="parent::imggroup">
                        <!-- get the id of the image in the imggroup and use it as a ref -->
                        <annotation by="republisher" ref="{../dtb:img/@id}">
                            <xsl:call-template name="attrs"/>
                            <xsl:apply-templates/>
                        </annotation>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <annotation by="republisher">
                            <xsl:call-template name="attrs"/>
                            <xsl:apply-templates/>
                        </annotation>
                    </xsl:otherwise>
                    
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dtb:sidebar">
        <aside role="sidebar">
            <!-- TODO: translate attribute @render = required | optional -->
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </aside>
    </xsl:template>

    <xsl:template match="dtb:note">
        <note>
            <xsl:call-template name="attrs"/>
            <xsl:choose>
                <xsl:when test="@class = 'footnote' or @class = 'endnote'">
                    <xsl:attribute name="role">
                        <xsl:value-of select="@class"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:when>
            </xsl:choose>
        </note>
    </xsl:template>


    <xsl:template match="dtb:div">
        <block>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </block>
    </xsl:template>

    <xsl:template match="dtb:code">
        <code>
            <xsl:call-template name="attrs"/>
        </code>
    </xsl:template>

    <xsl:template match="dtb:pagenum">
        <pagebreak value="{.}">
            <xsl:call-template name="attrs"/>
            <!-- TODO: @page: normal | front | special -->
        </pagebreak>
    </xsl:template>

    <xsl:template match="dtb:noteref|dtb:annoref">
        <noteref ref="{@idref}">
            <!-- TODO: @type -->
            <xsl:call-template name="attrs"/>
            <xsl:value-of select="."/>
        </noteref>
    </xsl:template>


    <xsl:template match="dtb:blockquote|dtb:q">
        <quote>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </quote>
    </xsl:template>

    <xsl:template match="dtb:rearmatter">
        <backmatter>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </backmatter>
    </xsl:template>

    <xsl:template match="dtb:table">
        <table>
            <!-- TODO: @summary, @width, @border, @frame, @rules, @cellspacing, @cellpadding -->
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </table>
    </xsl:template>

    <xsl:template match="dtb:col">
        <col>
            <xsl:call-template name="attrs"/>
            <!-- TODO: @align, @valign, @span, @width -->
            <xsl:apply-templates/>
        </col>
    </xsl:template>

    <xsl:template match="dtb:colgroup">
        <colgroup>
            <xsl:call-template name="attrs"/>
            <!-- TODO: @align, @valign, @span, @width -->
            <xsl:apply-templates/>
        </colgroup>
    </xsl:template>

    <xsl:template match="dtb:thead">
        <thead>
            <xsl:call-template name="attrs"/>
            <!-- TODO: @align, @valign -->
            <xsl:apply-templates/>
        </thead>
    </xsl:template>

    <xsl:template match="dtb:tfoot">
        <tfoot>
            <xsl:call-template name="attrs"/>
            <!-- TODO: @align, @valign -->
            <xsl:apply-templates/>
        </tfoot>
    </xsl:template>

    <xsl:template match="dtb:tbody">
        <tbody>
            <xsl:call-template name="attrs"/>
            <!-- TODO: @align, @valign -->
            <xsl:apply-templates/>
        </tbody>
    </xsl:template>

    <xsl:template match="dtb:tr">
        <tr>
            <xsl:call-template name="attrs"/>
            <!-- TODO: @align, @valign -->
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="dtb:th">
        <th>
            <xsl:call-template name="attrs"/>
            <!-- TODO: @align, @valign, @abbr, @axis, @headers, @scope, @rowspan, @colspan -->
            <xsl:apply-templates/>
        </th>
    </xsl:template>

    <xsl:template match="dtb:td">
        <td>
            <xsl:call-template name="attrs"/>
            <!-- TODO: @align, @valign, @abbr, @axis, @headers, @scope, @rowspan, @colspan -->
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:template match="dtb:byline">
        <p role="other-credits">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="dtb:sent">
        <s>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </s>
    </xsl:template>
   
    <xsl:template match="dtb:address">
        <!-- TODO: deal with dtb:address/dtb:line -->
        <!-- TODO: no "address" role in ZedAI -->
        <block role="address">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </block>
    </xsl:template>
    
    <xsl:template match="dtb:epigraph">
        <!-- TODO: check attrs -->
        <block role="epigraph">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </block>
    </xsl:template>
    
    <xsl:template match="dtb:dateline">
        <ln>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </ln>
    </xsl:template>
    
    <xsl:template match="dtb:br">
        <separator/>
    </xsl:template>
    
    <xsl:template match="dtb:cite">
        <citation>
            <xsl:call-template name="attrs"/>
            <xsl:if test="./title">
                <span role="title">
                    <xsl:value-of select="./title"/>
                </span>
            </xsl:if>
        </citation>
    </xsl:template>
    
    <xsl:template match="dtb:covertitle">
        <block role="covertitle">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </block>
    </xsl:template>
    
    <xsl:template match="bdo">
        <span its:dir="@dir">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="acronym">
        <abbr type="acronym">
            <!-- TODO: @pronounce -->
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </abbr>
    </xsl:template>
   
    <!-- link elements live in the head of dtbook documents; there seems to be no zedai equivalent (chances are, whatever they reference is not relevant in a zedai world anyway -->
    <xsl:template match="dtb:link"/>
    
    <!-- these are all of the same form: copy the dtbook element name and copy the translated attributes -->
    <!-- they could probably be condensed in the future but I'm leaving them like this for now -->
    <xsl:template match="dtb:bodymatter">
        <bodymatter>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </bodymatter>
    </xsl:template>

    <xsl:template match="dtb:p">
        <p>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <xsl:template match="dtb:abbr">
        <abbr>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </abbr>
    </xsl:template>

    <xsl:template match="dtb:sup">
        <sup>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>

    <xsl:template match="dtb:sub">
        <sub>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </sub>
    </xsl:template>

    <xsl:template match="dtb:span">
        <span>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="dtb:w">
        <w>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </w>
    </xsl:template>
    <!-- end of elements that follow the same form -->
    
    
</xsl:stylesheet>
