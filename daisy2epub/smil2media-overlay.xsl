<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:opf="http://www.idpf.org/2007/opf" version="2.0">

    <!-- TODO: make sure that XProc passes a language in here. -->
    <xsl:param name="language" required="yes"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <smil xmlns="http://www.w3.org/ns/SMIL" version="3.0"
            profile="http://www.idpf.org/epub/30/profile/content/" xml:lang="{$language}">
            <xsl:apply-templates/>
        </smil>
    </xsl:template>
    
    <xsl:template match="meta">
        <meta property="{@name}"><xsl:value-of select="@content"/></meta>
    </xsl:template>
    
    <xsl:template match="layout"/>

</xsl:stylesheet>
