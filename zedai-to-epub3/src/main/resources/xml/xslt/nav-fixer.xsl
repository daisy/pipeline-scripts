<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all" version="2.0">

  <xsl:output method="xhtml" indent="yes"/>

  <!--Unwraps all the "Untitled Document" top-level children of the Navigation Document-->
  <!--FIXME this is a naive hack, this should be handled upfront with a better chunking mechanism-->
  
  <xsl:template match="nav/ol/li">
    <xsl:apply-templates select="ol/*"/>
  </xsl:template>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  

</xsl:stylesheet>
