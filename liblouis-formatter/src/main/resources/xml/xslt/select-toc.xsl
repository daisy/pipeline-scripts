<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="xs louis css"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="select" select="1"/>
    
    <xsl:variable name="toc" as="element()" select="/descendant::louis:toc[number($select)]"/>
    
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <louis:no-pagenum>
                <louis:toc>
                    <xsl:text>&#xA0;</xsl:text>
                </louis:toc>
            </louis:no-pagenum>
            <xsl:apply-templates select="child::node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@xml:id]">
        <xsl:variable name="id" as="xs:string" select="@xml:id"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="$toc//*[@css:toc-item and @ref=$id]">
                    <louis:toc-item>
                        <xsl:copy-of select="$toc//*[@css:toc-item and @ref=$id]/@louis:style"/>
                        <xsl:apply-templates select="node()"/>
                    </louis:toc-item>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>