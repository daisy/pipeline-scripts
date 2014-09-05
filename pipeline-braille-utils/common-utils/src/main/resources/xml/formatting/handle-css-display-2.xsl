<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:sequence select="@*"/>
            <xsl:for-each-group select="*|text()" group-adjacent="boolean(descendant-or-self::css:block)">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <xsl:for-each select="current-group()">
                            <xsl:apply-templates select="."/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="matches(string-join(current-group()/string(.), ''), '^[\s&#x2800;]*$')
                                    and not(current-group()/descendant-or-self::css:white-space or
                                            current-group()/descendant-or-self::css:string-fn or
                                            current-group()/descendant-or-self::css:counter-fn or
                                            current-group()/descendant-or-self::css:target-text-fn or
                                            current-group()/descendant-or-self::css:target-string-fn or
                                            current-group()/descendant-or-self::css:target-counter-fn or
                                            current-group()/descendant-or-self::css:leader-fn)">
                        <xsl:sequence select="current-group()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="css:inline">
                            <xsl:sequence select="current-group()"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:sequence select="."/>
    </xsl:template>
    
</xsl:stylesheet>
