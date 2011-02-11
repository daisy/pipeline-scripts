<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0"
    xmlns:rend="http://www.daisy.org/ns/z3986/authoring/features/rend/"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns="http://www.daisy.org/ns/z3986/authoring/">
    
    <xsl:output indent="yes" method="text"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="object">
        <xsl:if test="@height or @width">
            #<xsl:value-of select="@id"/>{
                <xsl:if test="@height">
                    height: <xsl:value-of select="@height"/>;
                </xsl:if>
                <xsl:if test="@width">
                    width: <xsl:value-of select="@height"/>;
                </xsl:if>
            }
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="table">
        <xsl:if test="@width or @border or @cellspacing or @cellpadding">
            #<xsl:value-of select="@id"/>{
            <xsl:if test="@width">
                width: <xsl:value-of select="@height"/>;
            </xsl:if>
            <xsl:if test="@border">
                border: <xsl:value-of select="@border"/>;
            </xsl:if>
            <xsl:if test="@cellspacing">
                cellspacing: <xsl:value-of select="@cellspacing"/>;
            </xsl:if>
            <xsl:if test="@cellpadding">
                cellpadding: <xsl:value-of select="@cellpadding"/>;
            </xsl:if>
            }
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="col | colgroup">
        <xsl:if test="@width or @align or @valign">
            #<xsl:value-of select="@id"/>{
            <xsl:if test="@width">
                width: <xsl:value-of select="@height"/>;
            </xsl:if>
            <xsl:if test="@align">
                align: <xsl:value-of select="@align"/>;
            </xsl:if>
            <xsl:if test="@valign">
                valign: <xsl:value-of select="@valign"/>;
            </xsl:if>
            }
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="th | td | tr | tbody | tfoot | thead">
        <xsl:if test="@align or @valign">
            #<xsl:value-of select="@id"/>{
            <xsl:if test="@align">
                align: <xsl:value-of select="@align"/>;
            </xsl:if>
            <xsl:if test="@valign">
                valign: <xsl:value-of select="@valign"/>;
            </xsl:if>
            }
        </xsl:if>
    </xsl:template>
    
    
    <!-- identity template which discards everything -->
    <xsl:template match="@*|node()">
        <xsl:apply-templates select="@*|node()"/>
    </xsl:template>
</xsl:stylesheet>
