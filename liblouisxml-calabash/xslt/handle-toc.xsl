<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    xmlns:my="http://github.com/bertfrees"
    xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
    exclude-result-prefixes="xs brl lblxml my z"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/style-functions.xsl" />
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@brl:style), 'toc')]">
        <xsl:variable name="display" as="xs:string"
            select="brl:get-property-or-default(string(@brl:style), 'display')"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="$display='toc'">
                    <lblxml:toc>
                        <xsl:for-each select="child::*">
                            <xsl:variable name="child-display" as="xs:string"
                                select="brl:get-property-or-default(string(@brl:style), 'display')"/>
                            <xsl:choose>
                                <xsl:when test="$child-display='toc-title'">
                                    <lblxml:toc-title>
                                        <xsl:attribute name="brl:style" select="my:get-toc-title-style(.)"/>
                                        <xsl:value-of select="string(.)"/>
                                    </lblxml:toc-title>
                                </xsl:when>
                                <xsl:when test="$child-display='toc-item'">
                                    <xsl:variable name="ref" as="attribute()?" select="z:ref/@ref"/>
                                    <xsl:if test="$ref">
                                        <lblxml:toc-item>
                                            <xsl:attribute name="brl:style" select="my:get-toc-item-style(.)"/>
                                            <xsl:copy-of select="$ref"/>
                                        </lblxml:toc-item>
                                    </xsl:if>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </lblxml:toc>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="my:get-toc-title-style" as="xs:string">
        <xsl:param name="element" as="element()"/>
        <xsl:variable name="valid-property-names" as="xs:string*"
            select="('display',
                     'text-align',
                     'margin-left',
                     'margin-right',
                     'margin-top',
                     'margin-bottom',
                     'text-indent')"/>
        <xsl:variable name="name-value-pairs" as="xs:string*">
            <xsl:for-each select="$valid-property-names">
                <xsl:sequence select="concat(.,':',brl:get-property-or-inherited($element, .))"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($name-value-pairs,';')"/>
    </xsl:function>
    
    <xsl:function name="my:get-toc-item-style" as="xs:string">
        <xsl:param name="element" as="element()"/>
        <xsl:variable name="valid-property-names" as="xs:string*"
            select="('display',
                     'margin-left',
                     'margin-right',
                     'text-indent')"/>
        <xsl:variable name="name-value-pairs" as="xs:string*">
            <xsl:for-each select="$valid-property-names">
                <xsl:sequence select="concat(.,':',brl:get-property-or-inherited($element, .))"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($name-value-pairs,';')"/>
    </xsl:function>
    
</xsl:stylesheet>