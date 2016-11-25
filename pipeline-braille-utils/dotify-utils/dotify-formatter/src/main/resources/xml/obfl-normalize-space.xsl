<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="@*|node()">
       <xsl:copy>
           <xsl:apply-templates select="@*|node()"/>
       </xsl:copy>
    </xsl:template>
    
    <!--
        Anticipate a bug in Dotify's white space normalization
    -->
    
    <xsl:template match="obfl:block | obfl:td">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:variable name="first-with-nonempty-string" select="(node()[descendant-or-self::text()[normalize-space()!='']])[1]"/>
            <xsl:choose>
                <xsl:when test="count($first-with-nonempty-string) = 0">
                    <xsl:apply-templates select="node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$first-with-nonempty-string/(preceding-sibling::node() | .)">
                        <xsl:with-param name="should-normalize" select="true()" tunnel="yes"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="$first-with-nonempty-string/following-sibling::node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[normalize-space()!='']">
        <xsl:param name="should-normalize" select="false()" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$should-normalize">
                <xsl:value-of select="replace(., '^\s+', '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
