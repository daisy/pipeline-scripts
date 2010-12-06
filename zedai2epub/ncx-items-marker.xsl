<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/ns/z3986/authoring/"
  xmlns:f="http://nwalsh.com/ns/functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:z="http://www.daisy.org/ns/z3986/authoring/" exclude-result-prefixes="f xs z" version="2.0">
  <xsl:param name="chunkdepth" select="2"/>


  <xsl:template match="/">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!--TODO record playorder-->
  
  <xsl:template match="z:pagebreak">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="ncx-type" select="'pageTarget'"/>
      <!--FIXME set the target ID either form @value or @xml:id-->
      <xsl:attribute name="ncx-id" select="if(@xml:id) then @xml:id else concat('p',@value)"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="z:section/z:h[1]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="ncx-type" select="'navPoint'"/>
      <xsl:attribute name="ncx-id" select="if(@xml:id) then @xml:id else generate-id(.)"/>
      <xsl:attribute name="xml:id" select="if(@xml:id) then @xml:id else generate-id(.)"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="comment()|processing-instruction()|text()">
    <xsl:copy/>
  </xsl:template>



</xsl:stylesheet>
