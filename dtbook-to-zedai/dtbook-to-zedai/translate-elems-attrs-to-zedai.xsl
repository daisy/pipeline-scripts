<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:rend="http://www.daisy.org/ns/z3986/authoring/features/rend/"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    xmlns="http://www.daisy.org/ns/z3986/authoring/" exclude-result-prefixes="xs dtb">

    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>Direct translation element and attribute names from DTBook to ZedAI. Most of the work
            regarding content model normalization has already been done.</desc>
    </doc>
    
    <xsl:param name="css-filename"/>

    <xsl:output indent="yes" method="xml"/>

    <xsl:template match="/">
        <xsl:message>Translate to ZedAI</xsl:message>
        
        <!-- just for testing: insert the oxygen schema reference -->
        <!--<xsl:processing-instruction name="oxygen">
            <xsl:text>RNGSchema="../../schema/z3986a-book-0.8/z3986a-book.rng" type="xml"</xsl:text>
        </xsl:processing-instruction>-->
        <xsl:apply-templates/>
        <xsl:message>--Done</xsl:message>
    </xsl:template>

    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>

    <!-- a common set of attributes -->
    <xsl:template name="attrs">
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

    <xsl:template match="dtb:dtbook">
        <document xmlns:z3986="http://www.daisy.org/z3986/2011/vocab/decl/#"
            xmlns:dcterms="http://purl.org/dc/terms/"
            profile="http://www.daisy.org/z3986/2011/vocab/profiles/default/">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </document>
    </xsl:template>

    <xsl:template match="dtb:head">
        <head>
            <xsl:call-template name="attrs"/>
            <!-- hard-coding the zedai 'book' profile for dtbook transformation -->
            <meta rel="z3986:profile"
                resource="http://www.daisy.org/z3986/2011/auth/profiles/book/0.8/"/>
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
            <section xml:id="{generate-id()}">
                <xsl:apply-templates select="dtb:doctitle"/>
                <xsl:apply-templates select="dtb:covertitle"/>
                <xsl:apply-templates select="dtb:docauthor"/>
            </section>
            <xsl:apply-templates select="dtb:level"/>
            <xsl:apply-templates select="dtb:level1"/>
        </frontmatter>
    </xsl:template>

    <xsl:template match="dtb:docauthor">
        <p role="author">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="dtb:doctitle">
        <p role="title">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template
        match="dtb:level1|dtb:level2|dtb:level3|dtb:level4|dtb:level5|dtb:level6|dtb:level">
        <section>
            <xsl:call-template name="attrs"/>
            <!-- sections must have IDs since they might be referenced by floating annotations -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="xml:id" select="generate-id()"/>
            </xsl:if>
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


            <xsl:if test="@type = 'ul'">
                <xsl:attribute name="type">unordered</xsl:attribute>
            </xsl:if>
            <xsl:if test="@type = 'ol'">
                <xsl:attribute name="type">ordered</xsl:attribute>
            </xsl:if>
            <xsl:if test="@type = 'pl'">
                <!-- no attributes added for type='pl' -->
            </xsl:if>

            <xsl:apply-templates/>
        </list>
    </xsl:template>


    <xsl:template match="dtb:list/dtb:hd">
        <item>
            <hd>
                <xsl:call-template name="attrs"/>
                <xsl:apply-templates/>
            </hd>
        </item>
    </xsl:template>

    <xsl:template match="dtb:li">
        <item>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </item>
    </xsl:template>

    <xsl:template match="dtb:img">

        <!-- dtb @longdesc is a URI which resolves to a prodnote elsewhere the book -->
        <!-- zedai does not currently have a description equivalent to @alt/@longdesc, 
            however, it's an issue under consideration in the zedai group -->
        <object>
            <xsl:call-template name="attrs"/>
            <xsl:copy-of select="@src"/>

            <!-- height and width get put into CSS-->
            <xsl:if test="@height">
                <xsl:attribute name="tmp:height" select="@height"/>
            </xsl:if>
            <xsl:if test="@width">
                <xsl:attribute name="tmp:width" select="@width"/>
            </xsl:if>

            <!-- generate an ID for use by CSS -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="xml:id" select="generate-id()"/>
            </xsl:if>
            <description>
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

    <!-- use modes! -->
    <xsl:template match="dtb:caption" mode="table-caption">
        <xsl:param name="refValue"/>
        <caption>
            <xsl:if test="$refValue">
                <xsl:attribute name="ref" select="$refValue"/>
            </xsl:if>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates mode="#default"/>
        </caption>
    </xsl:template>

    <xsl:template match="dtb:caption" mode="#default">
        <xsl:param name="refValue"/>
        <caption>
            <xsl:choose>
                <xsl:when test="@imgref">
                    <xsl:attribute name="ref" select="replace(@imgref, '#', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="parent::dtb:imggroup">
                            <!-- get the id of the image in the imggroup and use it as a ref -->
                            <xsl:attribute name="ref" select="../dtb:img/@id"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </caption>
    </xsl:template>

    <xsl:template name="createAnnotation">
        <xsl:param name="byValue"/>
        <xsl:param name="refValue"/>
        <annotation>
            <xsl:if test="$byValue">
                <xsl:attribute name="by" select="$byValue"/>
            </xsl:if>

            <xsl:if test="$refValue">
                <xsl:attribute name="ref" select="$refValue"/>
            </xsl:if>
            
            <!-- at this point, annotations could still be "floating', i.e. not anchored to anything.  this will get fixed in another step.  -->

            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </annotation>
    </xsl:template>

    <xsl:template match="tmp:annotation-block | tmp:annotation-phrase">
        <xsl:call-template name="createAnnotation"/>
    </xsl:template>

    <xsl:template match="dtb:prodnote">

        <xsl:choose>
            <xsl:when test="@imgref">
                <xsl:call-template name="createAnnotation">
                    <xsl:with-param name="byValue" select="'republisher'"/>
                    <xsl:with-param name="refValue" select="replace(@imgref, '#', '')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="parent::dtb:imggroup">
                        <!-- get the id of the image in the imggroup and use it as a ref -->
                        <xsl:call-template name="createAnnotation">
                            <xsl:with-param name="byValue" select="'republisher'"/>
                            <xsl:with-param name="refValue" select="../dtb:img/@id"/>
                        </xsl:call-template>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:call-template name="createAnnotation">
                            <xsl:with-param name="byValue" select="'republisher'"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dtb:sidebar">
        <aside role="sidebar">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </aside>
    </xsl:template>

    <xsl:template match="dtb:note">

        <note>
            <xsl:call-template name="attrs"/>
            <xsl:choose>
                <xsl:when test="@class = 'footnote' or @class = 'endnote'">
                    <xsl:attribute name="role" select="@class"/>
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

    <xsl:template match="dtb:pagenum">
        <pagebreak value="{.}">
            <xsl:call-template name="attrs"/>
        </pagebreak>
    </xsl:template>

    <xsl:template match="dtb:noteref">
        <noteref ref="{replace(@idref, '#', '')}">
            <xsl:call-template name="attrs"/>
            <xsl:value-of select="."/>
        </noteref>
    </xsl:template>

    <xsl:template match="dtb:annoref">
        <annoref ref="{replace(@idref, '#', '')}">
            <xsl:call-template name="attrs"/>
            <xsl:value-of select="."/>
        </annoref>
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
        <!-- generate an ID in case we need it -->
        <xsl:variable name="tableID" select="generate-id()"/>

        <!-- in ZedAI, captions don't live inside tables as in DTBook -->
        <xsl:if test="./dtb:caption">
            <xsl:choose>
                <xsl:when test="@id">
                    <xsl:apply-templates mode="table-caption" select="./dtb:caption">
                        <xsl:with-param name="refValue" select="@id"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="table-caption" select="./dtb:caption">
                        <xsl:with-param name="refValue" select="$tableID"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

        <table>
            <!-- These will be put into CSS by a future XSL step -->
            <xsl:if test="@width">
                <xsl:attribute name="tmp:width" select="@width"/>
            </xsl:if>
            <xsl:if test="@border">
                <xsl:attribute name="tmp:border" select="@border"/>
            </xsl:if>
            <xsl:if test="@cellspacing">
                <xsl:attribute name="tmp:cellspacing" select="@cellspacing"/>
            </xsl:if>
            <xsl:if test="@cellpadding">
                <xsl:attribute name="tmp:cellpadding" select="@cellpadding"/>
            </xsl:if>

            <xsl:call-template name="attrs"/>

            <!-- generate an ID for use by CSS -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="xml:id" select="$tableID"/>
            </xsl:if>

            <xsl:for-each-group group-adjacent="local-name() = 'col'" select="*">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <colgroup>
                            <xsl:for-each select="current-group()">
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>
                        </colgroup>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="current-group()">
                            <xsl:if test="local-name() != 'caption'">
                                <xsl:apply-templates select="."/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </table>
    </xsl:template>

    <xsl:template match="dtb:col">
        <col>
            <xsl:call-template name="attrs"/>
            <xsl:copy-of select="@span"/>

            <!-- these will be put into a CSS file by a future XSL step -->
            <xsl:if test="@width">
                <xsl:attribute name="tmp:width" select="@width"/>
            </xsl:if>
            <xsl:if test="@align">
                <xsl:attribute name="tmp:align" select="@align"/>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="tmp:valign" select="@valign"/>
            </xsl:if>

            <!-- generate an ID for use by CSS -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="xml:id" select="generate-id()"/>
            </xsl:if>
            <xsl:apply-templates/>
        </col>
    </xsl:template>

    <xsl:template match="dtb:colgroup">
        <colgroup>
            <xsl:call-template name="attrs"/>

            <!-- ignore @span if there are any col children (this is what the DTBook DTD states, and it also maps nicely to ZedAI) -->
            <xsl:if test="not(./dtb:col)">
                <xsl:copy-of select="@span"/>
            </xsl:if>

            <!-- these will be put into a CSS file by a future XSL step -->
            <xsl:if test="@width">
                <xsl:attribute name="tmp:width" select="@width"/>
            </xsl:if>
            <xsl:if test="@align">
                <xsl:attribute name="tmp:align" select="@align"/>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="tmp:valign" select="@valign"/>
            </xsl:if>
            <!-- generate an ID for use by CSS -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="xml:id" select="generate-id()"/>
            </xsl:if>
            <xsl:apply-templates/>
        </colgroup>
    </xsl:template>

    <xsl:template match="dtb:thead">
        <thead>
            <xsl:call-template name="attrs"/>

            <!-- these will be put into a CSS file by a future XSL step -->
            <xsl:if test="@align">
                <xsl:attribute name="tmp:align" select="@align"/>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="tmp:valign" select="@valign"/>
            </xsl:if>
            <!-- generate an ID for use by CSS -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="xml:id" select="generate-id()"/>
            </xsl:if>
            <xsl:apply-templates/>
        </thead>
    </xsl:template>

    <xsl:template match="dtb:tfoot">
        <tfoot>
            <xsl:call-template name="attrs"/>

            <!-- these will be put into a CSS file by a future XSL step -->
            <xsl:if test="@align">
                <xsl:attribute name="tmp:align" select="@align"/>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="tmp:valign" select="@valign"/>
            </xsl:if>
            <!-- generate an ID for use by CSS -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="xml:id" select="generate-id()"/>
            </xsl:if>
            <xsl:apply-templates/>
        </tfoot>
    </xsl:template>

    <xsl:template match="dtb:tbody">
        <tbody>
            <xsl:call-template name="attrs"/>

            <!-- these will be put into a CSS file by a future XSL step -->
            <xsl:if test="@align">
                <xsl:attribute name="tmp:align" select="@align"/>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="tmp:valign" select="@valign"/>
            </xsl:if>
            <!-- generate an ID for use by CSS -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="xml:id" select="generate-id()"/>
            </xsl:if>
            <xsl:apply-templates/>
        </tbody>
    </xsl:template>

    <xsl:template match="dtb:tr">
        <tr>
            <xsl:call-template name="attrs"/>

            <!-- these will be put into a CSS file by a future XSL step -->
            <xsl:if test="@align">
                <xsl:attribute name="tmp:align" select="@align"/>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="tmp:valign" select="@valign"/>
            </xsl:if>
            <!-- generate an ID for use by CSS -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="xml:id" select="generate-id()"/>
            </xsl:if>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="dtb:th">
        <th>
            <xsl:call-template name="attrs"/>
            <xsl:copy-of select="@abbr"/>
            <xsl:copy-of select="@headers"/>
            <xsl:copy-of select="@colspan"/>
            <xsl:copy-of select="@rowspan"/>
            <xsl:copy-of select="@scope"/>

            <!-- these will be put into a CSS file by a future XSL step -->
            <xsl:if test="@align">
                <xsl:attribute name="tmp:align" select="@align"/>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="tmp:valign" select="@valign"/>
            </xsl:if>
            <!-- generate an ID for use by CSS -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="xml:id" select="generate-id()"/>
            </xsl:if>

            <xsl:apply-templates/>
        </th>
    </xsl:template>

    <xsl:template match="dtb:td">
        <td>
            <xsl:call-template name="attrs"/>

            <xsl:copy-of select="@headers"/>
            <xsl:copy-of select="@colspan"/>
            <xsl:copy-of select="@rowspan"/>
            <xsl:copy-of select="@scope"/>

            <!-- these will be put into a CSS file by a future XSL step -->
            <xsl:if test="@align">
                <xsl:attribute name="tmp:align" select="@align"/>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="tmp:valign" select="@valign"/>
            </xsl:if>
            <!-- generate an ID for use by CSS -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="xml:id" select="generate-id()"/>
            </xsl:if>
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:template match="dtb:byline">
        <!-- for most book (non-article) use cases, byline can be citation. the exception would be anthologies, for which we can call upon the periodicals vocab
            and actually use "role = byline".  for now, we will use just 1 vocabulary in this converter -->
        <citation>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </citation>
    </xsl:template>

    <xsl:template match="dtb:sent">

        <s>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </s>
    </xsl:template>

    <xsl:template match="dtb:address">
        <block>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </block>
    </xsl:template>

    <xsl:template match="dtb:epigraph">
        <block role="epigraph">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </block>
    </xsl:template>

    <xsl:template match="dtb:dateline">
        <p role="time">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="tmp:ln">
        <ln>
            <xsl:apply-templates/>
        </ln>
    </xsl:template>

    <xsl:template match="dtb:br">
        <!-- discard any br elements left after running convert-br-to-ln.xsl -->
    </xsl:template>

    <xsl:template match="dtb:cite">
        <!-- generate an ID, we might need it -->
        <xsl:variable name="citeID" select="generate-id()"/>
        <citation>
            <xsl:call-template name="attrs"/>

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
        </citation>
    </xsl:template>


    <xsl:template match="dtb:covertitle">
        <block role="covertitle">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </block>
    </xsl:template>



    <xsl:template match="dtb:acronym">
        <abbr>
            <!-- making an assumption: @pronounce has a default value of 'no' -->
            <xsl:choose>
                <xsl:when test="@pronounce = 'yes'">
                    <xsl:attribute name="role">acronym</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="role">initialism</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </abbr>
    </xsl:template>

    <!-- link elements live in the head of dtbook documents; there seems to be no zedai equivalent (chances are, whatever they reference is not relevant in a zedai world anyway) -->
    <xsl:template match="dtb:link"/>

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

        <abbr role="truncation">
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
            <!-- normalization steps sometimes put role='example' on some spans, so be sure to copy it -->
            <xsl:if test="@role">
                <xsl:copy-of select="@role"/>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="dtb:w">
        <w>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </w>
    </xsl:template>

    <xsl:template
        match="tmp:annotation-block/dtb:linegroup | dtb:caption/dtb:linegroup | dtb:level/dtb:linegroup | 
        dtb:level1/dtb:linegroup | dtb:level2/dtb:linegroup | dtb:level3/dtb:linegroup | dtb:level4/dtb:linegroup | 
        dtb:level5/dtb:linegroup | dtb:level6/dtb:linegroup | dtb:td/dtb:linegroup | dtb:prodnote/dtb:linegroup | 
        dtb:sidebar/dtb:linegroup | dtb:th/dtb:linegroup | dtb:poem/dtb:linegroup">

        <block>
            <xsl:call-template name="attrs"/>
            <xsl:for-each-group group-adjacent="local-name() = 'line'" select="*">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <p>
                            <xsl:for-each select="current-group()">
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>
                        </p>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="current-group()">
                            <xsl:apply-templates select="."/>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </block>

    </xsl:template>


    <xsl:template match="dtb:line">
        <ln>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </ln>
    </xsl:template>

    <!-- any samp elements left at this point will be block-level, since nested samps were made into spans in earlier steps -->
    <xsl:template match="dtb:samp">

        <block role="example">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </block>
    </xsl:template>

    <xsl:template match="dtb:dfn">
        <term>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </term>
    </xsl:template>

    <xsl:template match="dtb:a">
        <ref>
            <xsl:if test="@href">
                <xsl:choose>
                    <xsl:when test="@external='true'">
                        <xsl:attribute name="xlink:href" select="@href"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="ref" select="replace(@href, '#', '')"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:if>
            <xsl:copy-of select="@rev"/>
            <xsl:copy-of select="@rel"/>

            <xsl:apply-templates/>

        </ref>
    </xsl:template>

    <xsl:template match="dtb:dl">
        <!-- assumption: definition lists are unordered -->
        <list type="unordered">
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </list>
    </xsl:template>

    <xsl:template match="tmp:item">
        <item>
            <xsl:apply-templates/>
        </item>
    </xsl:template>

    <xsl:variable name="definition-list-block-elems"
        select="tokenize('list,dl,div,poem,linegroup,table,sidebar,note,epigraph', ',')"/>

    <xsl:template match="dtb:dd">
        <xsl:choose>
            <!-- when it has a block-level sibling, wrap in a p element -->
            <xsl:when
                test="preceding-sibling::*/local-name() = $definition-list-block-elems or 
                following-sibling::*/local-name() = $definition-list-block-elems">
                <p>
                    <definition>
                        <xsl:call-template name="attrs"/>
                        <xsl:apply-templates/>
                    </definition>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <definition>
                    <xsl:call-template name="attrs"/>
                    <xsl:apply-templates/>
                </definition>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dtb:dt">
        <xsl:choose>
            <!-- when it has a block-level sibling, wrap in a p element -->
            <xsl:when
                test="preceding-sibling::*/local-name() = $definition-list-block-elems or 
                following-sibling::*/local-name() = $definition-list-block-elems">
                <p>
                    <term>
                        <xsl:call-template name="attrs"/>
                        <xsl:apply-templates/>
                    </term>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <term>
                    <xsl:call-template name="attrs"/>
                    <xsl:apply-templates/>
                </term>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dtb:linenum">
        <lnum>
            <xsl:call-template name="attrs"/>
            <xsl:apply-templates/>
        </lnum>
    </xsl:template>

    <!-- TODO: why not @property for title & author like citation elem uses? -->
    <xsl:template match="dtb:poem">
        <block role="poem">
            <xsl:for-each-group group-adjacent="local-name() = 'line'" select="*">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <p>
                            <xsl:for-each select="current-group()">
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>
                        </p>

                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="current-group()">
                            <xsl:choose>
                                <xsl:when test="local-name() = 'title'">
                                    <p role="title">
                                        <xsl:call-template name="attrs"/>
                                        <xsl:apply-templates/>
                                    </p>
                                </xsl:when>

                                <xsl:when test="local-name() = 'author'">
                                    <p role="author">
                                        <xsl:call-template name="attrs"/>
                                        <xsl:apply-templates/>
                                    </p>
                                </xsl:when>

                                <xsl:otherwise>
                                    <xsl:apply-templates select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>

                    </xsl:otherwise>
                </xsl:choose>

            </xsl:for-each-group>

        </block>
    </xsl:template>


    <xsl:template match="tmp:code-block">
        <code>
            <xsl:call-template name="attrs"/>
            <xsl:variable name="wrap-in-p"
                select="tokenize('em,strong,dfn,cite,abbr,acronym,a,sub,sup,span,bdo,w,annoref,noteref,sent,code-phrase',',')"/>
            <!-- is there ever a nested code-block ... ? -->
            <xsl:variable name="wrap-in-block" select="tokenize('code-block,q,prodnote',',')"/>
            <!-- TODO: wrap text too -->
            <xsl:for-each-group group-adjacent="local-name() = $wrap-in-p" select="*">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <p>
                            <xsl:for-each select="current-group()">
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>
                        </p>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="current-group()">
                            <xsl:choose>
                                <xsl:when test="local-name() = $wrap-in-block">
                                    <block>
                                        <xsl:apply-templates select="."/>
                                    </block>
                                </xsl:when>
                                <xsl:when test="local-name() = 'br'">
                                    <!-- explicitly ignore linebreaks when treating code as a group of block-level items -->
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:otherwise>

                </xsl:choose>
            </xsl:for-each-group>
        </code>

    </xsl:template>

    <xsl:template match="tmp:code-phrase">
        <code>
            <xsl:call-template name="attrs"/>
            <xsl:for-each select="child::node()">
                <xsl:choose>

                    <xsl:when test="local-name() = 'abbr'">
                        <span role="truncation">
                            <xsl:call-template name="attrs"/>
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>

                    <xsl:when test="local-name() = 'acronym'">
                        <span>
                            <xsl:choose>
                                <xsl:when test="@pronounce = 'yes'">
                                    <xsl:attribute name="role">acronym</xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="role">initialism</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:call-template name="attrs"/>
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>
                    <xsl:when test="local-name() = 'br'">
                        <!-- TODO -->
                    </xsl:when>

                    <xsl:when test="local-name() = 'em' or local-name() = 'strong'">
                        <xsl:apply-templates select="."/>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:apply-templates select="."/>
                    </xsl:otherwise>

                </xsl:choose>
            </xsl:for-each>
        </code>

    </xsl:template>
</xsl:stylesheet>
