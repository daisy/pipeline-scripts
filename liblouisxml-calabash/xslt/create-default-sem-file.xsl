<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>
    
    <xsl:template match="/">
        
        <xsl:variable name="root-element-name" select="local-name(/*)"/>
        <xsl:variable name="element-names" as="xs:string*">
            <xsl:for-each select="descendant::element()">
                <xsl:sequence select="local-name(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="distinct-element-names" as="xs:string*"
            select="distinct-values($element-names)"/>
        
        <lblxml:semantic-file>
            <xsl:text>namespaces brl=http://www.daisy.org/ns/pipeline/braille&#xa;</xsl:text>
            <xsl:text>document </xsl:text>
            <xsl:value-of select="$root-element-name"/>
            <xsl:text>&#xa;</xsl:text>
            
            <!-- Only if default value of display = 'block' -->
            <!-- <xsl:for-each select="$distinct-element-names"> -->
            <!--     <xsl:text>para </xsl:text> -->
            <!--     <xsl:value-of select="."/> -->
            <!--     <xsl:text>&#xa;</xsl:text> -->
            <!-- </xsl:for-each> -->
            
            <xsl:text>&#xa;</xsl:text>
        </lblxml:semantic-file>
        
    </xsl:template>
    
</xsl:stylesheet>