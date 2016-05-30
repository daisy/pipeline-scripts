<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:css="http://www.daisy.org/ns/pipeline/braille-css">

    <xsl:output indent="yes"/>

    <xsl:template match="/*" priority="2">
        <!--The output is a sequence of one or more documents and is the result of splitting the
            input document before or after the split points specified with the 'split-before' and
            'split-after' options. Splitting before an element means duplicating the document,
            deleting the element and its following nodes from the first copy, and deleting the
            elements's preceding nodes from the second copy. Similarly, splitting after an element
            means deleting the element and its preceding nodes from the second copy and deleting the
            element's following nodes from the first copy. css:box elements that are split get a
            part attribute with value 'first', 'middle' or 'last'. The attributes css:id,
            css:string-set, css:string-entry, css:counter-set, css:counter-reset,
            css:counter-increment, css:counter-set-*, css:counter-reset-* and
            css:counter-increment-* are omitted on css:box elements with a part attribute equal to
            'middle' or 'last'.-->
        <_>
            <xsl:variable name="split-before" select="//node()[@pxi:split-before='true' or (preceding::node()[1] | preceding-sibling::node()[1])/@pxi:split-after='true']" as="node()*"/>

            <xsl:choose>
                <xsl:when test="not($split-before)">
                    <xsl:copy-of select="."/>
                </xsl:when>
                <xsl:otherwise>

                    <xsl:variable name="doc" select="/*"/>
                    <xsl:for-each select="$split-before">
                        <xsl:variable name="position" select="position()"/>
                        <xsl:variable name="nodes"
                            select="if (position() = 1) then preceding::node() else $split-before[$position - 1]/(following::node() | descendant-or-self::node()) intersect preceding::node()"/>
                        <xsl:element name="{$doc/name()}">
                            <xsl:apply-templates select="$doc/@*"/>
                            <xsl:apply-templates select="$doc/node()">
                                <xsl:with-param name="nodes" select="$nodes"/>
                            </xsl:apply-templates>
                        </xsl:element>
                    </xsl:for-each>

                    <xsl:variable name="nodes" select="$split-before[last()]/(following::node() | descendant-or-self::node())"/>
                    <xsl:element name="{/*/name()}">
                        <xsl:apply-templates select="@*"/>
                        <xsl:apply-templates select="node()">
                            <xsl:with-param name="nodes" select="$nodes"/>
                        </xsl:apply-templates>
                    </xsl:element>

                </xsl:otherwise>
            </xsl:choose>
        </_>
    </xsl:template>

    <xsl:template match="@* | text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="@pxi:*"/>

    <xsl:template match="node()">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:if test="(. | descendant::node()) intersect $nodes">
            <xsl:copy>

                <!-- if css:box => determine first/middle/last -->
                <xsl:choose>
                    <xsl:when test="self::css:box and (not(node()) or not(descendant-or-self::node() intersect $nodes) or . intersect $nodes or node()[1] intersect $nodes)">
                        <xsl:apply-templates select="@* except @xml:id"/>
                        <xsl:if test="not(node()[last()] intersect $nodes)">
                            <!-- only add @part if the css:box is being split -->
                            <xsl:attribute name="part" select="'first'"/>
                        </xsl:if>

                    </xsl:when>
                    <xsl:when test="self::css:box and node()[last()] intersect $nodes">
                        <xsl:apply-templates select="@* except (@xml:id | @css:id | @css:string-set | @css:string-entry | @css:*[starts-with(local-name(),'counter')])"/>
                        <xsl:attribute name="part" select="'last'"/>

                    </xsl:when>
                    <xsl:when test="self::css:box">
                        <xsl:apply-templates select="@* except (@xml:id | @css:id | @css:string-set | @css:string-entry | @css:*[starts-with(local-name(),'counter')])"/>
                        <xsl:attribute name="part" select="'middle'"/>

                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="@* except @xml:id"/>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- only add xml:id to first copy of element -->
                <xsl:if test=". intersect $nodes">
                    <xsl:copy-of select="@xml:id"/>
                </xsl:if>

                <xsl:apply-templates select="node()">
                    <xsl:with-param name="nodes" select="$nodes"/>
                </xsl:apply-templates>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
