<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:opf="http://www.idpf.org/2007/opf" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-result-prefixes="#all" version="2.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <xsl:variable name="fileset" select="."/>
        <manifest xmlns="http://www.idpf.org/2007/opf">
            <xsl:for-each select="child::*">
                <item xmlns="http://www.idpf.org/2007/opf" href="{@href}" media-type="{@media-type}" id="{concat('item_',position())}">
                    <xsl:if test="@media-type='application/xhtml+xml' and not(tokenize(@href,'/')[last()]='navigation.xhtml')">
                        <xsl:variable name="smil" select="replace(@href,'xhtml$','smil')"/>
                        <xsl:attribute name="media-overlay" select="concat('item_',count(($fileset/*[@href=$smil]/preceding-sibling::*))+1)"/>
                    </xsl:if>
                </item>
                <!-- NOTE: this assumes that the media overlays were generated based on the content documents. -->
            </xsl:for-each>
        </manifest>
    </xsl:template>

</xsl:stylesheet>
