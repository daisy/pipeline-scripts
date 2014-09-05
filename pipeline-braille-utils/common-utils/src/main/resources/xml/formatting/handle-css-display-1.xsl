<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <!--
        css-utils [2.0.0,3.0.0)
    -->
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@style), 'display')]">
        <xsl:variable name="properties"
            select="css:specified-properties('#all display', true(), true(), true(), .)"/>
        <xsl:variable name="display" as="xs:string" select="$properties[@name='display']/@value"/>
        <xsl:choose>
            <xsl:when test="$display='none'">
                <!--
                    temporary element, will be removed in subsequent pass
                -->
                <xsl:element name="css:temp">
                    <xsl:if test="descendant-or-self::*[@css:string-set]">
                        <xsl:attribute name="css:string-set"
                                       select="string-join(descendant-or-self::*/@css:string-set/string(.), ', ')"/>
                    </xsl:if>
                    <xsl:if test="descendant-or-self::*[@css:counter-reset]">
                        <xsl:attribute name="css:counter-reset"
                                       select="string-join(descendant-or-self::*/@css:counter-reset/string(.), ' ')"/>
                    </xsl:if>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{if ($display=('block','list-item')) then 'css:block' else name()}">
                    <xsl:sequence select="@*[not(name()='style')]"/>
                    <xsl:sequence select="css:style-attribute(css:serialize-declaration-list(
                                            $properties[not(@name='display')]))"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
