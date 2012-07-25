<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="xs louis css"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="no"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille-css/xslt/parsing-helper.xsl" />
    
    <xsl:template match="/">
        
        <louis:semantic-file>
            <xsl:for-each select="//louis:style">
                <xsl:variable name="display" as="xs:string?" select="string(@display)"/>
                <xsl:if test="$display and
                             ($display='block' or 
                              $display='list-item' or
                              $display='toc' or 
                              $display='none')">
                    <xsl:choose>
                        <xsl:when test="$display='none'">
                            <xsl:text>skip</xsl:text>
                        </xsl:when>
                        <!--
                        <xsl:when test="$display='inline'">
                            <xsl:text>generic</xsl:text>
                        </xsl:when>
                        -->
                        <xsl:otherwise>
                            <xsl:value-of select="@name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> &amp;xpath(//*[@louis:style='#</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>'])&#xa;</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>&#xa;</xsl:text>
        </louis:semantic-file>
        
    </xsl:template>
    
</xsl:stylesheet>