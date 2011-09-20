<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all" xmlns:pf="http://www.daisy.org/ns/pipeline/functions" xmlns:epub="http://www.idpf.org/2007/ops">
    <xsl:import href="numeral-conversion.xsl"/>
    <xsl:output indent="yes"/>

    <xsl:template match="/*">
        <mapping>
            <xsl:for-each select="//span[@class='page-normal' or @class='page-special' or @class='page-front']">
                <mapping id="{@id}" from="{@xml:base}" to="{ancestor::html/@xml:base}"/>
            </xsl:for-each>
        </mapping>
    </xsl:template>

</xsl:stylesheet>
