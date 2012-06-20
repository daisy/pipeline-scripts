<?xml version="1.1" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    xmlns:my="http://github.com/bertfrees"
    exclude-result-prefixes="xs brl lblxml my"
    version="2.0">
    
    <xsl:param name="keep-page-structure" as="xs:boolean" select="false()"/>

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/encoding-functions.xsl" />
    
    <xsl:template match="/lblxml:section">        
        <lblxml:preformatted>
            <xsl:for-each select="tokenize(my:right-trim-formfeed(string(.)), '&#x0C;')">
                <xsl:call-template name="page"/>
            </xsl:for-each>
        </lblxml:preformatted>
    </xsl:template>
    
    <xsl:template name="page">
        <xsl:variable name="page-content" as="element()*">
            <xsl:for-each select="tokenize(my:right-trim-whitespace(string(.)), '\n')">
                <xsl:call-template name="line"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$keep-page-structure">
                <lblxml:page>
                    <xsl:sequence select="$page-content"/>
                </lblxml:page>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$page-content"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="line">
        <lblxml:line>
            <xsl:choose>
                <xsl:when test="string-length(.) &gt; 0">
                    <xsl:value-of select="brl:nabcc-to-unicode-braille(my:space-to-nbsp(.))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>&#xA0;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </lblxml:line>
    </xsl:template>
    
    <xsl:function name="my:right-trim-whitespace" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="replace($string, '\s+$','')"/>
    </xsl:function>
    
    <xsl:function name="my:right-trim-formfeed" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="replace($string, '&#x0C;$','')"/>
    </xsl:function>
    
    <xsl:function name="my:space-to-nbsp" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="translate($string, ' ', '&#xA0;')"/>
    </xsl:function>
    
</xsl:stylesheet>