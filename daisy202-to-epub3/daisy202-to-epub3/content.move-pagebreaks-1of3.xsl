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

    <xsl:template match="span[@class='page-normal' or @class='page-special' or @class='page-front']">
        <xsl:copy-of select="(preceding::span[@class='page-normal' or @class='page-special' or @class='page-front'])[last()]"/>
    </xsl:template>

    <xsl:template match="/*">
        <xsl:copy>
            <xsl:apply-templates select="html[not(position()=last())]"/>
            <xsl:for-each select="html[position()=last()]">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates select="head"/>
                    <xsl:for-each select="body">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|node()"/>
                            <xsl:copy-of select="(//span[@class='page-normal' or @class='page-special' or @class='page-front'])[last()]"/>
                        </xsl:copy>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
