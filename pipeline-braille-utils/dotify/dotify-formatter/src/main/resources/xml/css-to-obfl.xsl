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
    
    <xsl:template match="/css:root/@css:counter-set-page">
        <xsl:attribute name="initial-page-number" select="."/>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']">
        <block>
            <xsl:apply-templates select="@* except (@type|@name|@part|@css:string-entry|@css:string-set)"/>
            <xsl:apply-templates select="@css:string-entry"/>
            <xsl:apply-templates select="@css:string-set"/>
            <xsl:apply-templates/>
        </block>
    </xsl:template>
    
    <xsl:template match="css:box[@type='inline']">
        <xsl:apply-templates select="@* except (@type|@name|@part|@css:string-entry|@css:string-set)"/>
        <xsl:apply-templates select="@css:string-entry"/>
        <xsl:apply-templates select="@css:string-set"/>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="css:box/@css:collapsing-margins"/>
    
    <xsl:template match="css:box/@style">
        <xsl:apply-templates select="css:specified-properties('#all', true(), true(), true(), parent::*)"
                             mode="property">
            <xsl:with-param name="type" select="parent::*/@type"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="css:property" mode="property">
        <xsl:param name="type" as="xs:string"/>
        <xsl:variable name="property-attribute" as="attribute()">
            <xsl:apply-templates select="." mode="css:property-as-attribute"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$type='block'">
                <xsl:apply-templates select="$property-attribute" mode="block-property"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$property-attribute" mode="inline-property"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:box/@css:margin-left|
                         css:box/@css:margin-right|
                         css:box/@css:margin-top|
                         css:box/@css:margin-bottom">
        <xsl:choose>
            <xsl:when test="parent::*/@type='block'">
                <xsl:apply-templates select="." mode="block-property"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="inline-property"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@css:margin-left|
                         @css:margin-right|
                         @css:margin-top|
                         @css:margin-bottom" mode="block-property">
        <xsl:variable name="value" as="xs:integer" select="xs:integer(number(.))"/>
        <xsl:if test="$value &gt; 0">
            <xsl:attribute name="{local-name()}" select="format-number($value, '0')"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@css:text-indent" mode="block-property">
        <xsl:variable name="value" as="xs:integer" select="xs:integer(number(.))"/>
        <xsl:if test="$value &gt; 0">
                <xsl:attribute name="first-line-indent" select="format-number($value, '0')"/>
            </xsl:if>
    </xsl:template>
    
    <xsl:template match="@css:text-align" mode="block-property">
        <xsl:attribute name="align" select="."/>
    </xsl:template>
    
    <xsl:template match="@css:page-break-before" mode="block-property">
        <xsl:if test=".='always'">
            <xsl:attribute name="break-before" select="'page'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@css:page-break-after" mode="block-property">
        <xsl:if test=".='avoid'">
            <xsl:attribute name="keep-with-next" select="'1'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@css:page-break-inside" mode="block-property">
        <xsl:if test=".='avoid'">
            <xsl:attribute name="keep" select="'all'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@css:border-left|
                         @css:border-right" mode="block-property">
        <xsl:choose>
            <xsl:when test=".='none'"/>
            <xsl:when test=".=('⠇','⠿','⠸')">
                <xsl:attribute name="{local-name()}-style" select="'solid'"/>
                <xsl:choose>
                    <xsl:when test=".='⠿'">
                        <xsl:attribute name="{local-name()}-width" select="'2'"/>
                    </xsl:when>
                    <xsl:when test=".='⠇'">
                        <xsl:attribute name="{local-name()}-align"
                                       select="if (local-name()='border-left') then 'outer' else 'inner'"/>
                    </xsl:when>
                    <xsl:when test=".='⠸'">
                        <xsl:attribute name="{local-name()}-align"
                                       select="if (local-name()='border-right') then 'outer' else 'inner'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>border value not supported</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@css:border-top|
                         @css:border-bottom" mode="block-property">
        <xsl:choose>
            <xsl:when test=".='none'"/>
            <xsl:when test=".=('⠉','⠛','⠿','⠶','⠤')">
                <xsl:attribute name="{local-name()}-style" select="'solid'"/>
                <xsl:choose>
                    <xsl:when test=".=('⠛','⠶')">
                        <xsl:attribute name="{local-name()}-width" select="'2'"/>
                    </xsl:when>
                    <xsl:when test=".='⠿'">
                        <xsl:attribute name="{local-name()}-width" select="'3'"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test=".=('⠉','⠛')">
                        <xsl:attribute name="{local-name()}-align"
                                       select="if (local-name()='border-top') then 'outer' else 'inner'"/>
                    </xsl:when>
                    <xsl:when test=".=('⠶','⠤')">
                        <xsl:attribute name="{local-name()}-align"
                                       select="if (local-name()='border-top') then 'inner' else 'outer'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>border value not supported</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@css:orphans|
                         @css:widows" mode="block-property">
        <xsl:message>NOT IMPLEMENTED</xsl:message>
    </xsl:template>
    
    <xsl:template match="@css:display|
                         @css:white-space|
                         @css:content|
                         @css:string-set|
                         @css:counter-reset|
                         @css:padding-left|
                         @css:padding-right|
                         @css:padding-top|
                         @css:padding-bottom" mode="block-property inline-property">
        <xsl:message terminate="yes">Coding error</xsl:message>
    </xsl:template>
    
    <xsl:template match="@css:margin-left|
                         @css:margin-right|
                         @css:margin-top|
                         @css:margin-bottom|
                         @css:text-indent|
                         @css:text-align|
                         @css:page-break-before|
                         @css:page-break-after|
                         @css:page-break-inside|
                         @css:border-left|
                         @css:border-right|
                         @css:border-top|
                         @css:border-bottom|
                         @css:orphans|
                         @css:widows" mode="inline-property"/>
    
    <xsl:template match="@css:*" mode="block-property inline-property">
        <xsl:message>Unknown property</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:text[@target]">
        <xsl:message>NOT IMPLEMENTED</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:string[@name][@target]">
        <xsl:message>NOT IMPLEMENTED</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:counter[@target]">
        <xsl:message>NOT IMPLEMENTED</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:leader">
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
        <marker class="{@name}" value="{string-join($value,'')}"/>
    </xsl:template>
    
    <xsl:template match="css:string[@value]" mode="eval-string-set" as="xs:string">
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
