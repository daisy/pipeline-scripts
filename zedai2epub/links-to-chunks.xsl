<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/ns/z3986/authoring/"
  xmlns:f="http://www.daisy.org/ns/functions" xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:z="http://www.daisy.org/ns/z3986/authoring/" exclude-result-prefixes="f xs z" version="2.0">

  <xsl:key name="id" match="*" use="@xml:id"/>

  <xsl:template match="/">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="z:ref[@ref]">
    <xsl:variable name="id" select="@ref"/>
    <xsl:variable name="target" select="key('id',@ref)"/>
    <xsl:variable name="target-chunk"
      select="($target/ancestor-or-self::z:*[@chunk])[last()]/@chunk"/>
    <xsl:variable name="target-uri" select="concat($target-chunk,'#',$id)"/>
    <xsl:variable name="chunk-uri" select="ancestor::z:*[@chunk][1]/@chunk"/>

    <xsl:variable name="ref" select="f:resolve-ref($target-uri, $chunk-uri)"/>
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:choose>
          <xsl:when test="name(.) = 'ref' and not(starts-with($ref,'#'))">
            <xsl:attribute name="xlink:href" select="$ref"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
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


  <xsl:function name="f:resolve-ref" as="xs:string">
    <xsl:param name="to-uri" as="xs:string"/>
    <xsl:param name="from-uri" as="xs:string"/>

    <xsl:choose>
      <xsl:when
        test="contains($to-uri,'#') and 
        (contains($from-uri,'#') and substring-before($to-uri,'#') = substring-before($from-uri,'#'))
        or (substring-before($to-uri,'#') = $from-uri)">
        <xsl:value-of select="concat('#', substring-after($to-uri, '#'))"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$to-uri"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
