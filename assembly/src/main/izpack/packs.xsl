<?xml version="1.0" encoding="iso-8859-1" standalone="yes" ?>
<xsl:stylesheet xmlns="http://izpack.org/schema/installation"
    xmlns:iz="http://izpack.org/schema/installation"
    xmlns:pom="http://maven.apache.org/POM/4.0.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="iz"
    version="2.0">

  <xsl:param name="pom"/>
  
  <xsl:output method="xml" encoding="utf-8" indent="yes" />
  
  <xsl:template match="iz:packs">
    <xsl:copy>
      <xsl:for-each select="doc($pom)//pom:execution[string(pom:id)='copy-module-bundles']
          /pom:configuration/pom:artifactItems/pom:artifactItem">
        <xsl:call-template name="pack">
          <xsl:with-param name="name" select="string(pom:artifactId)"/>
          <xsl:with-param name="path" select="'modules'"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="doc($pom)//pom:execution[string(pom:id)='copy-system-bundles']
          /pom:configuration/pom:artifactItems/pom:artifactItem">
        <xsl:call-template name="pack">
          <xsl:with-param name="name" select="string(pom:artifactId)"/>
          <xsl:with-param name="path" select="'system/framework'"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="pack">
    <xsl:param name="name"/>
    <xsl:param name="path"/>
    <xsl:element name="pack">
      <xsl:attribute name="name" select="$name"/>
      <xsl:attribute name="required" select="'no'"/>
      <xsl:if test="ends-with($name, '.linux')">
        <xsl:attribute name="condition" select="'is.linux'"/>
      </xsl:if>
      <xsl:if test="ends-with($name, '.mac')">
        <xsl:attribute name="condition" select="'is.mac'"/>
      </xsl:if>
      <xsl:if test="ends-with($name, '.windows')">
        <xsl:attribute name="condition" select="'is.windows'"/>
      </xsl:if>
      <xsl:element name="description"/>
      <xsl:element name="singlefile">
        <xsl:attribute name="src" select="concat($path, '/', $name, '.jar')"/>
        <xsl:attribute name="target" select="concat('$INSTALL_PATH', '/', $path, '/', $name, '.jar')"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
