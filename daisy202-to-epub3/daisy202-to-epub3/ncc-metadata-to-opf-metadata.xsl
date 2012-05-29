<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:opf="http://www.idpf.org/2007/opf" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

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
            <opf:meta property="dcterms:modified">
                <xsl:value-of
                    select="format-dateTime(
                    adjust-dateTime-to-timezone(current-dateTime(),xs:dayTimeDuration('PT0H')),
                    '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][Z]')"
                />
            </opf:meta>
            <dc:format>EPUB3</dc:format>
            <xsl:for-each select="//html:head/html:meta">
                <xsl:if
                    test="not(@name='dc:identifier' or @name='dc:title' or @name='dc:language' or
                              @name='dcterms:modified' or @name='dc:format' or @name='dc:date')">
                    <xsl:choose>
                        <xsl:when test="@http-equiv"/>
                        <xsl:when test="starts-with(@name,'dc:')">
                            <xsl:if test="string-length(normalize-space(@content)) &gt; 0">
                                <xsl:element name="{@name}">
                                    <xsl:choose>
                                        <xsl:when test="@name='dc:identifier'">
                                            <xsl:attribute name="id" select="'pub-id'"/>
                                        </xsl:when>
                                        <!--<xsl:when test="@scheme">
                                            <xsl:attribute name="id" select="concat('meta_',position())"/>
                                        </xsl:when>-->
                                    </xsl:choose>
                                    <xsl:value-of select="@content"/>
                                </xsl:element>
                                <xsl:if test="@scheme">
                                    <!-- TODO: handle different schemes for different metadata -->
                                    <!--<opf:meta refines="#{if (@name='dc:identifier') then 'pub-id' else concat('meta_',position())}" property="role" scheme="???">
                                    <xsl:value-of select="@scheme"/>
                                </opf:meta>-->
                                </xsl:if>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="starts-with(@name,'ncc:')">
                            <xsl:choose>
                                <xsl:when test="@name='ncc:narrator'">
                                    <xsl:variable name="id"
                                        select="if (count(preceding-sibling::*/starts-with(@id,'narrator')) &gt; 0) then generate-id() else concat('narrator_',(count(preceding-sibling::*/@name='ncc:narrator')+1))"/>
                                    <xsl:if test="string-length(normalize-space(@content)) &gt; 0">
                                        <dc:contributor id="{$id}">
                                            <xsl:value-of select="@content"/>
                                        </dc:contributor>
                                        <opf:meta refines="#{$id}" property="role" scheme="marc:relators">nrt</opf:meta>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="@name='ncc:producer'">
                                    <xsl:variable name="id"
                                        select="if (count(preceding-sibling::*/starts-with(@id,'producer')) &gt; 0) then generate-id() else concat('producer_',(count(preceding-sibling::*/@name='ncc:producer')+1))"/>
                                    <xsl:if test="string-length(normalize-space(@content)) &gt; 0">
                                        <dc:contributor id="{$id}">
                                            <xsl:value-of select="@content"/>
                                        </dc:contributor>
                                        <opf:meta refines="#{$id}" property="role" scheme="marc:relators">pro</opf:meta>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="@name='ncc:producedDate'"><!-- TODO --></xsl:when>
                                <xsl:when test="@name='ncc:revision'"><!-- TODO --></xsl:when>
                                <xsl:when test="@name='ncc:revisionDate'"><!-- TODO --></xsl:when>
                                <xsl:when test="@name='ncc:sourceDate'"><!-- TODO --></xsl:when>
                                <xsl:when test="@name='ncc:sourceEdition'"><!-- TODO --></xsl:when>
                                <xsl:when test="@name='ncc:sourcePublisher'"><!-- TODO --></xsl:when>
                                <xsl:when test="@name='ncc:sourceRights'"><!-- TODO --></xsl:when>
                                <xsl:when test="@name='ncc:sourceTitle'"><!-- TODO --></xsl:when>
                                <!-- Other ncc: metadata are irrelevant or inappropriate to include in the EPUB3 version. -->
                            </xsl:choose>
                        </xsl:when>
                        <!-- Metadata in other namespaces than dc: and ncc: are dropped. TODO: find a proper way to include metadata from other namespaces? -->
                        <xsl:when test="not(contains(@name,':')) and string-length(@name) &gt; 0">
                            <xsl:if test="string-length(@content) &gt; 0">
                                <opf:meta property="{@name}">
                                    <!-- TODO: try handling schemes for arbitrary metadata? -->
                                    <!--<xsl:if test="@scheme">
                                    <xsl:attribute name="scheme" select="@scheme"/>
                                </xsl:if>-->
                                    <xsl:value-of select="@content"/>
                                </opf:meta>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>

                </xsl:if>
            </xsl:for-each>
        </opf:metadata>
    </xsl:template>

</xsl:stylesheet>
