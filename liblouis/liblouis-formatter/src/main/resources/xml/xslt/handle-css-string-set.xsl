<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-result-prefixes="xs css louis"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl" />
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@style), 'string-set')]">
        <xsl:variable name="element" as="element()" select="."/>
        <xsl:variable name="string-set" as="xs:string?"
            select="css:get-property-value(., 'string-set', true(), true(), false())"/>
        <xsl:if test="$string-set and $string-set!='none'">
            <xsl:for-each select="tokenize($string-set,',')">
                <xsl:variable name="identifier" select="replace(., '^\s*(\S+)\s.*$', '$1')"/>
                <xsl:variable name="content-list" select="substring-after(., $identifier)"/>
                <xsl:variable name="content" select="css:eval-content-list($element, $content-list)"/>
                <xsl:if test="exists($content)">
                    <xsl:choose>
                        <xsl:when test="$identifier='print-page'">
                            <xsl:element name="louis:print-page">
                                <xsl:attribute name="break"
                                               select="if (css:get-property-value($element, 'display', true(), true(), true())='page-break')
                                                       then 'true' else 'false'"/>
                                <xsl:sequence select="string($content)"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$identifier='running-header'">
                            <xsl:element name="louis:running-header">
                                <xsl:sequence select="string($content)"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$identifier='running-footer'">
                            <xsl:element name="louis:running-footer">
                                <xsl:sequence select="string($content)"/>
                            </xsl:element>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
