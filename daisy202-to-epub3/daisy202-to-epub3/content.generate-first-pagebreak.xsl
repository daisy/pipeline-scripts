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

    <xsl:template match="/*/*[1]/body">
        <xsl:variable name="pagebreak" select="(//span[@class='page-normal' or @class='page-special' or @class='page-front'])[1]"/>
        <xsl:variable name="pagenum" select="normalize-space($pagebreak)"/>
        <xsl:variable name="type" select="$pagebreak/@class"/>

        <xsl:variable name="generated-pagenum"
            select="
                if (number($pagenum) = NaN or pf:numeric-is-roman($pagenum) and number(pf:numeric-roman-to-hindu($pagenum)) = NaN) then
                    0
                else if ($type = 'page-normal') then
                    if (number($pagenum) &gt; 1) then
                        number($pagenum)-1
                    else
                        0
                else if (pf:numeric-is-roman($pagenum)) then
                    if (pf:numeric-roman-to-hindu($pagenum) &gt; 1) then
                        pf:numeric-hindu-to-roman(pf:numeric-roman-to-hindu($pagenum)-1)
                    else
                        if ($type = 'page-front') then
                            1
                        else
                            0
                else
                    number($pagenum)-1
            "/>
        <xsl:variable name="new-class" select="if (string($generated-pagenum) = '0') then 'page-front' else $type"/>
        <xsl:variable name="new-page" select="if ($type = 'page-front' and not(number($pagenum) = NaN) or not(string($generated-pagenum) = '0')) then $generated-pagenum else 1"/>

        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <span id="{generate-id()}" class="{$new-class}" epub:type="pagebreak" title="{$new-page}">
                <xsl:value-of select="$new-page"/>
            </span>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
