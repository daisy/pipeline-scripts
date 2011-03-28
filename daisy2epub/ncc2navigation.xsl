<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2011/epub"
    version="2.0" exclude-result-prefixes="#all">

    <!--
        TODO:
            - possible improvement: infer more comprehensive TOC from all document files,
              and mark those that are not referenced in the NCC with display:none.
    -->

    <xsl:output xpath-default-namespace="http://www.w3.org/1999/xhtml"/>

    <xsl:template match="/*">
        <xsl:element name="html">
            <xsl:attribute name="profile" select="'http://www.idpf.org/epub/30/profile/content/'"/>
            <xsl:apply-templates select="@*|*"/>
        </xsl:element>
    </xsl:template>

    <!-- TODO: remove this identity template? -->
    <xsl:template match="@*|node()">
        <xsl:choose>
            <xsl:when test="self::*">
                <xsl:element name="{local-name()}">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="html:body">
        <body>
            <xsl:element name="nav">
                <xsl:attribute name="epub:type" select="'toc'"/>
                <xsl:attribute name="id" select="'toc'"/>
                <xsl:element name="ol">
                    <xsl:call-template name="make-toc-level">
                        <xsl:with-param name="level" select="'h1'"/>
                        <xsl:with-param name="group" select="child::*"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:element>
            <xsl:if test="child::html:span">
                <xsl:element name="nav">
                    <xsl:attribute name="epub:type" select="'page-list'"/>
                    <xsl:attribute name="style" select="'display:none'"/>
                    <xsl:element name="ol">
                        <xsl:for-each select="child::html:span">
                            <xsl:element name="li">
                                <a href="{child::html:a[1]/@href}">
                                    <xsl:if test="@id">
                                        <xsl:attribute name="id" select="@id"/>
                                    </xsl:if>
                                    <xsl:value-of select="child::html:a[1]"/>
                                </a>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            <xsl:if test="child::html:div">
                <xsl:element name="nav">
                    <xsl:attribute name="epub:type" select="'landmarks'"/>
                    <xsl:element name="ol">
                        <xsl:for-each select="child::html:div">
                            <xsl:element name="li">
                                <a href="{child::html:a[1]/@href}">
                                    <xsl:if test="@id">
                                        <xsl:attribute name="id" select="@id"/>
                                    </xsl:if>
                                    <xsl:value-of select="child::html:a[1]"/>
                                </a>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </body>
    </xsl:template>

    <xsl:template name="make-toc-level">
        <xsl:param name="level" required="yes"/>
        <xsl:param name="skipFirst" select="false()"/>
        <xsl:param name="group" required="yes"/>
        <xsl:if test="$level">
            <xsl:for-each-group select="$group" group-starting-with="*[local-name()=$level]">
                <xsl:choose>
                    <xsl:when test="current-group()[1]/local-name()=$level">
                        <xsl:element name="li">
                            <xsl:apply-templates select="current-group()[1]"/>
                            <xsl:if test="current-group()[position()>1]">
                                <xsl:element name="ol">
                                    <xsl:call-template name="make-toc-level">
                                        <xsl:with-param name="skipFirst" select="true()"/>
                                        <xsl:with-param name="level"
                                            select="if ($level='h1') then 'h2' else if ($level='h2') then 'h3' else if ($level='h3') then 'h4' else if ($level='h4') then 'h5' else 'h6'"/>
                                        <xsl:with-param name="group"
                                            select="current-group()[position()>1]"/>
                                    </xsl:call-template>
                                </xsl:element>
                            </xsl:if>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="make-toc-level">
                            <xsl:with-param name="level"
                                select="if ($level='h1') then 'h2' else if ($level='h2') then 'h3' else if ($level='h3') then 'h4' else if ($level='h4') then 'h5' else if ($level='h5') then 'h6' else false()"/>
                            <xsl:with-param name="group" select="current-group()"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:if>
    </xsl:template>

    <xsl:template
        match="html:*[self::html:h1 or self::html:h2 or self::html:h3 or self::html:h4 or self::html:h5 or self::html:h6]">
        <a href="{child::html:a[1]/@href}">
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <xsl:value-of select="child::html:a[1]"/>
        </a>
    </xsl:template>

</xsl:stylesheet>
