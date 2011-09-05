<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf"
    exclude-result-prefixes="#all" version="2.0">

    <xsl:param name="pub-id" required="yes"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <opf:metadata>
            <dc:identifier id="pub-id">
                <xsl:value-of select="$pub-id"/>
            </dc:identifier>
            <dc:title id="title">
                <xsl:value-of select="//html:head/html:meta[@name='dc:title']/@content"/>
            </dc:title>
            <dc:language>
                <xsl:value-of select="//html:head/html:meta[@name='dc:language']/@content"/>
            </dc:language>
            <dc:date id="date">
                <xsl:value-of select="//html:head/html:meta[@name='dc:date']/@content"/>
            </dc:date>
            <opf:meta refines="#date" property="scheme">
                <xsl:value-of select="//html:head/html:meta[@name='dc:date']/@scheme"/>
            </opf:meta>
            <opf:meta property="dcterms:modified">
                <xsl:value-of select="current-dateTime()"/>
            </opf:meta>
            <dc:format>EPUB3</dc:format>
            <xsl:for-each select="//html:head/html:meta">
                <xsl:if test="not(@name='dc:identifier' or @name='dc:title' or @name='dc:language' or
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
                            <xsl:if test="@scheme">
                                <opf:meta refines="#{if (@name='dc:identifier') then 'pub-id' else concat('meta_',position())}" property="scheme">
                                    <xsl:value-of select="@scheme"/>
                                </opf:meta>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="@name">
                            <opf:meta property="{@name}">
                                <xsl:if test="@scheme">
                                    <xsl:attribute name="scheme" select="@scheme"/>
                                </xsl:if>
                                <xsl:value-of select="@content"/>
                            </opf:meta>
                        </xsl:when>
                    </xsl:choose>
                    
                </xsl:if>
            </xsl:for-each>
        </opf:metadata>
    </xsl:template>

</xsl:stylesheet>
