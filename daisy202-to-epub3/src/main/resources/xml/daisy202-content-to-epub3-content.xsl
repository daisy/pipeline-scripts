<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" exclude-result-prefixes="#all" version="2.0">

    <xsl:param name="content-dir" required="yes"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="h:meta"/>

    <xsl:template match="h:a">
        <xsl:variable name="a-href" select="tokenize(@href,'#')[1]"/>
        <xsl:variable name="a-fragment" select="if (contains(@href,'#')) then tokenize(@href,'#')[last()] else ''"/>
        <xsl:variable name="self-id" select="ancestor-or-self::*/@id"/>
        <xsl:choose>
            <xsl:when test="starts-with(@href,'#') or not(matches($a-href,'^[^/]+:')) and resolve-uri(replace($a-href,'\.html$','.xhtml'),$content-dir) = /*/@xml:base">
                <!-- is link to the same document -->
                <xsl:choose>
                    <xsl:when test="$a-fragment = ('',$self-id)">
                        <!-- is link to the same part of the document (or no part of the document); replace the link with a span -->
                        <span xmlns="http://www.w3.org/1999/xhtml">
                            <xsl:apply-templates select="@*|node()"/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- is link to another part of the document; only keep the fragment part of the href -->
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:attribute name="href" select="concat('#',$a-fragment)"/>
                            <xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- links to another document; keep it as it is -->
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@class">
        <xsl:copy-of select="."/>
        <xsl:choose>
            <xsl:when test=".='title'">
                <xsl:attribute name="epub:type" select="'title'"/>
            </xsl:when>
            <xsl:when test=".='jacket'">
                <xsl:attribute name="epub:type" select="'cover'"/>
            </xsl:when>
            <xsl:when test=".='front'">
                <xsl:attribute name="epub:type" select="'frontmatter'"/>
            </xsl:when>
            <xsl:when test=".='title-page'">
                <xsl:attribute name="epub:type" select="'titlepage'"/>
            </xsl:when>
            <xsl:when test=".='copyright-page'">
                <xsl:attribute name="epub:type" select="'copyright-page'"/>
            </xsl:when>
            <xsl:when test=".='acknowledgments'">
                <xsl:attribute name="epub:type" select="'acknowledgments'"/>
            </xsl:when>
            <xsl:when test=".='prolog'">
                <xsl:attribute name="epub:type" select="'prologue'"/>
            </xsl:when>
            <xsl:when test=".='introduction'">
                <xsl:attribute name="epub:type" select="'introduction'"/>
            </xsl:when>
            <xsl:when test=".='dedication'">
                <xsl:attribute name="epub:type" select="'dedication'"/>
            </xsl:when>
            <xsl:when test=".='foreword'">
                <xsl:attribute name="epub:type" select="'foreword'"/>
            </xsl:when>
            <xsl:when test=".='preface'">
                <xsl:attribute name="epub:type" select="'preface'"/>
            </xsl:when>
            <xsl:when test=".='print-toc'">
                <xsl:attribute name="epub:type" select="'toc'"/> <!-- is this right? -->
            </xsl:when>
            <xsl:when test=".='part'">
                <xsl:attribute name="epub:type" select="'part'"/>
            </xsl:when>
            <xsl:when test=".='chapter'">
                <xsl:attribute name="epub:type" select="'chapter'"/>
            </xsl:when>
            <xsl:when test=".='section'">
                <xsl:attribute name="epub:type" select="'subchapter'"/> <!-- is this right? -->
            </xsl:when>
            <xsl:when test=".='sub-section'">
                <xsl:attribute name="epub:type" select="'division'"/> <!-- is this right? -->
            </xsl:when>
            <xsl:when test=".='minor-head'">
                <xsl:attribute name="epub:type" select="'bridgehead'"/> <!-- is this right? -->
            </xsl:when>
            <xsl:when test=".='bibliography'">
                <xsl:attribute name="epub:type" select="'bibliography'"/>
            </xsl:when>
            <xsl:when test=".='glossary'">
                <xsl:attribute name="epub:type" select="'glossary'"/> <!-- can glossterm and glossdef be inferred automatically? -->
            </xsl:when>
            <xsl:when test=".='appendix'">
                <xsl:attribute name="epub:type" select="'appendix'"/>
            </xsl:when>
            <xsl:when test=".='index'">
                <xsl:attribute name="epub:type" select="'index'"/>
            </xsl:when>
            <xsl:when test=".='index-category'">
                <!-- <xsl:attribute name="epub:type" select="''"/> ideas? -->
            </xsl:when>
            <xsl:when test=".='sidebar'">
                <xsl:attribute name="epub:type" select="'sidebar'"/>
            </xsl:when>
            <xsl:when test=".='optional-prodnote'">
                <xsl:attribute name="epub:type" select="'colophon'"/> <!-- is this right? -->
            </xsl:when>
            <xsl:when test=".='noteref'">
                <xsl:attribute name="epub:type" select="'noteref'"/>
            </xsl:when>
            <xsl:when test=".='group'">
                <!-- <xsl:attribute name="epub:type" select="''"/> ideas? -->
            </xsl:when>
            <xsl:when test=".='page-front'">
                <xsl:attribute name="epub:type" select="'pagebreak'"/> <!-- no way of distinguishing front/normal/special? -->
            </xsl:when>
            <xsl:when test=".='page-normal'">
                <xsl:attribute name="epub:type" select="'pagebreak'"/> <!-- no way of distinguishing front/normal/special? -->
            </xsl:when>
            <xsl:when test=".='page-special'">
                <xsl:attribute name="epub:type" select="'pagebreak'"/> <!-- no way of distinguishing front/normal/special? -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
