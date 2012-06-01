<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all" version="2.0">

  <xsl:output method="xhtml" indent="yes"/>

  <xsl:param name="base" select="base-uri(/*)"/>
  <xsl:param name="basename" select="replace($base,'.*/([^/]+)(\.[^.]+)','$1')"/>

  <xsl:key name="ids" match="*" use="@id|@xml:id"/>

  <xsl:variable name="chunks" select="f:get-chunks(/)" as="element()*"/>

  <xsl:template match="/">
    <xsl:for-each select="$chunks">
      <xsl:result-document href="{resolve-uri(f:get-chunk-name(.),$base)}">
        <xsl:call-template name="create-chunk-doc"/>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="create-chunk-doc">
    <html>
      <xsl:copy-of select="/html/((@* except @xml:base) | namespace::*)"/>
      <xsl:apply-templates select="/html/head"/>
      <body>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates select="node()"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="@href[starts-with(.,'#')]">
    <xsl:variable name="refid" select="substring(.,2)" as="xs:string"/>
    <xsl:variable name="mychunk" select="ancestor::*[.=$chunks][1]"/>
    <xsl:variable name="refchunk" select="key('ids',$refid)/ancestor::*[.=$chunks][1]"/>
    <xsl:attribute name="href"
      select="if ($mychunk = $refchunk) then . else concat(f:get-chunk-name($refchunk),.)"/>
  </xsl:template>

  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="f:get-chunk-name">
    <xsl:param name="chunk" as="element()"/>
    <xsl:value-of
      select="concat($basename,'-',1+count($chunks[. &lt;&lt; $chunk]),'.xhtml')"
    />
  </xsl:function>

  <xsl:function name="f:get-chunks" as="element()*">
    <xsl:param name="doc" as="document-node()"/>
    <xsl:sequence select="$doc/html/body/section"/>
    <!--TODO bodymatter chunks: lose some structure ???-->
    <!--  <xsl:sequence
      select="//body/section[@epub:type=('frontmatter','backmatter')] 
      | //section[@epub:type='bodymatter']/section"/>-->
  </xsl:function>

</xsl:stylesheet>
