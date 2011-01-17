<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output indent="yes" method="xml"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[dtb:br]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>

            <xsl:for-each-group select="node()" group-ending-with="dtb:br">
                <xsl:if test="not(empty(current-group()[not(self::dtb:br)][normalize-space()]))">

                    <xsl:element name="ln" namespace="http://www.daisy.org/z3986/2005/dtbook/">
                        <xsl:apply-templates select="current-group()[not(self::dtb:br)]"/>

                    </xsl:element>
                </xsl:if>

            </xsl:for-each-group>

        </xsl:copy>
    </xsl:template>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
