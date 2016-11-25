<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="css:box">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="not(@css:id)">
                <xsl:variable name="id" select="for $flow in (ancestor-or-self::*/@css:flow,'normal')[1] return
                    string((
                        (preceding::*|ancestor::*)[not(self::css:box)]
                                                  [@css:id]
                                                  [not(ancestor::css:box[@type='inline'])]
                                                  [(ancestor-or-self::*/@css:flow,'normal')[1]=$flow]
                        except
                        (preceding::css:box|ancestor::css:box)[last()]/(preceding::*|ancestor::*)
                    )[last()]/@css:id)"/>
                <xsl:if test="not($id='')">
                    <xsl:attribute name="css:id" select="$id"/>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@css:id[.='']"/>
    
    <xsl:template match="css:counter[@name][@target]">
        <xsl:variable name="target" select="@target"/>
        <xsl:variable name="target" select="
            //*[@css:id=$target]/(
                self::css:box
                | self::*[ancestor::css:box[@type='inline']]
                | following::css:box
                | descendant::css:box
            )[1]/@css:id"/>
        
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="target" select="$target"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@css:anchor">
        <xsl:variable name="anchor" select="."/>
        <xsl:variable name="anchor" select="
            (//*[@css:id=$anchor]/(
                self::css:box
                | self::*[ancestor::css:box[@type='inline']]
                | following::css:box
                | descendant::css:box
            )[1]/@css:id,'NULL')[1]"/>
        <xsl:attribute name="css:anchor" select="$anchor"></xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@css:id[not(parent::css:box) and not(ancestor::css:box[@type='inline'])]"/>
    
</xsl:stylesheet>
