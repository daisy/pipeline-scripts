<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:include href="library.xsl"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@css:content]">
        <xsl:variable name="context" select="if (self::css:before or self::css:after) then parent::* else ."/>
        <xsl:copy>
            <xsl:sequence select="@* except @css:content"/>
            <xsl:apply-templates select="css:parse-content-list(@css:content, $context)" mode="eval-content-list">
                <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="css:string[@value]" mode="eval-content-list">
        <xsl:value-of select="string(@value)"/>
    </xsl:template>
    
    <xsl:template match="css:attr" mode="eval-content-list">
        <xsl:param name="context" as="element()"/>
        <xsl:variable name="name" select="string(@name)"/>
        <xsl:value-of select="string($context/@*[name()=$name])"/>
    </xsl:template>
    
    <xsl:template match="css:text[@target]|css:string[@name][@target]|css:counter[@target]|css:leader"
                  mode="eval-content-list">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="css:string[@name][not(@target)]" mode="eval-content-list">
        <xsl:message>string() function not supported in content property of (pseudo-)elements</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:counter[not(@target)]" mode="eval-content-list">
        <xsl:message>counter() function not supported in content property of (pseudo-)elements</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:content" mode="eval-content-list">
        <xsl:message>content() function not supported in content property of (pseudo-)elements</xsl:message>
    </xsl:template>
    
    <xsl:template match="*" mode="eval-content-list">
        <xsl:message terminate="yes">Coding error</xsl:message>
    </xsl:template>
    
</xsl:stylesheet>
