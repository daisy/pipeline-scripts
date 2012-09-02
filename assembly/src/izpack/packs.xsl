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
      <xsl:for-each select="doc($pom)//pom:execution[string(pom:id)='copy-bundles']
          /pom:configuration/pom:artifactItems/pom:artifactItem">
        <xsl:variable name="group-id" select="string(pom:groupId)"/>
        <xsl:variable name="artifact-id" select="string(pom:artifactId)"/>
        <xsl:element name="pack">
          <xsl:attribute name="name" select="$artifact-id"/>
          <xsl:attribute name="required" select="'no'"/>
          <xsl:if test="ends-with($artifact-id, '.linux')">
            <xsl:attribute name="condition" select="'is.linux'"/>
          </xsl:if>
          <xsl:if test="ends-with($artifact-id, '.mac')">
            <xsl:attribute name="condition" select="'is.mac'"/>
          </xsl:if>
          <xsl:if test="ends-with($artifact-id, '.windows')">
            <xsl:attribute name="condition" select="'is.windows'"/>
          </xsl:if>
          <xsl:element name="description"/>
          <xsl:element name="singlefile">
            <xsl:attribute name="src" select="concat('bundles/', $artifact-id, '.jar')"/>
            <xsl:attribute name="target" select="concat('$INSTALL_PATH', '/',
                (if($group-id='org.daisy.pipeline.modules.braille')
                  then 'modules/' else 'system/framework/'),
                $artifact-id, '.jar')"/>
          </xsl:element>
        </xsl:element>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
