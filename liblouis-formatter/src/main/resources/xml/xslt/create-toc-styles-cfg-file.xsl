<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="create-styles-cfg-file.xsl" />

    <xsl:param name="toc-item-styles" as="xs:string*"/>

    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/">
        <xsl:call-template name="create-config-file">
            <xsl:with-param name="display-values" select="('toc-item')"/>
            <xsl:with-param name="toc-item-styles" select="$toc-item-styles"/>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>