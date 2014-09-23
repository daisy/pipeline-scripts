<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="css:_/@css:string-set|
                         css:_/@css:string-entry|
                         css:root/@css:string-set|
                         css:root/@css:string-entry"/>
    
    <xsl:template match="css:box">
        <xsl:variable name="count" select="count(following::css:box|descendant::css:box)"/>
        <xsl:variable name="pending" as="attribute()*"
                      select="for $e in (//css:_|//css:root)[count(following::css:box|descendant::css:box)=$count+1]
                              return ($e/@css:string-entry,$e/@css:string-set)"/>
        <xsl:choose>
            <xsl:when test="exists($pending)">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:attribute name="css:string-entry" select="string-join(($pending, @css:string-entry), ', ')"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
