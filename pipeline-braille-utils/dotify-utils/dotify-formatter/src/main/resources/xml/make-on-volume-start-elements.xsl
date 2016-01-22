<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@css:_obfl-on-volume-start]">
        <xsl:variable name="id" select="generate-id()"/>
        <xsl:copy>
            <xsl:sequence select="@* except @css:_obfl-on-volume-start"/>
            <xsl:attribute name="css:_obfl-on-volume-start-ref" select="$id"/>
            <xsl:apply-templates/>
        </xsl:copy>
        <xsl:result-document href="{$id}">
            <css:_ css:flow="-obfl-on-volume-start/{$id}">
                <css:_obfl-on-volume-start style="{@css:_obfl-on-volume-start}"/>
            </css:_>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>
