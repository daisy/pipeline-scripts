<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd dtb" version="2.0"
    xmlns:p2="http://code.google.com/p/daisy-pipeline/">
    <!-- TODO: what's the official namespace for pipeline2? -->

    <xd:doc>
        <xd:desc>Move target element out into the parent 'item' and split the 'dd' element that used
            to contain it. This is a simplified non-recursive version of
            normalize-generic-moveout.xsl</xd:desc>

    </xd:doc>

    <xsl:output indent="yes" method="xml"/>
    <xsl:param name="target-elements"
        select="tokenize('list,dl,div,poem,linegroup,table,sidebar,note,epigraph', ',')"/>

    <xsl:template match="/">
        <xsl:message>normalize-deflist-2</xsl:message>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="dtb:item/dtb:dd[dtb:list]">
        <xsl:message>Found unsuitable parent: {<xsl:value-of select="name()"/>}, id={<xsl:value-of
                select="@id"/>}</xsl:message>
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name-to-move">dtb:list</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dtb:item/dtb:dd[dtb:dl]">
        <xsl:message>Found unsuitable parent: {<xsl:value-of select="name()"/>}, id={<xsl:value-of
                select="@id"/>}</xsl:message>
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name-to-move">dtb:dl</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dtb:item/dtb:dd[dtb:div]">
        <xsl:message>Found unsuitable parent: {<xsl:value-of select="name()"/>}, id={<xsl:value-of
                select="@id"/>}</xsl:message>
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name-to-move">dtb:div</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dtb:item/dtb:dd[dtb:poem]">
        <xsl:message>Found unsuitable parent: {<xsl:value-of select="name()"/>}, id={<xsl:value-of
                select="@id"/>}</xsl:message>
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name-to-move">dtb:poem</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dtb:item/dtb:dd[dtb:linegroup]">
        <xsl:message>Found unsuitable parent: {<xsl:value-of select="name()"/>}, id={<xsl:value-of
                select="@id"/>}</xsl:message>
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name-to-move">dtb:linegroup</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dtb:item/dtb:dd[dtb:table]">
        <xsl:message>Found unsuitable parent: {<xsl:value-of select="name()"/>}, id={<xsl:value-of
                select="@id"/>}</xsl:message>
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name-to-move">table</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dtb:item/dtb:dd[dtb:sidebar]">
        <xsl:message>Found unsuitable parent: {<xsl:value-of select="name()"/>}, id={<xsl:value-of
                select="@id"/>}</xsl:message>
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name-to-move">dtb:sidebar</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dtb:dd/dtb:item[dtb:note]">
        <xsl:message>Found unsuitable parent: {<xsl:value-of select="name()"/>}, id={<xsl:value-of
                select="@id"/>}</xsl:message>
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name-to-move">dtb:note</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dtb:dd/dtb:item[dtb:epigraph]">
        <xsl:message>Found unsuitable parent: {<xsl:value-of select="name()"/>}, id={<xsl:value-of
                select="@id"/>}</xsl:message>
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name-to-move">dtb:epigraph</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="move-elem-out">
        <xsl:param name="elem-name-to-move"/>
        <xsl:message>Moving child element: <xsl:value-of select="$elem-name-to-move"/></xsl:message>
        <xsl:message>The element itself: <xsl:value-of select="."/></xsl:message>
        <xsl:variable name="elem" select="."/>
        <xsl:variable name="first-child" select="child::node()[1]"/>

        <!-- move the element out a level -->
        <xsl:for-each-group select="*|text()[normalize-space()]"
            group-adjacent="local-name() = $elem-name-to-move">
            <xsl:choose>
                <!-- the target element itself-->
                <xsl:when test="current-grouping-key()">
                    <xsl:copy-of select="current-group()"/>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:element name="{local-name($elem)}"
                        namespace="http://www.daisy.org/z3986/2005/dtbook/">

                        <xsl:apply-templates select="$elem/@*"/>

                        <!-- for all except the first 'copy' of the original parent:
                                    don't copy the node's ID since then it will result in many nodes with the same ID -->
                        <xsl:if
                            test="not(position() = 1 or local-name($first-child) = $elem-name-to-move)">
                            <xsl:if test="$elem/@id">
                                <!-- modifying the result of generate-id() by adding a character to the end
                                            seems to correct the problem of it not being unique; however, this 
                                            is an issue that should be explored in-depth -->
                                <xsl:variable name="tmp" select="concat(generate-id(), 'z')"/>
                                <xsl:message>Generating ID <xsl:value-of select="$tmp"
                                    /></xsl:message>
                                <xsl:attribute name="id" select="$tmp"/>
                            </xsl:if>
                        </xsl:if>

                        <xsl:apply-templates select="current-group()"/>

                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>
