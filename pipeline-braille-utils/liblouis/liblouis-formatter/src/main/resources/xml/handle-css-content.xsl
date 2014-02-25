<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@style), 'content')]">
        <xsl:variable name="content" as="xs:string?"
                      select="(for $declaration
                               in css:filter-declaration(css:tokenize-declarations(string(@style)), 'content')
                               return substring-after($declaration, ':'))[1]"/>
        <xsl:choose>
            <xsl:when test="$content">
                <xsl:copy>
                    <xsl:sequence select="@*"/>
                    <xsl:sequence select="css:eval-content-list(
                                            if (self::css:before or self::css:after) then parent::* else .,
                                            $content)"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
