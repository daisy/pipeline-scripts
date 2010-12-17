<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/ns/z3986/authoring/"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:z="http://www.daisy.org/ns/z3986/authoring/" exclude-result-prefixes="xs z" version="2.0">
  <xsl:param name="chunkdepth" select="2"/>


  <xsl:template match="/">
    <xsl:variable name="marked">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:apply-templates select="$marked" mode="playOrder"/>
  </xsl:template>
  

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
      <!--generate ID and + resolve against chunk -->
      <xsl:variable name="chunk-uri" select="ancestor-or-self::z:*[@chunk][1]/@chunk"/>
      <xsl:variable name="ncx-id" select="if(@xml:id) then  @xml:id else generate-id()"/>
      <xsl:attribute name="ncx:id" select="if($chunk-uri) then concat($chunk-uri,'#',$ncx-id) else $ncx-id"/>
      <xsl:if test="not(@xml:id)">
          <xsl:attribute name="xml:id" select="generate-id()"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[@ncx:id]">
    <xsl:variable name="chunk-uri" select="ancestor::z:*[@chunk][1]/@chunk"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="ncx-id" select="concat($chunk-uri,'#',@ncx-id)"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!--=============================================================================-->
  <!--====                  mode 'playOrder'                                   ====-->
  <!--=============================================================================-->
  
  <xsl:template match="*[@ncx:type]" mode="playOrder">
    <xsl:copy>
      <xsl:attribute name="ncx:playOrder">
        <xsl:number count="*[@ncx:type]" level="any"/>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="playOrder"/>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="*"  mode="playOrder">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="playOrder"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="comment()|processing-instruction()|text()"  mode="playOrder">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
