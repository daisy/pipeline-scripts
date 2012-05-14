<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/style-functions.xsl" />
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@brl:style), 'border')]">
        <xsl:variable name="style" as="xs:string" select="string(@brl:style)"/>
        <xsl:variable name="display" as="xs:string"
            select="brl:get-property-or-default($style, 'display')"/>
        <xsl:variable name="border-top" as="xs:string"
            select="brl:get-property-or-default($style, 'border-top')"/>
        <xsl:variable name="border-bottom" as="xs:string"
            select="brl:get-property-or-default($style, 'border-bottom')"/>
        <xsl:choose>
            <xsl:when test="($display='block' or $display='list-item') and
                            ($border-top!='none' or $border-bottom!='none')">
                <xsl:variable name="padding-top" as="xs:string"
                    select="brl:get-property-or-default($style, 'padding-top')"/>
                <xsl:variable name="padding-bottom" as="xs:string"
                    select="brl:get-property-or-default($style, 'padding-bottom')"/>
                <div>
                    <xsl:attribute name="brl:style"
                        select="brl:override-style($style, 'padding-top:0;padding-bottom:0')"/>
                    <xsl:if test="$border-top!='none'">
                        <brl:border>
                            <xsl:attribute name="style" select="$border-top"/>
                        </brl:border>
                    </xsl:if>
                    <xsl:copy>
                        <xsl:apply-templates select="@*"/>
                        <xsl:attribute name="brl:style"
                            select="concat('display:block;
                                            margin-top:', $padding-top, ';',
                                           'margin-bottom:', $padding-bottom)"/>
                        <xsl:apply-templates select="node()"/>
                    </xsl:copy>
                    <xsl:if test="$border-bottom!='none'">
                        <brl:border>
                            <xsl:attribute name="style" select="$border-bottom"/>
                        </brl:border>
                    </xsl:if>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>