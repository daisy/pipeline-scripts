<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

  <xsl:output method="xhtml" indent="yes" doctype-public="-//W3C//DTD XHTML 1.1//EN"
    doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>

  <xsl:param name="base" select="base-uri(/*)"/>
  <xsl:param name="basename" select="replace($base,'.*/([^/]+)(\.[^.]+)','$1')"/>

  <!--TODO bodymatter chunks: lose some structure ???-->
  <xsl:variable name="chunks" select="/html/body/section"/>
  <!--  <xsl:variable name="chunks"
    select="//body/section[@epub:type=('frontmatter','backmatter')] 
    | //section[@epub:type='bodymatter']/section"/>-->

  <xsl:template match="/">
    <xsl:for-each select="$chunks">
      <xsl:result-document href="{resolve-uri(concat($basename,'-',position(),'.xhtml'),$base)}">
        <xsl:call-template name="html">
          <xsl:with-param name="chunk" select="."/>
        </xsl:call-template>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="html">
    <xsl:param name="chunk" as="element()"/>
    <html xml:lang="en">
      <head>
        <title><xsl:value-of select="/html/head/title"/></title>
      </head>
      <body>
        <xsl:copy-of select="$chunk/@*"/>
        <xsl:apply-templates select="$chunk/node()"/>
      </body>
    </html>
  </xsl:template>


  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
