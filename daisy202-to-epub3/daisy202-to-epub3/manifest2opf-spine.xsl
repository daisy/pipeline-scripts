<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:opf="http://www.idpf.org/2007/opf" exclude-result-prefixes="#all" version="2.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <spine xmlns="http://www.idpf.org/2007/opf" toc="{child::*[tokenize(@href,'/')[last()]='navigation.xhtml']/@id}">
            <xsl:for-each
                select="child::*[@media-type='application/xhtml+xml' and not(tokenize(@href,'/')[last()]='navigation.xhtml')]">
                <itemref xmlns="http://www.idpf.org/2007/opf" idref="{@id}"/>
            </xsl:for-each>
        </spine>
    </xsl:template>

</xsl:stylesheet>
