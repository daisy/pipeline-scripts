<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:include href="library.xsl"/>
    
    <xsl:param name="counter-names"/>
    <xsl:param name="exclude-counter-names"/>
    <xsl:variable name="counter-names-list" as="xs:string*" select="tokenize(normalize-space($counter-names), ' ')"/>
    <xsl:variable name="exclude-counter-names-list" as="xs:string*" select="tokenize(normalize-space($exclude-counter-names), ' ')"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="css:counter">
        <xsl:choose>
            <xsl:when test="if ($counter-names='#all')
                            then not(@name=$exclude-counter-names-list)
                            else @name=$counter-names-list">
                <xsl:variable name="style" as="xs:string" select="(@style,'decimal')[1]"/>
                <xsl:choose>
                    <xsl:when test="@target">
                        <xsl:variable name="target" as="xs:string" select="@target"/>
                        <xsl:variable name="target" as="element()?" select="//*[@css:id=$target][1]"/>
                        <xsl:if test="$target">
                            <xsl:call-template name="css:counter">
                                <xsl:with-param name="name" select="@name"/>
                                <xsl:with-param name="style" select="$style"/>
                                <xsl:with-param name="context" select="$target"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="css:counter">
                            <xsl:with-param name="name" select="@name"/>
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@css:*[matches(local-name(),'^counter-(set|reset|increment)-.*$')]">
        <xsl:variable name="name" as="xs:string"
                      select="replace(local-name(),'^counter-(set|reset|increment)-(.*)$','$2')"/>
        <xsl:if test="if ($counter-names='#all')
                      then $name=$exclude-counter-names-list
                      else not($name=$counter-names-list)">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
