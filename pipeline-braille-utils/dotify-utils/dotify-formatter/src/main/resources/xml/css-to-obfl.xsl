<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/ns/2011/obfl"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0" >
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl" />
    
    <xsl:include href="generate-obfl-layout-master.xsl"/>
    
    <xsl:param name="braille-translator-query" as="xs:string" required="yes"/>
    <xsl:param name="duplex" as="xs:string" required="yes"/>
    
    <xsl:key name="page-stylesheet" match="/*[not(@css:flow)]" use="string(@css:page)"/>
    
    <xsl:function name="pxi:generate-layout-master-name" as="xs:string">
        <xsl:param name="page-stylesheet" as="xs:string"/>
        <xsl:variable name="elem" as="element()" select="(collection()[not(@css:flow)]/key('page-stylesheet', $page-stylesheet))[1]"/>
        <xsl:sequence select="generate-id($elem)"/>
    </xsl:function>
    
    <xsl:function name="pxi:generate-layout-master" as="element()">
        <xsl:param name="page-stylesheet" as="xs:string"/>
        <xsl:variable name="elem" as="element()" select="(collection()/*[not(@css:flow)]/key('page-stylesheet', $page-stylesheet))[1]"/>
        <xsl:sequence select="obfl:generate-layout-master(
                                $elem/string(@css:page),
                                pxi:generate-layout-master-name($page-stylesheet),
                                $duplex='true')"/>
    </xsl:function>
    
    <!--
        Based on a sequence of @volume rules, return a sequence of "use-when" expressions for which
        each volume is quaranteed to match exactly one of them. Should in theory not be needed
        because volume templates are matched in the order they appear.
    -->
    <xsl:function name="obfl:volume-stylesheets-use-when" as="xs:string*">
        <xsl:param name="stylesheets" as="element()*"/>
        <xsl:for-each select="$stylesheets">
            <xsl:variable name="i" select="position()"/>
            <xsl:choose>
                <xsl:when test="not(@selector)">
                    <xsl:sequence select="obfl:not(obfl:or($stylesheets[position()&lt;$i or @selector]/obfl:volume-stylesheets-use-when(.)))"/>
                </xsl:when>
                <xsl:when test="@selector=':first'">
                    <xsl:sequence select="obfl:and((
                                            '(= $volume 1)',
                                            obfl:not(obfl:or($stylesheets[position()&lt;$i and @selector]/obfl:volume-stylesheets-use-when(.)))))"/>
                </xsl:when>
                <xsl:when test="matches(@selector,'^:nth\([1-9][0-9]*\)$')">
                    <xsl:sequence select="obfl:and((
                                            concat('(= $volume ',substring(@selector,6)),
                                            obfl:not(obfl:or($stylesheets[position()&lt;$i and @selector]/obfl:volume-stylesheets-use-when(.)))))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="'nil'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:template name="main">
        <obfl version="2011-1" xml:lang="und" hyphenate="false">
            <xsl:for-each select="distinct-values(collection()/*[not(@css:flow)]/string(@css:page))">
                <xsl:sequence select="pxi:generate-layout-master(.)"/>
            </xsl:for-each>
            <xsl:variable name="volume-stylesheet" as="xs:string*"
                          select="distinct-values(collection()/*[not(@css:flow)]/string(@css:volume))"/>
            <xsl:if test="count($volume-stylesheet) &gt; 1">
                <xsl:message terminate="yes">Documents with more than one volume style are not supported.</xsl:message>
            </xsl:if>
            <xsl:variable name="volume-stylesheet" as="xs:string" select="$volume-stylesheet[1]"/>
            <xsl:if test="$volume-stylesheet!=''">
                <xsl:variable name="volume-stylesheets" as="element()*" select="css:parse-stylesheet($volume-stylesheet)"/>
                <xsl:variable name="volume-stylesheets" as="element()*">
                    <xsl:choose>
                        <xsl:when test="$volume-stylesheets[matches(@selector,'^:')]">
                            <xsl:sequence select="$volume-stylesheets"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <css:rule style="{$volume-stylesheet}"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="volume-stylesheets-use-when" as="xs:string*" select="obfl:volume-stylesheets-use-when($volume-stylesheets)"/>
                <xsl:if test="not(obfl:or($volume-stylesheets-use-when)='nil')">
                    <xsl:variable name="no-upper-limit" select="'1000'"/>
                    <xsl:for-each select="$volume-stylesheets">
                        <xsl:variable name="i" select="position()"/>
                        <xsl:variable name="use-when" as="xs:string" select="$volume-stylesheets-use-when[$i]"/>
                        <xsl:if test="not($use-when='nil')">
                            <xsl:variable name="stylesheet" as="element()*" select="css:parse-stylesheet(@style)"/>
                            <xsl:variable name="properties" as="element()*"
                                          select="css:parse-declaration-list($stylesheet[not(@selector)]/@style)"/>
                            <xsl:variable name="volume-area-rules" as="element()*" select="$stylesheet[@selector=('@begin','@end')]"/>
                            <volume-template sheets-in-volume-max="{($properties[@name='max-length' and css:is-valid(.)]/string(@value),$no-upper-limit)[1]}">
                                <xsl:if test="not($use-when='t')">
                                    <xsl:attribute name="use-when" select="$use-when"/>
                                </xsl:if>
                                <xsl:variable name="volume-begin-style" as="element()*"
                                          select="css:parse-declaration-list($volume-area-rules[@selector='@begin'][1]/@style)"/>
                                <xsl:variable name="volume-begin-content" as="element()*">
                                    <xsl:apply-templates select="css:parse-content-list($volume-begin-style[@name='content'][1]/@value,())"
                                                         mode="eval-volume-area-content-list">
                                        <xsl:with-param name="white-space"
                                                        select="($volume-begin-style[@name='white-space']/@value,'normal')[1]"/>
                                        <xsl:with-param name="text-transform"
                                                        select="($volume-begin-style[@name='text-transform']/@value,'auto')[1]"/>
                                        <xsl:with-param name="hyphens"
                                                        select="($volume-begin-style[@name='hyphens']/@value,'manual')[1]"/>
                                        <xsl:with-param name="word-spacing"
                                                        select="($volume-begin-style[@name='word-spacing']/@value,1)[1]"/>
                                    </xsl:apply-templates>
                                </xsl:variable>
                                <xsl:if test="$volume-begin-content">
                                    <pre-content>
                                        <!--
                                            FIXME: Using the same page style for the @begin area as
                                            for the first section of the document. Better is to
                                            support the 'page' property inside @begin.
                                        -->
                                        <xsl:variable name="pre-content-master" as="xs:string"
                                                      select="pxi:generate-layout-master-name(
                                                              (collection()/*[not(@css:flow)])[1]/string(@css:page))"/>
                                        <xsl:for-each-group select="$volume-begin-content" group-ending-with="*[@css:page-break-after='right']">
                                            <xsl:for-each-group select="current-group()" group-starting-with="*[@css:page-break-before='right']">
                                                <xsl:variable name="unwrap-flow" as="element()*"
                                                              select="for $e in current-group() return
                                                                      if ($e/self::css:_[@css:flow]) then $e/* else $e"/>
                                                <xsl:choose>
                                                    <xsl:when test="$unwrap-flow/self::css:box[@type='block' and @css:_obfl-toc]">
                                                        <xsl:variable name="on-first-toc-start-content" as="element()*">
                                                            <xsl:for-each-group select="$unwrap-flow"
                                                                                group-starting-with="css:box[@type='block' and @css:_obfl-toc]">
                                                                <xsl:if test="position()=1
                                                                              and not(current-group()/self::css:box[@type='block' and @css:_obfl-toc])">
                                                                    <xsl:sequence select="current-group()"/>
                                                                </xsl:if>
                                                            </xsl:for-each-group>
                                                        </xsl:variable>
                                                        <xsl:for-each-group select="$unwrap-flow"
                                                                            group-starting-with="css:box[@type='block' and @css:_obfl-toc]">
                                                            <xsl:variable name="toc" as="element()?"
                                                                          select="current-group()/self::css:box[@type='block' and @css:_obfl-toc]"/>
                                                            <xsl:if test="exists($toc)">
                                                                <xsl:variable name="toc-name" select="generate-id($toc)"/>
                                                                <xsl:variable name="toc-range" as="xs:string"
                                                                              select="($toc/@css:_obfl-toc-range,'document')[1]"/>
                                                                <xsl:variable name="on-toc-start-content" as="element()*"
                                                                              select="(collection()/*[@css:flow=concat('-obfl-on-toc-start/',
                                                                                                                       $toc/@css:_obfl-on-toc-start)]/*,
                                                                                       if (position()=2) then $on-first-toc-start-content else ())"/>
                                                                <xsl:variable name="on-volume-start-content" as="element()*"
                                                                              select="if ($toc-range='document' and $toc/@css:_obfl-on-volume-start)
                                                                                      then collection()/*[@css:flow=concat('-obfl-on-volume-start/',
                                                                                                                           $toc/@css:_obfl-on-volume-start)]/*
                                                                                      else ()"/>
                                                                <xsl:variable name="on-volume-end-content" as="element()*"
                                                                              select="if ($toc-range='document' and $toc/@css:_obfl-on-volume-end)
                                                                                      then collection()/*[@css:flow=concat('-obfl-on-volume-end/',
                                                                                                                           $toc/@css:_obfl-on-volume-end)]/*
                                                                                      else ()"/>
                                                                <xsl:variable name="on-toc-end-content" as="element()*"
                                                                              select="(current-group()[not(self::css:box[@type='block' and @css:_obfl-toc])],
                                                                                       collection()/*[@css:flow=concat('-obfl-on-toc-end/',
                                                                                                                       $toc/@css:_obfl-on-toc-end)]/*)"/>
                                                                <toc-sequence master="{$pre-content-master}" range="{$toc-range}" toc="{$toc-name}">
                                                                    <!--
                                                                        Inserting table-of-contents here as child of toc-sequence. Will be moved to the
                                                                        right place (child of obfl) later.
                                                                    -->
                                                                    <table-of-contents name="{$toc-name}">
                                                                        <xsl:apply-templates select="$toc" mode="table-of-contents">
                                                                            <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                                                                            <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
                                                                            <xsl:with-param name="word-spacing" tunnel="yes" select="1"/>
                                                                        </xsl:apply-templates>
                                                                    </table-of-contents>
                                                                    <xsl:if test="exists($on-toc-start-content)">
                                                                        <on-toc-start>
                                                                            <xsl:call-template name="group-inline-elements">
                                                                                <xsl:with-param name="elements" select="$on-toc-start-content"/>
                                                                                <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                                                                                <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
                                                                                <xsl:with-param name="word-spacing" tunnel="yes" select="1"/>
                                                                            </xsl:call-template>
                                                                        </on-toc-start>
                                                                    </xsl:if>
                                                                    <xsl:if test="exists($on-volume-start-content)">
                                                                        <on-volume-start>
                                                                            <xsl:call-template name="group-inline-elements">
                                                                                <xsl:with-param name="elements" select="$on-volume-start-content"/>
                                                                                <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                                                                                <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
                                                                                <xsl:with-param name="word-spacing" tunnel="yes" select="1"/>
                                                                            </xsl:call-template>
                                                                        </on-volume-start>
                                                                    </xsl:if>
                                                                    <xsl:if test="exists($on-volume-end-content)">
                                                                        <on-volume-end>
                                                                            <xsl:call-template name="group-inline-elements">
                                                                                <xsl:with-param name="elements" select="$on-volume-end-content"/>
                                                                                <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                                                                                <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
                                                                                <xsl:with-param name="word-spacing" tunnel="yes" select="1"/>
                                                                            </xsl:call-template>
                                                                        </on-volume-end>
                                                                    </xsl:if>
                                                                    <xsl:if test="exists($on-toc-end-content)">
                                                                        <on-toc-end>
                                                                            <xsl:call-template name="group-inline-elements">
                                                                                <xsl:with-param name="elements" select="$on-toc-end-content"/>
                                                                                <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                                                                                <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
                                                                                <xsl:with-param name="word-spacing" tunnel="yes" select="1"/>
                                                                            </xsl:call-template>
                                                                        </on-toc-end>
                                                                    </xsl:if>
                                                                </toc-sequence>
                                                            </xsl:if>
                                                        </xsl:for-each-group>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <sequence master="{$pre-content-master}">
                                                            <xsl:call-template name="group-inline-elements">
                                                                <xsl:with-param name="elements" select="$unwrap-flow"/>
                                                                <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                                                                <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
                                                                <xsl:with-param name="word-spacing" tunnel="yes" select="1"/>
                                                            </xsl:call-template>
                                                        </sequence>
                                                    </xsl:otherwise>
                                               </xsl:choose>
                                            </xsl:for-each-group>
                                        </xsl:for-each-group>
                                    </pre-content>
                                </xsl:if>
                                <xsl:variable name="volume-end-style" as="element()*"
                                              select="css:parse-declaration-list($volume-area-rules[@selector='@end'][1]/@style)"/>
                                <xsl:variable name="volume-end-content" as="element()*">
                                    <xsl:apply-templates select="css:parse-content-list($volume-end-style[@name='content'][1]/@value,())"
                                                         mode="eval-volume-area-content-list">
                                        <xsl:with-param name="white-space"
                                                        select="($volume-end-style[@name='white-space']/@value,'normal')[1]"/>
                                        <xsl:with-param name="text-transform"
                                                        select="($volume-end-style[@name='text-transform']/@value,'auto')[1]"/>
                                        <xsl:with-param name="hyphens"
                                                        select="($volume-end-style[@name='hyphens']/@value,'manual')[1]"/>
                                        <xsl:with-param name="word-spacing"
                                                        select="($volume-end-style[@name='word-spacing']/@value,1)[1]"/>
                                    </xsl:apply-templates>
                                </xsl:variable>
                                <xsl:if test="$volume-end-content">
                                    <post-content>
                                        <!--
                                            FIXME: Using the same page style for the @end area as
                                            for the last section of the document. Better is to
                                            support the 'page' property inside @end.
                                        -->
                                        <xsl:variable name="post-content-master" as="xs:string"
                                                      select="pxi:generate-layout-master-name(
                                                              (collection()/*[not(@css:flow)])[last()]/string(@css:page))"/>
                                        <xsl:for-each-group select="$volume-end-content" group-ending-with="*[@css:page-break-after='right']">
                                            <xsl:for-each-group select="current-group()" group-starting-with="*[@css:page-break-before='right']">
                                                <xsl:variable name="unwrap-flow" as="element()*"
                                                              select="for $e in current-group() return
                                                                      if ($e/self::css:_[@css:flow]) then $e/* else $e"/>
                                                <sequence master="{$post-content-master}">
                                                    <xsl:call-template name="group-inline-elements">
                                                        <xsl:with-param name="elements" select="$unwrap-flow"/>
                                                        <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                                                        <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
                                                        <xsl:with-param name="word-spacing" tunnel="yes" select="1"/>
                                                    </xsl:call-template>
                                                </sequence>
                                            </xsl:for-each-group>
                                        </xsl:for-each-group>
                                    </post-content>
                                </xsl:if>
                            </volume-template>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:if>
            <!--
                <xsl:for-each select="collection()/*[@css:flow]">
                <xsl:variable name="flow" as="xs:string" select="@css:flow"/>
                <collection name="{$flow}">
                <xsl:for-each select="*">
                <item id="{@css:anchor}">
                <xsl:apply-templates select=".">
                <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
                </xsl:apply-templates>
                </item>
                </xsl:for-each>
                </collection>
                </xsl:for-each>
            -->
            <xsl:for-each-group select="collection()/*[not(@css:flow)]" group-adjacent="string(@css:page)">
                <xsl:variable name="layout-master" select="pxi:generate-layout-master-name(current-grouping-key())"/>
                <xsl:for-each-group select="current-group()" group-starting-with="*[@css:page-break-before='right' or @css:counter-set-page]">
                    <xsl:for-each-group select="current-group()" group-ending-with="*[@css:page-break-after='right']">
                        <sequence master="{$layout-master}">
                            <xsl:variable name="first" as="element()" select="current-group()[1]"/>
                            <xsl:apply-templates select="$first/@css:counter-set-page" mode="sequence"/>
                            <xsl:apply-templates select="$first/(@* except (@css:counter-set-page,@css:string-entry))" mode="sequence"/>
                            <xsl:apply-templates select="$first/@css:string-entry" mode="sequence"/>
                            <xsl:call-template name="group-inline-elements">
                                <xsl:with-param name="elements" select="for $x in current-group()
                                                                        return if ($x/self::css:_) then $x/* else $x"/>
                                <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                                <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
                                <xsl:with-param name="word-spacing" tunnel="yes" select="1"/>
                            </xsl:call-template>
                        </sequence>
                    </xsl:for-each-group>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </obfl>
    </xsl:template>
    
    <xsl:template name="group-inline-elements">
        <xsl:param name="elements" as="node()*" required="yes"/>
        <xsl:for-each-group select="$elements" group-adjacent="boolean(self::css:box[@type=('block','table')])">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:apply-templates select="current-group()" mode="sequence"/>
                </xsl:when>
                <xsl:otherwise>
                    <block>
                        <xsl:apply-templates select="current-group()"/>
                    </block>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']" mode="sequence">
        <xsl:apply-templates select="."/>
    </xsl:template>
    
    <xsl:template match="/*/@css:counter-set-page" mode="sequence">
        <xsl:attribute name="initial-page-number" select="."/>
    </xsl:template>
    
    <xsl:template match="/*/@css:counter-set-page"/>
    
    <xsl:template match="/*/@css:page|
                         /*/@css:volume"
                  mode="#default sequence"/>
    
    <xsl:template match="css:box/css:_" mode="#default table-of-contents">
        <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:template>
    
    <!--
        block or toc-entry element depending on context
    -->
    <xsl:template match="css:box[@type='block']" priority="0.8" mode="#default td">
        <block>
            <xsl:next-match/>
        </block>
    </xsl:template>
    <xsl:template match="css:box[@type='block']" priority="0.8" mode="table-of-contents">
        <!--
            Automatically compute the toc-entry's ref-id by searching for target-counter(),
            target-text() and target-string() values within the current block, descendant blocks,
            following blocks or preceding blocks (in that order). It is currently not possible to
            define the ref-id directly in CSS which means a table-of-contents can not be constructed
            if no references are used for rendering content (such as braille page numbers or print
            page numbers).
        -->
        <!--
            TODO: warning when not all references in a block point to the same element
            TODO: warning when a block has no references or descendant blocks with references
        -->
        <xsl:variable name="descendant-refs" as="attribute()*"
                      select="((descendant::css:box)/@css:anchor
                               |(descendant::css:string)/@target
                               |(descendant::css:counter)/@target)"/>
        <xsl:variable name="following-refs" as="attribute()*"
                      select="((following::css:box)/@css:anchor
                               |(following::css:string)/@target
                               |(following::css:counter)/@target)"/>
        <xsl:variable name="preceding-refs" as="attribute()*"
                      select="(preceding::css:box/@css:anchor
                               |preceding::css:string/@target
                               |preceding::css:counter/@target)"/>
        <xsl:choose>
            <xsl:when test="exists($descendant-refs[some $id in string(.) satisfies collection()/*[not(@css:flow)]//*[@css:id=$id]])">
                <xsl:variable name="ref-id" as="xs:string"
                              select="$descendant-refs[some $id in string(.) satisfies collection()/*[not(@css:flow)]//*[@css:id=$id]][1]"/>
                <toc-entry ref-id="{$ref-id}">
                    <xsl:next-match>
                        <xsl:with-param name="toc-entry-ref-id" select="$ref-id" tunnel="yes"/>
                    </xsl:next-match>
                </toc-entry>
            </xsl:when>
            <xsl:when test="exists($descendant-refs)">
                <!--
                    if the entry references an element in a named flow, we assume that element is
                    part of the volume begin or end area, and is therefore omitted from the table of
                    contents
                -->
            </xsl:when>
            <xsl:when test="exists($following-refs[some $id in string(.) satisfies collection()/*[not(@css:flow)]//*[@css:id=$id]])">
                <xsl:variable name="ref-id" as="xs:string"
                              select="$following-refs[some $id in string(.) satisfies collection()/*[not(@css:flow)]//*[@css:id=$id]][1]"/>
                <toc-entry ref-id="{$ref-id}">
                    <xsl:next-match>
                        <xsl:with-param name="toc-entry-ref-id" select="$ref-id" tunnel="yes"/>
                    </xsl:next-match>
                </toc-entry>
            </xsl:when>
            <xsl:when test="exists($preceding-refs[some $id in string(.) satisfies collection()/*[not(@css:flow)]//*[@css:id=$id]])">
                <xsl:variable name="ref-id" as="xs:string"
                              select="$preceding-refs[some $id in string(.) satisfies collection()/*[not(@css:flow)]//*[@css:id=$id]][last()]"/>
                <toc-entry ref-id="{$ref-id}">
                    <xsl:next-match>
                        <xsl:with-param name="toc-entry-ref-id" select="$ref-id" tunnel="yes"/>
                    </xsl:next-match>
                </toc-entry>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="concat(
                                       'An element with display: -obfl-toc must have at least one descendant ',
                                       'target-counter(), target-string() or target-text() value (that references ',
                                       'an element that does not participate in a named flow).')">
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
        attributes that apply on outer block
    -->
    <xsl:template match="css:box[@type='block']" priority="0.7" mode="#default td table-of-contents">
        <xsl:apply-templates select="@* except (@type|
                                                @css:string-set|@css:_obfl-marker|
                                                @css:line-height|
                                                @css:text-align|@css:text-indent|@page-break-inside)"
                             mode="#current"/>
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        not wrapped in additional block
    -->
    <xsl:template match="css:box[@type='block']
                                [not(@css:line-height
                                     and (@css:margin-top or @css:margin-bottom or
                                          @css:border-top or @css:border-bottom))]"
                  priority="0.6" mode="#default td table-of-contents">
        <xsl:apply-templates select="@css:line-height|@css:text-align|@css:text-indent|@page-break-inside" mode="#current"/>
        <xsl:apply-templates select="@css:string-set|@css:_obfl-marker" mode="#current"/>
        <xsl:apply-templates mode="#current"/>
        <!-- <xsl:apply-templates select="@css:id" mode="anchor"/> -->
    </xsl:template>
    
    <!--
        wrap content in additional block or toc-entry element when line-height > 1 is combined with
        top/bottom margin or border
    -->
    <xsl:template match="css:box[@type='block']
                                [@css:line-height
                                 and (@css:margin-top or @css:margin-bottom or
                                      @css:border-top or @css:border-bottom)]"
                  priority="0.63" mode="#default td table-of-contents">
        <xsl:apply-templates select="@css:string-set|@css:_obfl-marker" mode="#current"/>
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        block or toc-entry element depending on context
    -->
    <xsl:template match="css:box[@type='block']
                                [@css:line-height
                                 and (@css:margin-top or @css:margin-bottom or
                                      @css:border-top or @css:border-bottom)]"
                  mode="#default td"
                  priority="0.62">
        <block>
            <xsl:next-match/>
        </block>
    </xsl:template>
    <xsl:template match="css:box[@type='block']
                                [@css:line-height
                                 and (@css:margin-top or @css:margin-bottom or
                                      @css:border-top or @css:border-bottom)]"
                  priority="0.61" mode="table-of-contents">
        <xsl:param name="toc-entry-ref-id" as="xs:string" tunnel="yes"/>
        <toc-entry ref-id="{$toc-entry-ref-id}">
            <xsl:next-match/>
        </toc-entry>
    </xsl:template>
    
    <!--
        attributes that apply on inner block
    -->
    <xsl:template match="css:box[@type='block']
                                [@css:line-height
                                 and (@css:margin-top or @css:margin-bottom or
                                      @css:border-top or @css:border-bottom)]"
                  priority="0.6" mode="#default td table-of-contents">
        <xsl:apply-templates select="@css:line-height|@css:text-align|@css:text-indent|@page-break-inside" mode="#current"/>
        <!--
            repeat orphans/widows (why?)
        -->
        <xsl:apply-templates select="@css:orphans|@css:widows" mode="#current"/>
        <xsl:apply-templates mode="#current"/>
        <!-- <xsl:apply-templates select="@css:id" mode="anchor"/> -->
    </xsl:template>
    
    <xsl:template match="css:box[@type='table']|
                         css:box[@type='block'][descendant::css:box[@type='table']]"
                  priority="0.8" mode="sequence">
        <table>
            <xsl:apply-templates select="." mode="table"/>
        </table>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']" mode="table">
        <xsl:apply-templates select="@* except @type" mode="#current"/>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="css:box[@type='table']" mode="table">
        <xsl:apply-templates select="@* except @type" mode="#current"/>
        <xsl:variable name="header-cells" as="element()*" select="css:box[@type='table-cell' and @css:table-header-group]"/>
        <xsl:variable name="body-cells" as="element()*" select="css:box[@type='table-cell' and @css:table-row-group]"/>
        <xsl:variable name="footer-cells" as="element()*" select="css:box[@type='table-cell' and @css:table-footer-group]"/>
        <xsl:variable name="header" as="element()*">
            <xsl:for-each-group select="$header-cells" group-by="@css:table-row">
                <xsl:sort select="xs:integer(current-grouping-key())"/>
                <tr>
                    <xsl:for-each select="current-group()">
                        <xsl:sort select="xs:integer(@css:table-column)"/>
                        <xsl:apply-templates select="." mode="tr"/>
                    </xsl:for-each>
                </tr>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:variable name="body" as="element()*">
            <xsl:for-each-group select="$body-cells" group-by="@css:table-row-group">
                <xsl:sort select="xs:integer(current-grouping-key())"/>
                <xsl:for-each-group select="current-group()" group-by="@css:table-row">
                    <xsl:sort select="xs:integer(current-grouping-key())"/>
                    <tr>
                        <xsl:for-each select="current-group()">
                            <xsl:sort select="xs:integer(@css:table-column)"/>
                            <xsl:apply-templates select="." mode="tr"/>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:variable name="footer" as="element()*">
            <xsl:for-each-group select="$footer-cells" group-by="@css:table-row">
                <xsl:sort select="xs:integer(current-grouping-key())"/>
                <tr>
                    <xsl:for-each select="current-group()">
                        <xsl:sort select="xs:integer(@css:table-column)"/>
                        <xsl:apply-templates select="." mode="tr"/>
                    </xsl:for-each>
                </tr>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:apply-templates select="node() except ($header-cells|$body-cells|$footer-cells)" mode="table"/>
        <xsl:choose>
            <xsl:when test="exists($header)">
                <thead>
                    <xsl:sequence select="$header"/>
                </thead>
                <tbody>
                    <xsl:sequence select="$body"/>
                    <xsl:sequence select="$footer"/>
                </tbody>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$body"/>
                <xsl:sequence select="$footer"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:box[@type='table-cell']" mode="tr">
        <td>
            <xsl:if test="@css:table-row-span">
                <xsl:attribute name="row-span" select="@css:table-row-span"/>
            </xsl:if>
            <xsl:if test="@css:table-column-span">
                <xsl:attribute name="col-span" select="@css:table-column-span"/>
            </xsl:if>
            <xsl:apply-templates select="@* except (@type|
                                                    @css:table-header-group|
                                                    @css:table-row-group|
                                                    @css:table-footer-group|
                                                    @css:table-row|
                                                    @css:table-column|
                                                    @css:table-row-span|
                                                    @css:table-column-span)"
                                 mode="td"/>
            <xsl:apply-templates mode="td"/>
        </td>
    </xsl:template>
    
    <xsl:template match="css:box[@type='table']" mode="td">
        <xsl:message terminate="yes">Nested tables not supported.</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:box[@type='inline']" mode="#default td table-of-contents">
        <xsl:variable name="attrs" as="attribute()*">
            <xsl:apply-templates select="@* except (@type|@css:string-set|@css:_obfl-marker)" mode="#current"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="exists($attrs)">
                <!--
                    FIXME: nested spans are a problem
                -->
                <span>
                    <xsl:sequence select="$attrs"/>
                    <xsl:apply-templates select="@css:string-set|@css:_obfl-marker" mode="#current"/>
                    <xsl:apply-templates mode="#current"/>
                    <!-- <xsl:apply-templates select="@css:id" mode="anchor"/> -->
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="@css:string-set|@css:_obfl-marker" mode="#current"/>
                <xsl:apply-templates mode="#current"/>
                <!-- <xsl:apply-templates select="@css:id" mode="anchor"/> -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:box[@css:hyphens]" priority="1" mode="#default td table-of-contents">
        <xsl:next-match>
            <xsl:with-param name="hyphens" tunnel="yes" select="@css:hyphens"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="css:box/@css:hyphens" mode="#default td table-of-contents">
        <!--
            'hyphens:auto' corresponds with 'hyphenate="true"'. 'hyphens:manual' corresponds with
            'hyphenate="false"'. For 'hyphens:none' all SHY and ZWSP characters are removed from the
            text.
        -->
        <xsl:attribute name="hyphenate" select="if (.='auto') then 'true' else 'false'"/>
    </xsl:template>
    
    <xsl:template match="css:box[@css:text-transform]" priority="1.1" mode="#default td table table-of-contents">
        <xsl:next-match>
            <xsl:with-param name="text-transform" tunnel="yes" select="@css:text-transform"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="css:box/@css:text-transform" mode="#default td table table-of-contents">
        <!--
            'text-transform:auto' corresponds with 'translate=""'. 'text-transform:none' would
            normally correspond with 'translate="pre-translated"', but because "pre-translated"
            currently delegates to a non-configurable bypass translator, 'translate=""' is used here
            too. Other values of text-transform are currently handled by translating prior to
            formatting when possible and otherwise (i.e. for content generated while formatting)
            ignored. FIXME: make use of style elements.
        -->
    </xsl:template>
    
    <xsl:template match="css:box[@css:word-spacing]" priority="1.2" mode="#default td table table-of-contents">
        <xsl:next-match>
            <xsl:with-param name="word-spacing" tunnel="yes" select="xs:integer(@css:word-spacing)"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="css:box/@css:word-spacing" mode="#default td table table-of-contents"/>
    
    <xsl:template match="css:box/@name|
                         css:box/css:_/@name"
                  mode="#default td table table-of-contents"/>
    
    <xsl:template match="css:box/@part" mode="#default td table"/>
    
    <xsl:template match="/*/*/@css:_obfl-toc|
                         /*/*[@css:_obfl-toc]/@css:_obfl-toc-range|
                         /*/*[@css:_obfl-toc]/@css:_obfl-on-toc-start|
                         /*/*[@css:_obfl-toc]/@css:_obfl-on-volume-start|
                         /*/*[@css:_obfl-toc]/@css:_obfl-on-volume-end|
                         /*/*[@css:_obfl-toc]/@css:_obfl-on-toc-end"
                  mode="table-of-contents"/>
    
    <xsl:template match="css:box[@type=('block','table')]/@css:margin-left|
                         css:box[@type=('block','table')]/@css:margin-right|
                         css:box[@type=('block','table')]/@css:margin-top|
                         css:box[@type=('block','table')]/@css:margin-bottom"
                  mode="#default table td table-of-contents">
        <xsl:attribute name="{local-name()}" select="format-number(xs:integer(number(.)), '0')"/>
    </xsl:template>
    
    <xsl:template match="css:box[@type=('block','table')]/@css:line-height"
                  mode="#default table td table-of-contents">
        <xsl:attribute name="row-spacing" select="format-number(xs:integer(number(.)), '0.0')"/>
    </xsl:template>
    
    <xsl:template match="css:box[@type=('block','table-cell') and not(child::css:box[@type='block']) and @css:text-indent]/@css:margin-left"
                  mode="#default table td table-of-contents"/>
    
    <xsl:template match="css:box[@type=('block','table-cell') and not(child::css:box[@type='block'])]/@css:text-indent"
                  mode="#default table td table-of-contents" priority="0.6">
        <xsl:variable name="text-indent" as="xs:integer" select="xs:integer(number(.))"/>
        <xsl:variable name="margin-left" as="xs:integer" select="(parent::*/@css:margin-left/xs:integer(number(.)),0)[1]"/>
        <xsl:if test="parent::*[@name or not(preceding-sibling::css:box)]">
            <xsl:attribute name="first-line-indent" select="format-number($margin-left + $text-indent, '0')"/>
        </xsl:if>
        <xsl:if test="$margin-left &gt; 0">
            <xsl:attribute name="text-indent" select="format-number($margin-left, '0')"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:box[@type=('block','table-cell')]/@css:text-indent"
                  mode="#default table td table-of-contents"/>
    
    <xsl:template match="css:box[@type=('block','table-cell')]/@css:text-align"
                  mode="#default table td table-of-contents">
        <xsl:attribute name="align" select="."/>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']/@css:_obfl-vertical-position">
        <xsl:attribute name="vertical-position" select="."/>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']/@css:_obfl-vertical-align">
        <xsl:attribute name="vertical-align" select="."/>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']/@css:page-break-before[.='always']">
        <xsl:attribute name="break-before" select="'page'"/>
    </xsl:template>
    
    <!--
        FIXME: 'left' not supported, treating as 'always'
    -->
    <xsl:template match="css:box[@type='block']/@css:page-break-before[.='left']">
        <xsl:message select="concat(local-name(),':',.,' not supported yet. Treating like &quot;always&quot;.')"/>
        <xsl:attribute name="break-before" select="'page'"/>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']/@css:page-break-after[.='avoid']">
        <xsl:attribute name="keep-with-next" select="'1'"/>
        <!--
            keep-with-next="1" requires that keep="all". This gives it a slighly different meaning
            than "page-break-after: avoid", but it will do.
        -->
        <xsl:if test="not(parent::*/@css:page-break-inside[.='avoid'])">
            <xsl:attribute name="keep" select="'all'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="/*/@css:page-break-before[.=('always','right')]|
                         /*/@css:page-break-after[.=('always','right')]"
                  mode="sequence" priority="0.6"/>
    
    <!--
        FIXME: 'left' not supported
    -->
    <xsl:template match="/*/@css:page-break-before[.='left']|
                         /*/@css:page-break-after[.='left']"
                  mode="sequence" priority="0.6"/>
    
    <xsl:template match="css:box[@type='block']/@css:page-break-inside[.='avoid']">
        <xsl:attribute name="keep" select="'all'"/>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']/@css:orphans|
                         css:box[@type='block']/@css:widows">
        <xsl:attribute name="{local-name()}" select="."/>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']/@css:_obfl-vertical-position|
                         css:box[@type='block']/@css:_obfl-vertical-align|
                         css:box[@type='block']/@css:page-break-before|
                         css:box[@type='block']/@css:page-break-after|
                         css:box[@type='block']/@css:page-break-inside|
                         css:box[@type='block']/@css:orphans|
                         css:box[@type='block']/@css:widows"
                  mode="table-of-contents">
        <xsl:message select="concat('Property ',replace(local-name(),'^_','-'),' not supported inside an element with display: -obfl-toc')"/>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']/@css:_obfl-vertical-position|
                         css:box[@type='block']/@css:_obfl-vertical-align|
                         css:box[@type='block']/@css:page-break-before|
                         css:box[@type='block']/@css:page-break-after|
                         css:box[@type='block']/@css:page-break-inside|
                         css:box[@type='block']/@css:orphans|
                         css:box[@type='block']/@css:widows"
                  mode="td">
        <xsl:message select="concat('Property ',replace(local-name(),'^_','-'),' not supported inside table cell elements')"/>
    </xsl:template>
    
    <xsl:template match="css:box[@type=('block','table','table-cell')]/@css:border-left|
                         css:box[@type=('block','table','table-cell')]/@css:border-right"
                  mode="#default table td table-of-contents">
        <xsl:choose>
            <xsl:when test=".='none'">
                <xsl:attribute name="{local-name()}-style" select="'none'"/>
            </xsl:when>
            <xsl:when test=".=('⠇','⠿','⠸')">
                <xsl:attribute name="{local-name()}-style" select="'solid'"/>
                <xsl:choose>
                    <xsl:when test=".='⠿'">
                        <xsl:attribute name="{local-name()}-width" select="'2'"/>
                    </xsl:when>
                    <xsl:when test=".='⠇'">
                        <xsl:attribute name="{local-name()}-align"
                                       select="if (local-name()='border-left') then 'outer' else 'inner'"/>
                    </xsl:when>
                    <xsl:when test=".='⠸'">
                        <xsl:attribute name="{local-name()}-align"
                                       select="if (local-name()='border-right') then 'outer' else 'inner'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="concat(local-name(),':',.,' not supported yet')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:box[@type=('block','table','table-cell')]/@css:border-top|
                         css:box[@type=('block','table','table-cell')]/@css:border-bottom"
                  mode="#default table td table-of-contents">
        <xsl:choose>
            <xsl:when test=".='none'">
                <xsl:attribute name="{local-name()}-style" select="'none'"/>
            </xsl:when>
            <xsl:when test=".=('⠉','⠛','⠒','⠿','⠶','⠤')">
                <xsl:attribute name="{local-name()}-style" select="'solid'"/>
                <xsl:choose>
                    <xsl:when test=".=('⠛','⠶')">
                        <xsl:attribute name="{local-name()}-width" select="'2'"/>
                    </xsl:when>
                    <xsl:when test=".='⠿'">
                        <xsl:attribute name="{local-name()}-width" select="'3'"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test=".=('⠉','⠛')">
                        <xsl:attribute name="{local-name()}-align"
                                       select="if (local-name()='border-top') then 'outer' else 'inner'"/>
                    </xsl:when>
                    <xsl:when test=".=('⠶','⠤')">
                        <xsl:attribute name="{local-name()}-align"
                                       select="if (local-name()='border-top') then 'inner' else 'outer'"/>
                    </xsl:when>
                    <xsl:when test=".='⠒'">
                        <xsl:attribute name="{local-name()}-align"
                                       select="'center'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="concat(local-name(),':',.,' not supported yet')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:string[@name]" mode="#default table-of-contents">
        <xsl:if test="@scope">
            <xsl:message select="concat('string(',@name,', ',@scope,'): second argument not supported')"/>
        </xsl:if>
        <xsl:if test="@css:white-space">
            <xsl:message select="concat('white-space:',@css:white-space,' could not be applied to ',
                                        (if (@target) then 'target-string' else 'string'),'(',@name,')')"/>
        </xsl:if>
        <xsl:variable name="target" as="xs:string?"
                      select="if (@target) then @target else
                              if (ancestor::*/@css:flow[not(.='normal')]) then ancestor::*/@css:anchor else ()"/>
        <xsl:variable name="target" as="element()?"
                      select="if ($target) then collection()/*[not(@css:flow)]//*[@css:id=$target][1] else ."/>
        <xsl:if test="$target">
            <xsl:apply-templates select="css:string(@name, $target)" mode="eval-string"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:string[@value]" mode="eval-string">
        <xsl:call-template name="text">
            <xsl:with-param name="text" select="string(@value)"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="css:counter[@target][@name='page']" mode="#default table-of-contents">
        <xsl:param name="text-transform" as="xs:string" tunnel="yes"/>
        <xsl:param name="hyphens" as="xs:string" tunnel="yes"/>
        <xsl:if test="@css:white-space">
            <xsl:message select="concat('white-space:',@css:white-space,' could not be applied to target-counter(page)')"/>
        </xsl:if>
        <xsl:if test="not($text-transform=('auto','none'))">
            <!--
                FIXME: make use of style element
            -->
            <xsl:message select="concat('text-transform:',$text-transform,' could not be applied to target-counter(page)')"/>
        </xsl:if>
        <xsl:if test="$hyphens='none'">
            <!--
                FIXME: make use of style element
            -->
            <xsl:message select="'hyphens:none could not be applied to target-counter(page)'"/>
        </xsl:if>
        <page-number ref-id="{@target}" number-format="{if (@style=('roman', 'upper-roman', 'lower-roman', 'upper-alpha', 'lower-alpha'))
                                                        then @style else 'default'}"/>
    </xsl:template>
    
    <xsl:template match="css:leader" mode="#default td table-of-contents">
        <leader pattern="{@pattern}" position="100%" align="right"/>
    </xsl:template>
    
    <xsl:template match="css:custom-func[@name='-obfl-evaluate'][matches(@arg1,$css:STRING_RE) and not (@arg2)]" priority="1">
        <evaluate expression="{substring(@arg1,2,string-length(@arg1)-2)}"/>
    </xsl:template>
    
    <xsl:template match="css:custom-func[@name='-obfl-evaluate']">
        <xsl:message>-obfl-evaluate() function requires exactly one string argument</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']/@css:id" mode="#default table-of-contents">
        <xsl:variable name="id" as="xs:string" select="."/>
        <xsl:if test="not(ancestor::*/@css:flow[not(.='normal')])">
            <xsl:attribute name="id" select="$id"/>
        </xsl:if>
    </xsl:template>
    
    <!--
        FIXME: id attribute not supported on a span
    -->
    <xsl:template match="css:box[@type='inline']/@css:id" mode="#default table-of-contents">
        <xsl:variable name="id" as="xs:string" select="."/>
        <xsl:if test="collection()//css:counter[@target=$id]">
            <xsl:message terminate="yes">target-counter() referencing inline elements not supported.</xsl:message>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:box/@css:id" mode="anchor">
        <xsl:variable name="id" as="xs:string" select="."/>
        <xsl:if test="collection()/*[@css:flow]/*/@css:anchor=$id">
            <anchor item="{$id}"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:box/@css:anchor" mode="#default table-of-contents"/>
    
    <xsl:template match="css:box/@css:string-set|
                         css:box/css:_/@css:string-set"
                  mode="#default td table-of-contents">
        <xsl:apply-templates select="css:parse-string-set(.)" mode="parse-string-set"/>
    </xsl:template>
    
    <xsl:template match="css:string-set" mode="parse-string-set">
        <xsl:variable name="value" as="xs:string*">
            <xsl:apply-templates select="css:parse-content-list(@value, ())" mode="eval-string-set"/>
        </xsl:variable>
        <marker class="{@name}" value="{string-join($value,'')}"/>
    </xsl:template>
    
    <xsl:template match="/*/@css:string-entry"/>
    
    <xsl:template match="/*/@css:string-entry" mode="sequence">
        <block>
            <xsl:apply-templates select="css:parse-string-set(.)" mode="parse-string-entry"/>
        </block>
    </xsl:template>
    
    <xsl:template match="css:string-set" mode="parse-string-entry">
        <xsl:variable name="value" as="xs:string*">
            <xsl:apply-templates select="css:parse-content-list(@value, ())" mode="eval-string-set"/>
        </xsl:variable>
        <marker class="{@name}/entry" value="{string-join($value,'')}"/>
    </xsl:template>
    
    <xsl:template match="css:string[@value]" mode="eval-string-set" as="xs:string">
        <xsl:sequence select="string(@value)"/>
    </xsl:template>
    
    <xsl:template match="css:box/@css:_obfl-marker|
                         css:box/css:_/@css:_obfl-marker"
                  mode="#default table-of-contents">
        <marker class="indicator/{.}" value="x"/>
    </xsl:template>
    
    <xsl:template match="css:box[@type='table']/@css:_obfl-table-col-spacing|
                         css:box[@type='table']/@css:_obfl-table-row-spacing|
                         css:box[@type='table']/@css:_obfl-preferred-empty-space"
                  mode="table">
        <xsl:attribute name="{replace(local-name(),'^_obfl-','')}" select="format-number(xs:integer(.), '0')"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="#default td table-of-contents">
        <xsl:call-template name="text">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <!--
        FIXME: only if within block and no sibling blocks
    -->
    <xsl:template name="text">
        <xsl:param name="text" as="xs:string" required="yes"/>
        <xsl:param name="text-transform" as="xs:string" tunnel="yes"/>
        <xsl:param name="hyphens" as="xs:string" tunnel="yes"/>
        <xsl:param name="word-spacing" as="xs:integer" tunnel="yes"/>
        <xsl:variable name="text" as="xs:string">
            <xsl:choose>
                <!--
                    text-transform values 'none' and 'auto' are handled during formatting. A
                    translation is performed only when there are non-braille characters in the text.
                -->
                <xsl:when test="$text-transform=('none','auto') or not($word-spacing=1)">
                    <xsl:sequence select="$text"/>
                </xsl:when>
                <!--
                    Other values are handled by translating prior to formatting.
                -->
                <xsl:otherwise>
                    <xsl:sequence select="pf:text-transform($braille-translator-query,
                                                            $text,
                                                            concat('text-transform:',$text-transform))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="text" as="xs:string" select="translate($text,'&#x2800;',' ')"/>
        <xsl:variable name="text" as="xs:string">
            <xsl:choose>
                <!--
                    For 'hyphens:none' all SHY and ZWSP characters are removed from the text in advance.
                -->
                <xsl:when test="$hyphens='none'">
                    <xsl:sequence select="replace($text,'[&#x00AD;&#x200B;]','')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$text"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="text" as="xs:string">
            <xsl:choose>
                <xsl:when test="$word-spacing=1">
                    <xsl:sequence select="$text"/>
                </xsl:when>
                <!--
                    FIXME: style elements are currently processed in a step before line breaking (in
                    MarkerProcessorFactoryServiceImpl) so that they can't be used for
                    word-spacing. Performing word spacing in XSLT instead.
                -->
                <xsl:otherwise>
                    <xsl:variable name="words" as="xs:string*">
                        <xsl:analyze-string select="$text" regex="[&#x00AD;&#x200B;]*[ \t\n\r][&#x00AD;&#x200B; \t\n\r]*">
                            <xsl:matching-substring/>
                            <xsl:non-matching-substring>
                                <xsl:sequence select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    <xsl:variable name="spacing" as="xs:string" select="concat(string-join(for $x in 1 to $word-spacing return '&#x00A0;',''),'&#x200B;')"/>
                    <xsl:sequence select="string-join($words, $spacing)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not($word-spacing=1) and not($text-transform=('none','auto'))">
                <!--
                    text-transform has not been applied yet
                -->
                <style>
                    <xsl:attribute name="name" select="concat('text-transform:',$text-transform)"/>
                    <xsl:value-of select="$text"/>
                </style>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:white-space" mode="#default td table-of-contents">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="css:white-space/text()" mode="#default td table-of-contents">
        <xsl:analyze-string select="." regex="\n">
            <xsl:matching-substring>
                <br/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="\s+">
                    <xsl:matching-substring>
                        <xsl:value-of select="concat(replace(.,'.','&#x00A0;'),'&#x200B;')"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']/@css:_obfl-toc" mode="#default table-of-contents" priority="0.1">
        <xsl:message>display: -obfl-toc only allowed on elements that are flowed into @begin area.</xsl:message>
    </xsl:template>
    
    <xsl:template match="@css:_obfl-on-toc-start|
                         @css:_obfl-on-volume-start|
                         @css:_obfl-on-volume-end|
                         @css:_obfl-on-toc-end">
        <xsl:message select="concat('::',replace(local-name(),'^_','-'),' pseudo-element only allowed on elements with display: -obfl-toc.')"/>
    </xsl:template>
    
    <xsl:template match="@*|*" mode="#default sequence table tr td table-of-contents">
        <xsl:message terminate="yes">Coding error: unexpected <xsl:value-of select="pxi:get-path(.)"/> (mode was <xsl:apply-templates select="$pxi:mode" mode="#current"/>)</xsl:message>
    </xsl:template>
    
    <xsl:function name="pxi:get-path" as="xs:string">
        <xsl:param name="x"/> <!-- element()|attribute() -->
        <xsl:variable name="name" as="xs:string"
                      select="if ($x/self::css:box[@name]) then $x/@name else name($x)"/>
        <xsl:sequence select="if ($x/self::attribute())
                              then concat(pxi:get-path($x/parent::*),'/@',$name)
                              else if ($x/parent::*)
                              then concat(pxi:get-path($x/parent::*),'/',$name,'[',(count($x/preceding-sibling::*)+1),']')
                              else concat('/',$name)"/>
    </xsl:function>
    
    <xsl:variable name="pxi:mode"><pxi:mode/></xsl:variable>
    <xsl:template match="pxi:mode">#default</xsl:template>
    <xsl:template match="pxi:mode" mode="sequence">sequence</xsl:template>
    <xsl:template match="pxi:mode" mode="table">table</xsl:template>
    <xsl:template match="pxi:mode" mode="tr">tr</xsl:template>
    <xsl:template match="pxi:mode" mode="td">td</xsl:template>
    <xsl:template match="pxi:mode" mode="table-of-contents">table-of-contents</xsl:template>
    
    <!-- ============================= -->
    <!-- eval-volume-area-content-list -->
    <!-- ============================= -->
    
    <xsl:template match="css:string[@value]" mode="eval-volume-area-content-list">
        <css:box type="inline">
            <xsl:value-of select="@value"/>
        </css:box>
    </xsl:template>
    
    <xsl:template match="css:flow[@from]" mode="eval-volume-area-content-list">
        <xsl:variable name="flow" as="xs:string" select="@from"/>
        <xsl:sequence select="collection()/*[@css:flow=$flow]"/>
    </xsl:template>
    
    <xsl:template match="css:attr|
                         css:content|
                         css:string[@name][not(@target)]|
                         css:counter[not(@target)]|
                         css:text[@target]|
                         css:string[@name][@target]|
                         css:counter[@target]|
                         css:leader"
                  mode="eval-volume-area-content-list">
        <xsl:message select="concat(
                               if (@target) then 'target-' else '',
                               local-name(),
                               '() function not supported in volume area')"/>
    </xsl:template>
    
    <xsl:template match="*" mode="eval-volume-area-content-list">
        <xsl:message terminate="yes">Coding error</xsl:message>
    </xsl:template>
    
    <!-- ======================== -->
    <!-- OBFL evaluation language -->
    <!-- ======================== -->
    
    <xsl:function name="obfl:not" as="xs:string">
        <xsl:param name="sexpr" as="xs:string"/>
        <xsl:sequence select="if ($sexpr='nil') then 't'
                              else if ($sexpr='t') then 'nil'
                              else concat('(! ',$sexpr,')')"/>
    </xsl:function>
    
    <xsl:function name="obfl:and" as="xs:string">
        <xsl:param name="sexprs" as="xs:string*"/>
        <xsl:variable name="sexprs2" as="xs:string*" select="distinct-values($sexprs)[not(.='t')]"/>
        <xsl:sequence select="if (not(exists($sexprs2))) then 't'
                              else if ('nil'=$sexprs2) then 'nil'
                              else if (count($sexprs2)=1) then $sexprs2[1]
                              else concat('(&amp; ',string-join($sexprs2,' '),')')"/>
    </xsl:function>
    
    <xsl:function name="obfl:or" as="xs:string">
        <xsl:param name="sexprs" as="xs:string*"/>
        <xsl:variable name="sexprs2" as="xs:string*" select="distinct-values($sexprs)[not(.='nil')]"/>
        <xsl:sequence select="if (not(exists($sexprs2))) then 'nil'
                              else if ('t'=$sexprs2) then 't'
                              else if (count($sexprs2)=1) then $sexprs2[1]
                              else concat('(| ',string-join($sexprs2,' '),')')"/>
    </xsl:function>

</xsl:stylesheet>
