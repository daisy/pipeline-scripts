<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
    xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>

    <xsl:output indent="yes"/>


    <!--TODO implement a custom HTML-compliant base-uri() function-->
    <xsl:variable name="doc-base"
        select="if (/html/head/base[@href][1]) then resolve-uri(normalize-space(/html/head/base[@href][1]/@href),base-uri(/)) else base-uri(/)"/>


    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>


    <!--TODO handle SVG references-->
    <!--TODO replace type inference by media type functions-->
    <!--TODO replace URI patterns by uri-utils functions-->


    <!--<xsl:template match="/processing-instruction('xml-stylesheet')">
        <xsl:variable name="href" select="replace(.,'^.*href=(&amp;apos;|&quot;)(.*?)\1.*$','$2')"/>
        <xsl:variable name="type" select="replace(.,'^.*type=(&amp;apos;|&quot;)(.*?)\1.*$','$2')"/>
        <!-\-TODO-\->
        <xsl:copy-of select="."/>
    </xsl:template>-->

    <xsl:template match="link">
        <!--
            External resources: icon, prefetch, stylesheet + pronunciation
            Hyperlinks:  alternate, author, help, license, next, prev, search
        -->
        <!--Note: outbound hyperlinks that resolve outside the EPUB Container are not Publication Resources-->
        <!--TODO warning for remote external resources, ignore remote hyperlinks -->
        <xsl:variable name="rel" as="xs:string*" select="tokenize(@rel,'\s+')"/>
        <xsl:choose>
            <xsl:when
                test="$rel='stylesheet' and not(@type='text/css' or matches(@href,'.*\.css\s*$','i'))">
                <xsl:message>[WARNING] Discarding stylesheet '<xsl:value-of select="@href"/>' of
                    unknown type.</xsl:message>
            </xsl:when>
            <xsl:when
                test="$rel='pronunciation' and not(@type='application/pls+xml' or matches(@href,'.*\.pls\s*$','i'))">
                <xsl:message>[WARNING] Discarding pronunciation lexicon '<xsl:value-of
                        select="@href"/>' of unknown type.</xsl:message>
            </xsl:when>
            <xsl:when test="pf:is-relative(@href) and not($rel=('stylesheet','pronunciation'))">
                <xsl:message>[WARNING] Discarding local link '<xsl:value-of select="@href"/>' of
                    unsupported relation type '<xsl:value-of select="@rel"/>'.</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <link href="{f:safe-uri(@href)}" data-original-href="{normalize-space(@href)}">
                    <xsl:copy-of select="@* except @href | node()"/>
                </link>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--<xsl:template match="style">
        <!-\-TODO parse refs in inlined CSS-\->
    </xsl:template>-->

    <!--<xsl:template match="script[@src]">
        <!-\-TODO handle 'script' with @src-\->
    </xsl:template>-->

    <xsl:template match="a[@href]">
        <xsl:choose>
            <xsl:when
                test="pf:is-relative(@href) and not(pf:file-exists(pf:unescape-uri(pf:get-path(@href))))"
                use-when="function-available('pf:file-exists')">

                <xsl:message>[WARNING] Discarding link to non-existing resource '<xsl:value-of
                        select="@src"/>'.</xsl:message>
                <span>
                    <xsl:copy-of select="@* except (@href|@target|@rel|@media|@targetlang|@type)"/>
                    <xsl:apply-templates select="node()"/>
                </span>
            </xsl:when>
            <xsl:when
                test="false()">
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="img[@src]">
        <!--TODO handle 'img'-->
        <xsl:choose>
            <xsl:when test="pf:is-absolute(@src)">
                <xsl:message>[WARNING] Replacing remote image '<xsl:value-of select="@src"/>' by
                    alternative text.</xsl:message>
                <span>
                    <xsl:copy-of
                        select="@* except (@alt|@src|@crossorigin|@usemap|@ismap|@width|@height)"/>
                    <xsl:value-of select="@alt"/>
                </span>
            </xsl:when>
            <xsl:when test="not(matches(@src,'^.*\.(png|jpe?g|gif|svg)\s*$'))">
                <xsl:message>[WARNING] The type of image '<xsl:value-of select="@src"/>' is not a
                    core EPUB media type. Replacing by alternative text.</xsl:message>
                <span>
                    <xsl:copy-of
                        select="@* except (@alt|@src|@crossorigin|@usemap|@ismap|@width|@height)"/>
                    <xsl:value-of select="@alt"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <img src="{f:safe-uri(@src)}" data-original-href="{normalize-space(@src)}">
                    <xsl:copy-of select="@* except @src | node()"/>
                </img>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--<xsl:template match="iframe">
        <!-\-TODO handle 'iframe'-\->
    </xsl:template>-->

    <!--<xsl:template match="embed">
        <!-\-TODO handle 'embed'(note: no content fallback)-\->
    </xsl:template>-->

    <!--<xsl:template match="object">
        <!-\-TODO handle 'object' with @data-\->
    </xsl:template>-->

    <!--TODO handle audio-->
    <!--TODO handle video-->

    <!--<xsl:template match="source">
        <!-\-TODO handle 'source'-\->
    </xsl:template>-->

    <!--<xsl:template match="track">
        <!-\-TODO handle 'track'-\->
    </xsl:template>-->

    <xsl:function name="f:safe-uri" as="xs:string">
        <xsl:param name="uri" as="xs:string"/>
        <xsl:sequence
            select="pf:replace-path($uri,escape-html-uri(replace(pf:unescape-uri(pf:get-path($uri)),'[^\p{L}\p{N}\-/_.]','_')))"
        />
    </xsl:function>
</xsl:stylesheet>
