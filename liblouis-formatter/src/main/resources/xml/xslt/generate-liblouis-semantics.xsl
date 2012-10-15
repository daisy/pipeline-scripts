<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    exclude-result-prefixes="xs louis brl css"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="no"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/utilities/xslt/encoding-functions.xsl" />
    
    <xsl:template match="/">
        <louis:semantics>
            <xsl:choose>
                <xsl:when test="/louis:toc">
                    <xsl:for-each select="distinct-values(//*[@css:toc-item]/@louis:style/string())">
                        <xsl:value-of select="concat('heading', position())"/>
                        <xsl:text> &amp;xpath(//louis:toc-item[@louis:style='</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>'])&#xa;</xsl:text>
                    </xsl:for-each>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>namespaces </xsl:text>
                    <xsl:text>louis=http://liblouis.org/liblouis&#xa;</xsl:text>
                    <xsl:text>document </xsl:text>
                    <xsl:value-of select="local-name(/*)"/>
                    <xsl:text>&#xa;&#xa;</xsl:text>
                    <xsl:for-each select="distinct-values(//louis:border/@louis:style/string())">
                        <xsl:text>boxline &amp;xpath(//louis:border[@louis:style='</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>']) </xsl:text>
                        <xsl:value-of select="brl:unicode-braille-to-nabcc(.)"/>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:for-each>
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:for-each select="distinct-values(//*[not(self::louis:border)]/@louis:style/string())">
                        <xsl:if test="starts-with(., '#')">
                            <xsl:value-of select="substring-after(., '#')"/>
                            <xsl:text> &amp;xpath(//*[@louis:style='</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>'])&#xa;</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </louis:semantics>
    </xsl:template>
    
</xsl:stylesheet>