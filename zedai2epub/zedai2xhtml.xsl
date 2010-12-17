<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:f="http://www.daisy.org/ns/functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:z="http://www.daisy.org/ns/z3986/authoring/" exclude-result-prefixes="f xs z" version="2.0">

  <xsl:output method="xhtml" indent="yes" doctype-public="-//W3C//DTD XHTML 1.1//EN"
    doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>

  <xsl:param name="base" select="'file:///Users/Romain/Desktop/'"/>

  <xsl:template match="/">
    <xsl:variable name="chunks" select="//*[@chunk]"/>
    <xsl:choose>
      <xsl:when test="$chunks">
        <xsl:for-each select="$chunks">
          <xsl:result-document href="{resolve-uri(@chunk,$base)}">
            <xsl:call-template name="html">
              <xsl:with-param name="nodes" select="."/>
            </xsl:call-template>
          </xsl:result-document>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="html">
          <xsl:with-param name="nodes" select="z:document/z:body/*"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="html">
    <xsl:param name="nodes" as="node()*"/>
    <html xml:lang="en">
      <head>
        <title>Alice's Adventures In Wonderland</title>
        <meta name="dcterms:identifier" content="com.googlecode.zednext.alice"/>
        <meta name="dcterms:publisher" content="CSU"/>
        <meta name="dcterms:date" content="2010-03-27T13:50:05-02:00"/>
      </head>
      <body>
        <xsl:apply-templates select="$nodes"/>
      </body>
    </html>
  </xsl:template>

  <!--===========================================================-->
  <!-- Translation templates                                     -->
  <!--===========================================================-->

  <xsl:template match="z:block">
    <div>
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="z:bodymatter">
    <div class="bodymatter">
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="z:d">
    <span class="dialog">
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="z:emph">
    <em>
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </em>
  </xsl:template>

  <xsl:template match="z:entry">
    <p>
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="z:frontmatter">
    <div class="frontmatter">
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="z:h">
    <xsl:variable name="level" select="count(ancestor::z:section)"/>
    <xsl:element
      name="{concat('h',if ($level = 0) then '1' else if ($level le 6) then $level else '6')}">
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="z:hpart">
    <span>
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="z:ln">
    <p>
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="z:lngroup">
    <div class="lngroup">
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="z:name">
    <span class="name">
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="z:object">
    <xsl:choose>
      <xsl:when test="starts-with(@srctype,'image/')">
        <img src="{@src}" alt="{normalize-space()}">
          <xsl:call-template name="attrs"/>
        </img>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="z:p">
    <p>
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="z:pagebreak">
    <a class="page-normal">
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="z:ref">
    <a href="{concat('#',@ref)}">
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  <xsl:template match="z:section">
    <div class="section">
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="z:separator">
    <hr>
      <xsl:call-template name="attrs"/>
    </hr>
  </xsl:template>

  <xsl:template match="z:time">
    <span class="time">
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="z:toc">
    <div class="toc">
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>


  <xsl:template match="z:verse">
    <div class="verse">
      <xsl:call-template name="attrs"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!--===========================================================-->
  <!-- Identity templates                                        -->
  <!--===========================================================-->

  <xsl:template match="comment()|processing-instruction()|text()">
    <xsl:copy/>
  </xsl:template>

  <!--===========================================================-->
  <!-- Named templates                                           -->
  <!--===========================================================-->

  <xsl:template name="attrs">
    <xsl:if test="@xml:id">
      <xsl:attribute name="id">
        <xsl:value-of select="@xml:id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="@xml:lang"/>
  </xsl:template>
</xsl:stylesheet>
