<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@style), 'display')]">
        <xsl:variable name="display" select="css:get-value(., 'display', true(), true(), false())"/>
        <xsl:choose>
            <xsl:when test="$display=('none','page-break')">
                <xsl:sequence select=".//louis:print-page|
                                      .//louis:running-header|
                                      .//louis:running-footer"/>
            </xsl:when>
            <xsl:when test="$display=('block','list-item')">
                <xsl:copy>
                    <xsl:sequence select="@*[not(name()='style')]"/>
                    <xsl:variable name="style" as="xs:string?"
                                  select="css:remove-from-declarations(string(@style), ('display'))"/>
                    <xsl:if test="$style">
                        <xsl:attribute name="style" select="$style"/>
                    </xsl:if>
                    <xsl:attribute name="css:display" select="'block'"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
