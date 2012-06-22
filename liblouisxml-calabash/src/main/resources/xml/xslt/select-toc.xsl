<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    exclude-result-prefixes="xs brl lblxml"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="select" select="1"/>
    
    <xsl:variable name="toc" as="element()" select="/descendant::lblxml:toc[number($select)]"/>
    
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <lblxml:no-pagenum>
                <xsl:sequence select="$toc/lblxml:toc-title"/>
            </lblxml:no-pagenum>
            <xsl:apply-templates select="child::node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="lblxml:toc" mode="move">
        <xsl:copy>
            <xsl:sequence select="lblxml:toc-title"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@xml:id]">
        <xsl:variable name="id" as="xs:string" select="@xml:id"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="$toc/lblxml:toc-item[@ref=$id]">
                    <lblxml:toc-item>
                        <xsl:copy-of select="$toc/lblxml:toc-item[@ref=$id]/@brl:style"/>
                        <xsl:apply-templates select="node()"/>
                    </lblxml:toc-item>
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