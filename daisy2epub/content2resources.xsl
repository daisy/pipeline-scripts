<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:h="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" version="2.0"
    exclude-result-prefixes="#all">
    
    <xsl:template match="/*">
        <c:manifest>
            <xsl:for-each select="/processing-instruction('xml-stylesheet')">
                <xsl:variable name="href"
                    select="replace(.,'^.*href=(&amp;apos;|&quot;)(.*?)\1.*$','$2')"/>
                <xsl:variable name="type"
                    select="replace(.,'^.*type=(&amp;apos;|&quot;)(.*?)\1.*$','$2')"/>
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
                    <c:entry href="{$href}" media-type="{$inferredType}"/>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="//h:link[ends-with(lower-case(@href),'.css')]">
                <c:entry href="{@href}" media-type="text/css"/>
            </xsl:for-each>
            <xsl:for-each select="//h:img">
                <xsl:variable name="type">
                    <xsl:choose>
                        <xsl:when test="ends-with(lower-case(@src),'.jpg')"
                            ><![CDATA[image/jpeg]]></xsl:when>
                        <xsl:when test="ends-with(lower-case(@src),'.jpeg')"
                            ><![CDATA[image/jpeg]]></xsl:when>
                        <xsl:when test="ends-with(lower-case(@src),'.png')"
                            ><![CDATA[image/png]]></xsl:when>
                        <xsl:when test="ends-with(lower-case(@src),'.gif')"
                            ><![CDATA[image/gif]]></xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="$type">
                    <c:entry href="{@src}" media-type="{$type}"/>
                </xsl:if>
            </xsl:for-each>
        </c:manifest>
    </xsl:template>
    
</xsl:stylesheet>
