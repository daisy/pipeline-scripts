<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:html="http://www.w3.org/1999/xhtml" version="2.0">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*[child::html:a]">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="html:a">
        <xsl:element name="{name(parent::*)}" namespace="{namespace-uri(parent::*)}">
            <!-- TODO: if there are multiple html:a children, this will wrap them in separate parents I guess, shouldn't be so... -->
            <xsl:apply-templates select="parent::*/@*"/>
            <xsl:choose>
                <xsl:when
                    test="starts-with(@href,'file:') or starts-with(@href,'#') and substring(@href,2) = (@id | ancestor::*/@id | descendant::*/@id)">
                    <xsl:if test="not(parent::*/@id) and @id">
                        <xsl:attribute name="id" select="@id"/>
                    </xsl:if>
                    <xsl:apply-templates select="node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="@*|node()"/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
