<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="2.0"
    exclude-result-prefixes="#all">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="c:body">
        <xsl:copy>
            <xsl:variable name="sources" select="distinct-values(//*[local-name()='text']/tokenize(@src,'#')[1])"/>
            <xsl:for-each select="$sources">
                <xsl:element name="c:file">
                    <xsl:attribute name="href" select="."/>
                </xsl:element>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
