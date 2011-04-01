<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:opf="http://www.idpf.org/2007/opf" exclude-result-prefixes="#all" version="2.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <opf:metadata>
            <dc:identifier id="pub-id">
                <xsl:value-of select="//c:meta[@name='dc:identifier']/@content"/>
            </dc:identifier>
            <dc:title id="title">
                <xsl:value-of select="//c:meta[@name='dc:title']/@content"/>
            </dc:title>
            <dc:language>
                <xsl:value-of select="//c:meta[@name='dc:language']/@content"/>
            </dc:language>
            <dc:date id="date">
                <xsl:value-of select="//c:meta[@name='dc:date']/@content"/>
            </dc:date>
            <meta about="#date" property="scheme">
                <xsl:value-of select="//c:meta[@name='dc:date']/@scheme"/>
            </meta>
            <meta property="dcterms:modified">{TODO: ignore dynamically created time}</meta>
            <dc:format>ePub3</dc:format>
            <xsl:for-each select="//c:meta">
                <xsl:if
                    test="not(@name='dc:identifier' or @name='dc:title' or @name='dc:language' or
                              @name='dcterms:modified' or @name='dc:format' or @name='dc:date')">
                    <xsl:choose>
                        <xsl:when test="starts-with(@name,'dc:')">
                            <xsl:element name="{@name}">
                                    <xsl:choose>
                                        <xsl:when test="@name='dc:identifier'">
                                            <xsl:attribute name="id" select="'pub-id'"/>
                                        </xsl:when>
                                        <xsl:when test="@scheme">
                                            <xsl:attribute name="id" select="concat('meta_',position())"/>
                                        </xsl:when>
                                    </xsl:choose>
                                <xsl:value-of select="@content"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <meta property="{@name}">
                                <xsl:if test="@scheme">
                                    <xsl:attribute name="id" select="concat('meta_',position())"/>
                                </xsl:if>
                                <xsl:value-of select="@content"/>
                            </meta>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="@scheme">
                        <meta about="#{if (@name='dc:identifier') then 'pub-id' else concat('meta_',position())}" property="scheme">
                            <xsl:value-of select="@scheme"/>
                        </meta>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </opf:metadata>
    </xsl:template>

</xsl:stylesheet>
