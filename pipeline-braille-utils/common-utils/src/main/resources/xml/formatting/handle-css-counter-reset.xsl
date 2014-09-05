<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <!--
        css-utils [2.0.0,3.0.0)
    -->
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@style), 'counter-reset')]">
        <xsl:variable name="properties" as="element()*"
            select="css:specified-properties('#all counter-reset', true(), true(), true(), .)"/>
        <xsl:variable name="counter-reset" as="xs:string" select="$properties[@name='counter-reset']/@value"/>
        <xsl:copy>
            <xsl:sequence select="@*[not(name()='style')]"/>
            <xsl:sequence select="css:style-attribute(css:serialize-declaration-list(
                                    $properties[not(@name='counter-reset')]))"/>
            <xsl:if test="$counter-reset!='none'">
                <xsl:attribute name="css:counter-reset" select="$counter-reset"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
