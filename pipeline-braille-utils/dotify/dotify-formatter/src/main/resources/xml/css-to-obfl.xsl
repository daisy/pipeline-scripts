<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/ns/2011/obfl"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0" >
    
    <!--
        css-utils [2.0.0,3.0.0)
    -->
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl" />
    
    <xsl:include href="generate-obfl-layout-master.xsl"/>
    
    <xsl:key name="page-style" match="/css:root" use="string(@css:page)"/>
    
    <xsl:function name="pxi:generate-layout-master-name" as="xs:string">
        <xsl:param name="stylesheet" as="xs:string"/>
        <xsl:value-of select="generate-id((collection()/key('page-style', $stylesheet))[1])"/>
    </xsl:function>
    
    <xsl:template name="main">
        <obfl version="2011-1" xml:lang="und">
            <xsl:for-each select="distinct-values(collection()/css:root/string(@css:page))">
                <xsl:sequence select="obfl:generate-layout-master(., pxi:generate-layout-master-name(.))"/>
            </xsl:for-each>
            <xsl:apply-templates select="collection()/css:root"/>
        </obfl>
    </xsl:template>
    
    <xsl:template match="/css:root">
        <xsl:element name="sequence">
            <xsl:attribute name="master" select="pxi:generate-layout-master-name(string(@css:page))"/>
            <xsl:apply-templates select="(@* except @css:page)|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="/css:root/@obfl:initial-page-number">
        <xsl:attribute name="initial-page-number" select="."/>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']">
        <block>
            <xsl:apply-templates select="@* except (@css:string-entry|@css:string-set)"/>
            <xsl:apply-templates select="@css:string-entry"/>
            <xsl:apply-templates select="@css:string-set"/>
            <xsl:apply-templates/>
        </block>
    </xsl:template>
    
    <xsl:template match="css:box[@type='inline']">
        <xsl:apply-templates select="@* except (@css:string-entry|@css:string-set)"/>
        <xsl:apply-templates select="@css:string-entry"/>
        <xsl:apply-templates select="@css:string-set"/>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="css:box/@name|
                         css:box/@type"/>
    
    <xsl:template match="css:box/@style">
        <xsl:choose>
            <xsl:when test="parent::css:box/@type='block'">
                <xsl:apply-templates select="css:parse-declaration-list(.)" mode="block"/>
            </xsl:when>
            <xsl:when test="parent::css:box/@type='inline'">
                <xsl:apply-templates select="css:parse-declaration-list(.)" mode="inline"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:property[@name=('margin-left','margin-right','margin-top','margin-bottom')]" mode="block">
        <xsl:variable name="value" as="xs:integer" select="xs:integer(number(@value))"/>
        <xsl:if test="$value &gt; 0">
            <xsl:attribute name="{@name}" select="format-number($value, '0')"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:property[@name='text-indent']" mode="block">
        <xsl:variable name="value" as="xs:integer" select="xs:integer(number(@value))"/>
        <xsl:if test="$value &gt; 0">
                <xsl:attribute name="first-line-indent" select="format-number($value, '0')"/>
            </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:property[@name='page-break-before']" mode="block">
        <xsl:if test="@value='always'">
            <xsl:attribute name="break-before" select="'page'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:property[@name='page-break-after']" mode="block">
        <xsl:if test="@value='avoid'">
            <xsl:attribute name="keep-with-next" select="'1'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:property[@name='page-break-inside']" mode="block">
        <xsl:if test="@value='avoid'">
            <xsl:attribute name="keep" select="'all'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:property[@name=(
                           'border-left','border-right','border-top','border-bottom',
                           'padding-left','padding-right','padding-top','padding-bottom',
                           'orphans','widows','text-align')]"
                  mode="block">
        <xsl:message>NOT IMPLEMENTED</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:property" mode="block inline">
        <xsl:message>property not supported</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:target-text-fn">
        <xsl:message>NOT IMPLEMENTED</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:target-string-fn">
        <xsl:message>NOT IMPLEMENTED</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:target-counter-fn">
        <xsl:message>NOT IMPLEMENTED</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:leader-fn">
        <leader pattern="{@pattern}"/>
    </xsl:template>
    
    <xsl:template match="css:box/@css:string-entry|
                         css:box/@css:string-set">
        <xsl:apply-templates select="css:parse-string-set(.)" mode="parse-string-set"/>
    </xsl:template>
    
    <xsl:template match="css:string-set" mode="parse-string-set">
        <xsl:variable name="value" as="xs:string*">
            <xsl:apply-templates select="css:parse-content-list(@value, ())" mode="eval-string-set"/>
        </xsl:variable>
        <marker class="{@identifier}" value="{string-join($value,'')}"/>
    </xsl:template>
    
    <xsl:template match="css:string" mode="eval-string-set" as="xs:string">
        <xsl:value-of select="string(@value)"/>
    </xsl:template>
    
    <xsl:template match="css:white-space">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="text()">
       <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="@*|*">
        <xsl:message terminate="yes">Coding error</xsl:message>
    </xsl:template>
    
</xsl:stylesheet>
