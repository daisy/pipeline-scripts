<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml">
    
    <xsl:output indent="yes"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*/*[1]"/>
    
    <xsl:template match="a">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="@href=/*/*[1]/*/concat(@from,'#',@id)">
                <xsl:variable name="href" select="@href"/>
                <xsl:attribute name="href" select="concat((/*/*[1]/*[$href=concat(@from,'#',@id)]/@to)[1],'#',tokenize(@href,'#')[2])"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
