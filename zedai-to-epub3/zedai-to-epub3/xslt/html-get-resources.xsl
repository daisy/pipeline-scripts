<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:h="http://www.w3.org/1999/xhtml" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    version="2.0" exclude-result-prefixes="#all">

    <xsl:output indent="yes" method="xml"/>
    <xsl:template match="/*">
        <d:fileset xml:base="{replace(base-uri(),'^(.+/)[^/]*','$1')}">
            <xsl:apply-templates/>
        </d:fileset>
    </xsl:template>

    <xsl:template match="processing-instruction('xml-stylesheet')">
        <xsl:variable name="href" select="replace(.,'^.*href=(&amp;apos;|&quot;)(.*?)\1.*$','$2')"/>
        <xsl:variable name="type" select="replace(.,'^.*type=(&amp;apos;|&quot;)(.*?)\1.*$','$2')"/>
        <xsl:variable name="inferredType">
            <xsl:choose>
                <xsl:when test="$type">
                    <xsl:value-of select="$type"/>
                </xsl:when>
                <xsl:when test="ends-with(lower-case($href),'.css')">
                    <xsl:value-of select="'text/css'"/>
                </xsl:when>
                <xsl:when
                    test="ends-with(lower-case($href),'.xsl') or ends-with(lower-case($href),'.xslt')">
                    <xsl:value-of select="'application/xslt+xml'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$inferredType">
            <d:file href="{$href}" media-type="{$inferredType}"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="h:link[not(matches(@href,'^[a-z]+:'))]">
        <xsl:choose>
            <xsl:when test="ends-with(lower-case(@href),'.css')">
                <d:file href="{@href}" media-type="text/css"/>
            </xsl:when>
            <xsl:otherwise>
                <d:file href="{@href}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="h:img">
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="ends-with(lower-case(@src),'.jpg')"
                    ><![CDATA[image/jpeg]]></xsl:when>
                <xsl:when test="ends-with(lower-case(@src),'.jpeg')"
                    ><![CDATA[image/jpeg]]></xsl:when>
                <xsl:when test="ends-with(lower-case(@src),'.png')"><![CDATA[image/png]]></xsl:when>
                <xsl:when test="ends-with(lower-case(@src),'.gif')"><![CDATA[image/gif]]></xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$type">
            <d:file href="{@src}" media-type="{$type}"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="text()"/>


</xsl:stylesheet>
