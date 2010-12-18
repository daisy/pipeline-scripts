<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:f="http://www.daisy.org/ns/functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="f xs" version="2.0">


  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="c:manifest">
    <c:zip-manifest>
      <xsl:apply-templates/>
    </c:zip-manifest>
  </xsl:template>
  
  <xsl:template match="c:entry">
    <c:entry name="{@href}" href="{resolve-uri(@href,base-uri(/*))}"/>
  </xsl:template>

  <xsl:template match="text()|comment()|processing-instruction()"/>

</xsl:stylesheet>
