<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="xs louis css"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/xslt/library.xsl"/>
    
    <xsl:variable name="liblouis-properties" as="xs:string*"
        select="('-louis-reset-margin-left',
                 '-louis-reset-margin-right',
                 'display',
                 'margin-top',
                 'margin-bottom',
                 'text-align',
                 'text-indent',
                 'page-break-before',
                 'page-break-after',
                 'page-break-inside',
                 'orphans')"/>
    
    <xsl:variable name="liblouis-defaults" as="xs:string*"
        select="('inherit',
                 'inherit',
                 'inline',
                 '0.0',
                 '0.0',
                 'inherit',
                 'inherit',
                 'auto',
                 'auto',
                 'auto',
                 '0.0')"/>
    
    <xsl:template match="@*|text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="element()">
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name()='style')]"/>
            <xsl:call-template name="normalized-style-attribute"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="louis:box|
                         *[@css:toc-item]">
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name()='style')]"/>
            <xsl:call-template name="normalized-style-attribute">
                <xsl:with-param name="force-inherit" select="true()"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="louis:border|
                         louis:line|
                         louis:print-page|
                         louis:page-layout">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="*[descendant::*[@css:toc-item] and normalize-space(string(.))='']">
        <xsl:variable name="normalized-style-attribute" as="attribute()?">
            <xsl:call-template name="normalized-style-attribute"/>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name()='style')]"/>
            <xsl:if test="not(every $declaration in css:tokenize-declarations(string($normalized-style-attribute))
                          satisfies normalize-space(substring-before($declaration,':'))
                              =('display','orphans','-louis-reset-margin-left','text-indent'))">
                <xsl:sequence select="$normalized-style-attribute"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="normalized-style-attribute">
        <xsl:param name="force-inherit" as="xs:boolean" select="false()"/>
        <xsl:variable name="this" select="." as="element()"/>
        <xsl:variable name="display" select="css:get-value(., 'display', true(), true(), true())"/>
        <xsl:variable name="declarations" as="xs:string*">
            <xsl:for-each select="$liblouis-properties">
                <xsl:if test="not($this/ancestor-or-self::louis:box and .=$css:paged-media-properties)">
                    <xsl:if test="$this/self::louis:box or css:applies-to(., $display) or starts-with(., '-louis-')">
                        <xsl:variable name="i" select="position()"/>
                        <xsl:variable name="liblouis-default"
                            select="$liblouis-defaults[$i]"/>
                        <xsl:variable name="concretize-inherit"
                            select="$force-inherit or $liblouis-default!='inherit'"/>
                        <xsl:variable name="include-default"
                            select="not(starts-with(., '-louis-')) and $liblouis-default!=css:get-default-value(.)"/>
                        <xsl:variable name="value" as="xs:string?"
                            select="css:get-value($this, ., $concretize-inherit, $include-default, not(starts-with(., '-louis-')))"/>
                        <xsl:if test="$value and $value!=$liblouis-default">
                            <xsl:sequence select="concat(., ': ', $value)"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="exists($declarations)">
            <xsl:attribute name="style" select="string-join($declarations, '; ')"/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
