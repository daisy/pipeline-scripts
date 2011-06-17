<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/ns/z3986/authoring/"
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:f="http://www.daisy.org/ns/functions"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:z="http://www.daisy.org/ns/z3986/authoring/" exclude-result-prefixes="f xlink xs z"
  version="2.0">

  <!--<doc>
    <p>Gets the satellite files referenced from a ZedAI document</p>
    <p>From the core elements:</p>
    <ul>
      <li>//object/@src (possibly combined with //object/@srctype</li>
      <li>//separator/@src</li>
      <li>//description/@xlink:href</li>
      <li>//ref/@xlink:href</li>
    </ul>
    <p>If the SVG feature is present:</p>
    <ul>
      <li>//object/@src with @srctype="image/svg+xml</li>
    </ul>
    <p>Internal-only links:</p>
    <ul>
      <li>//abbr/@ref pointing to a //definition</li>
      <li>//annoref/@ref pointing to a //annotation</li>
      <li>//annotation/@ref pointing to a //*[@xml:id]</li>
      <li>//caption/@ref pointing to the component(s) to which the caption applies.</li>
      <li>//citation/@ref pointing to the passage (epigraph, quote, etc.) that constitutes the
        quotation</li>
      <li>//d/@ref pointing to a character in a dramatis personae</li>
      <li>//description/@ref</li>
      <li>//hd/@ref pointing to the construct that it acts as a heading for.</li>
      <li>//note/@ref if the note hasn't a referent noteref</li>
      <li>//noteref/@ref pointing to its associated note</li>
      <li>//ref/@ref</li>
      <li>//term/@ref pointing to a definition</li>
    </ul>
    <p>Non-retrieved links:</p>
    <ul>
      <li>//citation/@xlink:href</li>
    </ul>
    </doc>-->
  
  <xsl:output method="xml" indent="yes" />

  <xsl:template match="/">
    <c:manifest xml:base="{replace(base-uri(),'[^/]+$','')}">
      <xsl:apply-templates/>
    </c:manifest>
  </xsl:template>

  <xsl:template match="z:object">
    <xsl:call-template name="entry">
      <xsl:with-param name="href" select="@src"/>
      <xsl:with-param name="media-type" select="@srctype"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="text()|comment()|processing-instruction()"/>
  
  <xsl:template name="entry">
    <xsl:param name="href" required="yes" as="xs:anyURI"/>
    <xsl:param name="media-type" required="no" as="xs:string"/>
    <c:entry href="{$href}">
      <xsl:if test="base-uri() != base-uri(/)">
        <xsl:attribute name="xml:base" select="replace(base-uri(),'[^/]+$','')"/>
      </xsl:if>
      <xsl:if test="$media-type">
        <xsl:attribute name="media-type" select="$media-type"/>
      </xsl:if>
    </c:entry>
  </xsl:template>

</xsl:stylesheet>
