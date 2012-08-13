<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="xs louis css"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl" />

    <xsl:variable name="liblouis-properties" as="xs:string*"
        select="('louis-abs-margin-left',
                 'louis-abs-margin-right',
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
    
    <xsl:template match="louis:vertical-border|
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
                         louis:preformatted|
                         louis:line|
                         louis:toc|
                         louis:toc//*[not(@css:toc-item)]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="normalized-style-attribute">
        <xsl:param name="force-inherit" as="xs:boolean" select="false()"/>
        <xsl:variable name="element" select="." as="element()"/>
        <xsl:variable name="name-value-pairs" as="xs:string*">
            <xsl:for-each select="$liblouis-properties">
                <xsl:variable name="i" select="position()"/>
                <xsl:variable name="liblouis-default"
                    select="$liblouis-defaults[$i]"/>
                <xsl:variable name="concretize-inherit"
                    select="$force-inherit or $liblouis-default!='inherit'"/>
                <xsl:variable name="include-default"
                    select="not(starts-with(., 'louis-')) and $liblouis-default!=css:get-default-value(.)"/>
                <xsl:variable name="value" as="xs:string?"
                    select="css:get-property-value($element, ., $concretize-inherit, $include-default, false())"/>
                <xsl:if test="$value and $value!=$liblouis-default">
                    <xsl:sequence select="concat(., ':', $value)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="$name-value-pairs[1]">
            <xsl:attribute name="style" select="string-join($name-value-pairs,';')"/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
