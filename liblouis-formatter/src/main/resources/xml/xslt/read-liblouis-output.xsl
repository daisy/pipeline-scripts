<?xml version="1.1" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:my="http://github.com/bertfrees"
    exclude-result-prefixes="xs brl louis my"
    version="2.0">
    
    <xsl:param name="width"/>
    <xsl:param name="margin-left" select="0"/>
    <xsl:param name="border-left" select="'none'"/>
    <xsl:param name="border-right" select="'none'"/>
    <xsl:param name="skip-first-line" select="'false'"/>
    <xsl:param name="skip-last-line" select="'false'"/>
    <xsl:param name="keep-empty-trailing-lines" select="'false'"/>
    <xsl:param name="keep-page-structure" select="'false'"/>

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/encoding-functions.xsl" />
    
    <xsl:template match="/*">        
        <louis:preformatted>
            <xsl:for-each select="tokenize(my:right-trim-formfeeds(string(.)), '&#x0C;')">
                <xsl:call-template name="page"/>
            </xsl:for-each>
        </louis:preformatted>
    </xsl:template>
    
    <xsl:template name="page">
        <xsl:variable name="page-content">
            <xsl:choose>
                <xsl:when test="$keep-empty-trailing-lines='true'">
                    <xsl:for-each select="tokenize(string(.), '\n')">
                        <xsl:if test="not(
                            (position()=1 and $skip-first-line='true') or
                            (position()=last()-1 and $skip-last-line='true') or
                            (position()=last()))">
                            <xsl:call-template name="line"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="tokenize(my:right-trim-newlines(string(.)), '\n')">
                        <xsl:if test="not(position()=1 and $skip-first-line='true')">
                            <xsl:call-template name="line"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$keep-page-structure='true'">
                <louis:page>
                    <xsl:sequence select="$page-content"/>
                </louis:page>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$page-content"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="line">
        <louis:line>
            <xsl:if test="number($margin-left) &gt; 0">
                <xsl:value-of select="my:repeat-char('&#xA0;', number($margin-left))"/>
            </xsl:if>
            <xsl:if test="$border-left!='none'">
                <xsl:value-of select="$border-left"/>
            </xsl:if>
            <xsl:value-of select="brl:nabcc-to-unicode-braille(my:space-to-nbsp(.))"/>
            <xsl:choose>
                <xsl:when test="$border-right!='none'">
                    <xsl:value-of select="my:repeat-char('&#xA0;', number($width) - string-length(.))"/>
                    <xsl:value-of select="$border-right"/>
                </xsl:when>
                <xsl:when test="number($margin-left)=0 and $border-left='none' and string-length(.)=0">
                    <xsl:text>&#xA0;</xsl:text>
                </xsl:when>
            </xsl:choose>
        </louis:line>
    </xsl:template>
    
    <xsl:function name="my:right-trim-newlines" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="replace($string, '\n+$','')"/>
    </xsl:function>
    
    <xsl:function name="my:right-trim-formfeeds" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="replace($string, '&#x0C;+$','')"/>
    </xsl:function>
    
    <xsl:function name="my:space-to-nbsp" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="translate($string, ' ', '&#xA0;')"/>
    </xsl:function>
    
    <xsl:function name="my:repeat-char" as="xs:string?">
        <xsl:param name="char" as="xs:string"/>
        <xsl:param name="times" />
        <xsl:if test="$times &gt; 0">
            <xsl:value-of select="concat($char, my:repeat-char($char, $times - 1))"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>