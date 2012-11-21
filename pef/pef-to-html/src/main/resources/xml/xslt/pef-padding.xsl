<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    xmlns:my="http://github.com/bertfrees"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs pef my"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="pef:page">
        <xsl:variable name="rows" select="number(ancestor::*[@rows][1]/@rows)"/>
        <xsl:variable name="cols" select="number(ancestor::*[@cols][1]/@cols)"/>
        <xsl:copy>
            <xsl:sequence select="@*"/>
            <xsl:for-each select="pef:row">
                <xsl:copy>
                    <xsl:sequence select="@*"/>
                    <xsl:sequence select="concat(string(.), my:repeat-char('⠀', $cols - string-length(string(.))))"/>
                </xsl:copy>
            </xsl:for-each>
            <xsl:if test="count(pef:row) &lt; $rows">
                <xsl:variable name="row">
                    <xsl:element name="row" namespace="http://www.daisy.org/ns/2008/pef">
                        <xsl:sequence select="my:repeat-char('⠀', $cols)"/>
                    </xsl:element>
                </xsl:variable>
                <xsl:sequence select="my:repeat-node($row, $rows - count(pef:row))"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="my:repeat-char" as="xs:string?">
        <xsl:param name="char" as="xs:string"/>
        <xsl:param name="times" />
        <xsl:if test="$times &gt; 0">
            <xsl:sequence select="concat($char, my:repeat-char($char, $times - 1))"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="my:repeat-node" as="node()*">
        <xsl:param name="element" as="node()"/>
        <xsl:param name="times" />
        <xsl:if test="$times &gt; 0">
            <xsl:sequence select="$element"/>
            <xsl:sequence select="my:repeat-node($element, $times - 1)"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>
