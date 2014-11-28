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
    <xsl:template match="obfl:block/text()[not(preceding-sibling::node()[not(self::obfl:marker or self::text()[normalize-space(.)=''])])]">
        <xsl:sequence select="replace(., '^\s+', '')"/>
    </xsl:template>
    
    <!--
        TODO: same for span?
    -->
    
</xsl:stylesheet>
