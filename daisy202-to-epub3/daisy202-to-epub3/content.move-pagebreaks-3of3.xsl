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

    <xsl:template match="span[parent::body and preceding-sibling::div]"/>

    <xsl:template match="span[parent::body and not(preceding-sibling::div)]">
        <div>
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </div>
    </xsl:template>

    <xsl:template match="div[parent::body]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
            <xsl:variable name="after-spans" select="min(following-sibling::*/(if (not(self::span)) then position()-1 else last()))"/>
            <xsl:copy-of select="following-sibling::*[position() &lt;= $after-spans]"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
