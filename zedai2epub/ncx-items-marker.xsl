<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/ns/z3986/authoring/"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:z="http://www.daisy.org/ns/z3986/authoring/" exclude-result-prefixes="xs z" version="2.0">
  <xsl:param name="chunkdepth" select="2"/>


  <xsl:template match="/">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!--TODO record playorder-->

  <xsl:template match="z:pagebreak">
    <xsl:call-template name="annotate-ncx-item">
      <xsl:with-param name="type" select="'pageList'"/>
      <xsl:with-param name="label" select="normalize-space(@value)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="z:section[z:h|z:hd]">
    <xsl:call-template name="annotate-ncx-item">
      <xsl:with-param name="label" select="normalize-space((z:h|z:hd)[1])"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="bibliography|glossary">
    <xsl:call-template name="annotate-ncx-item">
      <!--FIXME get bibliography/glossary label-->
      <xsl:with-param name="label" select="normalize-space((z:h|z:hd)[1])"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="toc">
    <xsl:call-template name="annotate-ncx-item">
      <!--FIXME get toc label-->
      <xsl:with-param name="label" select="normalize-space((z:h|z:hd)[1])"/>
    </xsl:call-template>
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

  <xsl:template name="annotate-ncx-item" as="item()*">
    <xsl:param name="type" as="xs:string" select="'navMap'"/>
    <xsl:param name="label" as="xs:string" required="yes"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="ncx:type" select="$type"/>
      <xsl:attribute name="ncx:label" select="$label"/>
      <xsl:choose>
        <xsl:when test="@xml:id">
          <xsl:attribute name="ncx:id" select="@xml:id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="xml:id" select="generate-id()"/>
          <xsl:attribute name="ncx:id" select="generate-id()"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
