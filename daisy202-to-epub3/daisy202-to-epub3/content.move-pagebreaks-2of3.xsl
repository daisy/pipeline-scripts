<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all" xmlns:pf="http://www.daisy.org/ns/pipeline/functions" xmlns:epub="http://www.idpf.org/2007/ops">
    <xsl:import href="numeral-conversion.xsl"/>
    <xsl:output indent="yes"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="body">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:copy-of select="parent::*/following-sibling::html[1]/body/span[(@class='page-normal' or @class='page-special' or @class='page-front') and (string-length(normalize-space(string-join(preceding-sibling::*/descendant-or-self::*/text(),''))) = 0) = true()]"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="span[(@class='page-normal' or @class='page-special' or @class='page-front') and parent::body and (string-length(normalize-space(string-join(preceding-sibling::*/descendant-or-self::*/text(),''))) = 0) = true()]"/>

</xsl:stylesheet>
