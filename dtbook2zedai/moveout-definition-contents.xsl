<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/" exclude-result-prefixes="dtb" version="2.0">


    <!--Move target element out into the parent 'item' and split the 'dd' element that used
            to contain it. 
    -->

    <xsl:output indent="yes" method="xml"/>

    <xsl:include href="moveout-template.xsl"/>

    <xsl:param name="target-elements"
        select="tokenize('list,dl,div,poem,linegroup,table,sidebar,note,epigraph', ',')"/>

    <xsl:template match="/">
        <xsl:message>normalize definitions in definition lists</xsl:message>
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


</xsl:stylesheet>
