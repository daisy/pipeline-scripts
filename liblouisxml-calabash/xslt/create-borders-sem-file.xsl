<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/encoding-functions.xsl" />
    
    <xsl:template match="/">
        
        <lblxml:semantic-file>
            
            <xsl:variable name="border-styles" as="xs:string*">
                <xsl:for-each select="//brl:border/@style">
                    <xsl:sequence select="string(.)"/>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:for-each select="distinct-values($border-styles)">
                <xsl:text>boxline &amp;xpath(//brl:border[@style='</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>']) </xsl:text>
                <xsl:value-of select="brl:unicode-braille-to-nabcc(.)"/>
                <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
            <xsl:text>&#xa;</xsl:text>
        </lblxml:semantic-file>
        
    </xsl:template>
    
</xsl:stylesheet>