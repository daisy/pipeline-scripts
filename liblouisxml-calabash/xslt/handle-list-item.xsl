<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:my="http://github.com/bertfrees"
    exclude-result-prefixes="xs brl my"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/style-functions.xsl" />
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@brl:style), 'list-item')]">
        <xsl:variable name="display" as="xs:string"
            select="brl:get-property-or-default(string(@brl:style), 'display')"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="$display='list-item'">
                <xsl:variable name="list-style-type" as="xs:string"
                    select="my:get-list-style-type(.)"/>
                <xsl:if test="$list-style-type!='none' and
                              $list-style-type!='inherit'">
                    <span brl:style="display:inline">
                        <xsl:sequence select="concat($list-style-type, ' ')"/>
                    </span>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="my:get-list-style-type" as="xs:string">
        <xsl:param name="element" as="element()"/>
        <xsl:sequence select="brl:get-property-or-inherited($element, 'list-style-type')"/>
    </xsl:function>
    
</xsl:stylesheet>