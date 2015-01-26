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
    
    <xsl:key name="page-style" match="/*" use="string(@css:page)"/>
    
    <xsl:function name="pxi:generate-layout-master-name" as="xs:string">
        <xsl:param name="stylesheet" as="xs:string"/>
        <xsl:value-of select="generate-id((collection()/key('page-style', $stylesheet))[1])"/>
    </xsl:function>
    
    <xsl:template name="main">
        <obfl version="2011-1" xml:lang="und">
            <xsl:for-each select="distinct-values(collection()/*/string(@css:page))">
                <xsl:sequence select="obfl:generate-layout-master(., pxi:generate-layout-master-name(.))"/>
            </xsl:for-each>
            <xsl:apply-templates select="collection()/*[not(@css:flow)]"/>
        </obfl>
    </xsl:template>
    
    <xsl:template match="/*" priority="0.6">
        <xsl:element name="sequence">
            <xsl:attribute name="master" select="pxi:generate-layout-master-name(string(@css:page))"/>
            <xsl:if test="@css:counter-set-page">
                <xsl:attribute name="initial-page-number" select="@css:counter-set-page"/>
            </xsl:if>
            <xsl:next-match/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="/*/@css:counter-set-page|
                         /*/@css:page"/>
    
    <xsl:template match="/css:_">
        <xsl:apply-templates select="@*|node()"/>
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
    
    <xsl:template match="css:box/@type|
                         css:box/@name|
                         css:box/@part"/>
    
    <xsl:template match="@css:collapsing-margins"/>
    
    <xsl:template match="@css:margin-left|
                         @css:margin-right|
                         @css:margin-top|
                         @css:margin-bottom">
        <xsl:attribute name="{local-name()}" select="format-number(xs:integer(number(.)), '0')"/>
    </xsl:template>
    
    <xsl:template match="@css:text-indent">
        <xsl:attribute name="first-line-indent" select="format-number(xs:integer(number(.)), '0')"/>
    </xsl:template>
    
    <xsl:template match="@css:text-align">
        <xsl:attribute name="align" select="."/>
    </xsl:template>
    
    <xsl:template match="@css:page-break-before">
        <xsl:if test=".='always'">
            <xsl:attribute name="break-before" select="'page'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@css:page-break-after">
        <xsl:if test=".='avoid'">
            <xsl:attribute name="keep-with-next" select="'1'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@css:page-break-inside">
        <xsl:if test=".='avoid'">
            <xsl:attribute name="keep" select="'all'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@css:border-left|
                         @css:border-right">
        <xsl:choose>
            <xsl:when test=".='none'">
                <xsl:attribute name="{local-name()}-style" select="'none'"/>
            </xsl:when>
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
                         @css:border-bottom">
        <xsl:choose>
            <xsl:when test=".='none'">
                <xsl:attribute name="{local-name()}-style" select="'none'"/>
            </xsl:when>
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
                         @css:widows">
        <xsl:message>NOT IMPLEMENTED</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:string[@name]">
        <xsl:variable name="target" as="xs:string?" select="@target"/>
        <xsl:variable name="target" as="element()?"
                      select="if ($target) then collection()//*[@css:id=$target][1] else ."/>
        <xsl:if test="$target">
            <xsl:apply-templates select="css:string(@name, $target)" mode="eval-string-set"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:counter[@target][@name='page']">
        <page-number ref-id="{@target}" style="{if (@style=('roman', 'upper-roman', 'lower-roman', 'upper-alpha', 'lower-alpha'))
                                               then @style else 'default'}"/>
    </xsl:template>
    
    <xsl:template match="css:leader">
        <leader pattern="{@pattern}" position="100%" align="right"/>
    </xsl:template>
    
    <xsl:template match="css:box/@css:id">
        <xsl:attribute name="id" select="."/>
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
