<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:pf="http://www.daisy.org/ns/pipeline/functions">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>

    <xsl:variable name="smil" select="/*/smil"/>
    <xsl:variable name="base-uri" select="base-uri(/*)"/>
    <xsl:variable name="smil-href" select="pf:relativize-uri(base-uri($smil),$base-uri)"/>

    <xsl:template match="/*">
        <xsl:copy>
            <xsl:apply-templates select="@*|html:*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()[not(self::*)]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="par" select="if (not(@id)) then () else ($smil//par[text/resolve-uri(@src,base-uri()) = concat($base-uri,'#',$id)])[1]"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="$par">
                    <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                        <xsl:attribute name="href" select="concat($smil-href,'#',$par/@id)"/>
                        <xsl:apply-templates select="@*|node()"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
