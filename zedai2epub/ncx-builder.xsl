<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:f="http://www.daisy.org/ns/functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:z="http://www.daisy.org/ns/z3986/authoring/" exclude-result-prefixes="f ncx xs z" version="2.0">

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <ncx version="2005-1" xml:lang="{(/z:document/@xml:lang,/z:document/z:body/@xml:lang,'en')[1]}">
      <head>
        <meta name="dtb:uid"
          content="{z:document/z:head/z:meta[@property='dcterms:identifier']/@content}"/>
        <meta name="dtb:depth" 
          content="{max(for $n in //*[@ncx:type='navMap'] return count($n/ancestor-or-self::*[@ncx:type='navMap']))}"/>
        <meta name="dtb:generator" content="DAISY Pipeline 2"/>
        <!--TODO function to get the Pipeline version ?-->
        <meta name="dtb:totalPageCount" content="{f:page-count(/)}"/>
        <meta name="dtb:maxPageNumber" content="{f:max-page-number(/)}"/>
      </head>

      <docTitle>
        <text>
          <xsl:value-of select="f:doc-title(/)"/>
        </text>
      </docTitle>
      <docAuthor>
        <text>
          <xsl:value-of select="f:doc-author(/)"/>
        </text>
      </docAuthor>

      <navMap>
        <xsl:apply-templates mode="navMap"/>
      </navMap>

        <xsl:if test="//z:pagebreak[@ncx:type='pageList']">
          <pageList>
            <navLabel>
              <text>Page List</text>
            </navLabel>
            <xsl:apply-templates select="//z:pagebreak[@ncx:type='pageList']" mode="pageList"/>
          </pageList>
        </xsl:if>
      
      <xsl:if test="//z:*[@ncx:type='navList']">
        <!--FIXME build navList(s)-->
      </xsl:if>
    </ncx>
  </xsl:template>

  <xsl:template match="z:*[@ncx:type='navMap']" mode="navMap">

    <navPoint id="{generate-id(.)}" playOrder="{@playOrder}">
      <xsl:if test="@class">
        <xsl:attribute name="class" select="@class"/>
      </xsl:if>

      <navLabel>
        <text>
          <xsl:value-of select="normalize-space(@ncx:label)"/>
        </text>
      </navLabel>

      <content src="{@ncx:id}"/>

      <xsl:apply-templates mode="navMap"/>
    </navPoint>
  </xsl:template>

  <xsl:template match="*" mode="navMap">
    <xsl:apply-templates mode="navMap"/>
  </xsl:template>

  <xsl:template match="comment()|processing-instruction()|text()" mode="navMap"/>

  <xsl:template match="z:pagebreak" mode="pageList">

    <pageTarget id="{generate-id(.)}" playOrder="{@playOrder}">
      <xsl:if test="@class">
        <xsl:attribute name="class" select="@class"/>
      </xsl:if>
      
      <xsl:choose>
        <xsl:when test="@value castable as xs:integer">
          <xsl:attribute name="type" select="'normal'"/>
          <xsl:attribute name="value" select="@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="type" select="if (ancestor::z:frontmatter) then 'front' else 'special'"/>
          <xsl:variable name="roman" select="f:roman-to-int(@value)"/>
          <!--FIXME convert special page values-->
          <xsl:attribute name="value" select="if ($roman>0) then $roman else @value"/>
        </xsl:otherwise>
      </xsl:choose>

      <navLabel>
        <text>
          <xsl:value-of select="normalize-space(@ncx:label)"/>
        </text>
      </navLabel>

      <content src="{@ncx:id}"/>

    </pageTarget>
  </xsl:template>

  <xsl:function name="f:doc-title" as="xs:string">
    <xsl:param name="doc" as="document-node()"/>
    <!--TODO resolve CURIE-->
    <!--
      Refine the algorithm, e.g. pick the first from:
      - *[@property='fulltitle']
      - *[@property='title']
      - *[@property='dcterms:title']
      - z:h | z:hd
    -->
    <xsl:value-of select="normalize-space($doc//*[@property='dcterms:title'][1])"/>

  </xsl:function>
  <xsl:function name="f:doc-author" as="xs:string">
    <xsl:param name="doc" as="document-node()"/>
    <xsl:value-of select="normalize-space($doc//*[@property='dcterms:creator'][1])"/>
  </xsl:function>
  
  <xsl:function name="f:max-page-number" as="xs:integer">
    <xsl:param name="doc" as="document-node()"/>
    <xsl:value-of
      select="max($doc//z:pagebreak/@value/(if (. castable as xs:integer) then xs:integer(.) else ()))"
    />
  </xsl:function>
  
  <xsl:function name="f:page-count" as="xs:integer">
    <xsl:param name="doc" as="document-node()"/>
    <xsl:value-of select="count($doc//z:pagebreak)"/>
  </xsl:function>
  
  <xsl:function name="f:roman-to-int" as="xs:integer">
    <xsl:param name="r" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="ends-with($r,'XC')">
        <xsl:sequence select="90 + f:roman-to-int(substring($r,1,string-length($r)-2))"/>
      </xsl:when>
      <xsl:when test="ends-with($r,'L')">
        <xsl:sequence select="50 + f:roman-to-int(substring($r,1,string-length($r)-1))"/>
      </xsl:when>
      <xsl:when test="ends-with($r,'C')">
        <xsl:sequence select="100 + f:roman-to-int(substring($r,1,string-length($r)-1))"/>
      </xsl:when>
      <xsl:when test="ends-with($r,'D')">
        <xsl:sequence select="500 + f:roman-to-int(substring($r,1,string-length($r)-1))"/>
      </xsl:when>
      <xsl:when test="ends-with($r,'M')">
        <xsl:sequence select="1000 + f:roman-to-int(substring($r,1,string-length($r)-1))"/>
      </xsl:when>
      <xsl:when test="ends-with($r,'IV')">
        <xsl:sequence select="4 + f:roman-to-int(substring($r,1,string-length($r)-2))"/>
      </xsl:when>
      <xsl:when test="ends-with($r,'IX')">
        <xsl:sequence select="9 + f:roman-to-int(substring($r,1,string-length($r)-2))"/>
      </xsl:when>
      <xsl:when test="ends-with($r,'IIX')">
        <xsl:sequence select="8 + f:roman-to-int(substring($r,1,string-length($r)-2))"/>
      </xsl:when>
      <xsl:when test="ends-with($r,'I')">
        <xsl:sequence select="1 + f:roman-to-int(substring($r,1,string-length($r)-1))"/>
      </xsl:when>
      <xsl:when test="ends-with($r,'V')">
        <xsl:sequence select="5 + f:roman-to-int(substring($r,1,string-length($r)-1))"/>
      </xsl:when>
      <xsl:when test="ends-with($r,'X')">
        <xsl:sequence select="10 + f:roman-to-int(substring($r,1,string-length($r)-1))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  

</xsl:stylesheet>
