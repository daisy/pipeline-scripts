<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="no"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/style-functions.xsl" />
    
    <xsl:template match="/">
        
        <lblxml:semantic-file>
            <xsl:for-each select="//brl:style">
                <xsl:variable name="display" select="brl:get-property-or-default(., 'display')"/>
                <xsl:choose>
                    <xsl:when test="$display='none'">
                        <xsl:text>skip</xsl:text>
                    </xsl:when>
                    <xsl:when test="$display='block' or 
                                    $display='list-item'">
                        <xsl:value-of select="@name"/>
                    </xsl:when>
                    
                    <!-- Only if default value of display = 'block' -->
                    <!-- <xsl:when test="$display='inline'"> -->
                    <!--     <xsl:text>generic</xsl:text> -->
                    <!-- </xsl:when> -->
                    
                </xsl:choose>
                <xsl:text> &amp;xpath(//*[@brl:style='#</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>'])&#xa;</xsl:text>
            </xsl:for-each>
            <xsl:text>&#xa;</xsl:text>
        </lblxml:semantic-file>
        
    </xsl:template>
    
</xsl:stylesheet>