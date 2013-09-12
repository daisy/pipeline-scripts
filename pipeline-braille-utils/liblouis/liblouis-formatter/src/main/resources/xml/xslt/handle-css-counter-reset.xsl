<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/xslt/library.xsl"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@style), 'counter-reset')]">
        <xsl:variable name="element" as="element()" select="."/>
        <xsl:variable name="counter-reset" as="xs:string?"
            select="css:get-value(., 'counter-reset', true(), true(), false())"/>
        <xsl:copy>
            <xsl:if test="$counter-reset and $counter-reset!='none'">
                <!--
                    TODO: be careful with group indexes !!
                -->
                <xsl:variable name="COUNTER_RESET" select="concat($IDENT,'(\s', $INTEGER, ')?')"/>
                <xsl:analyze-string select="normalize-space($counter-reset)" regex="{$COUNTER_RESET}">
                    <xsl:matching-substring>
                        <xsl:variable name="counter" select="replace(., '^(\S+)\s.*$', '$1')"/>
                        <xsl:variable name="value" select="if (regex-group(3)!='') then normalize-space(regex-group(3)) else '1'"/>
                        <xsl:if test="$counter='braille-page'">
                            <xsl:attribute name="louis:braille-page-reset" select="$value"/>
                        </xsl:if>
                    </xsl:matching-substring>
                </xsl:analyze-string>
                <xsl:if test="not(@xml:id)">
                    <xsl:attribute name="xml:id" select="generate-id()"/>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
