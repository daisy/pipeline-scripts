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
    
    <xsl:key name="page-style" match="/*|//*[@css:page]" use="string(@css:page)"/>
    
    <xsl:function name="pxi:generate-layout-master-name" as="xs:string">
        <xsl:param name="stylesheet" as="xs:string"/>
        <xsl:value-of select="generate-id((collection()/key('page-style', $stylesheet))[1])"/>
    </xsl:function>
    
    <xsl:template name="main">
        <obfl version="2011-1" xml:lang="und">
            <xsl:for-each select="distinct-values(collection()/*/string(@css:page))">
                <xsl:sequence select="obfl:generate-layout-master(., pxi:generate-layout-master-name(.))"/>
            </xsl:for-each>
            <xsl:for-each select="collection()/*">
               <xsl:element name="sequence">
                   <xsl:attribute name="master" select="pxi:generate-layout-master-name(string(@css:page))"/>
                   <xsl:if test=".//css:counter-reset[@identifier='braille-page']">
                       <xsl:attribute name="initial-page-number" select="@obfl:initial-page-number"/>
                   </xsl:if>
                   <xsl:apply-templates select="."/>
               </xsl:element>
            </xsl:for-each>
        </obfl>
    </xsl:template>
    
    <xsl:template match="/*">
        <xsl:choose>
            <xsl:when test="descendant::css:inline[not(ancestor::css:block)]">
                <block>
                    <xsl:apply-templates/>
                </block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:block">
        <block>
            <xsl:if test="@style">
                <xsl:apply-templates select="css:parse-declaration-list(@style)"/>
            </xsl:if>
            <xsl:apply-templates/>
        </block>
    </xsl:template>
    
    <xsl:template match="css:property[@name=('margin-left','margin-right','margin-top','margin-bottom')]">
        <xsl:variable name="value" as="xs:integer" select="xs:integer(number(@value))"/>
        <xsl:if test="$value &gt; 0">
                <xsl:attribute name="{@name}" select="format-number($value, '0')"/>
            </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:property[@name='text-indent']">
        <xsl:variable name="value" as="xs:integer" select="xs:integer(number(@value))"/>
        <xsl:if test="$value &gt; 0">
                <xsl:attribute name="first-line-indent" select="format-number($value, '0')"/>
            </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:property[@name='page-break-before']">
        <xsl:if test="@value='always'">
            <xsl:attribute name="break-before" select="page"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:property[@name='page-break-after']">
        <xsl:if test="@value='avoid'">
            <xsl:attribute name="keep-with-next" select="1"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:property[@name='page-break-inside']">
        <xsl:if test="@value='avoid'">
            <xsl:attribute name="keep" select="all"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:property">
        <xsl:message>NOT IMPLEMENTED</xsl:message>
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
    
    <xsl:template match="css:white-space">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="text()">
       <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="*|css:inline">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="css:*">
        <xsl:message terminate="yes">Coding error</xsl:message>
    </xsl:template>
    
</xsl:stylesheet>
