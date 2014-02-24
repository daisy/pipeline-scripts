<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline type="pxi:test-content" name="main"
            xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
            xmlns:p="http://www.w3.org/ns/xproc"
            version="1.0">
  
  <p:xslt>
    <p:input port="source">
      <p:inline>
        <template/>
      </p:inline>
      <p:pipe step="main" port="source"/>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0"
                        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
                        xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
                        xmlns:xlink="http://www.w3.org/1999/xlink"
                        xmlns:xs="http://www.w3.org/2001/XMLSchema"
                        xmlns:pf="http://www.daisy.org/ns/pipeline/functions">
          
          <xsl:import href="../../main/resources/xml/content.xsl"/>
          <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>
          
          <xsl:template match="/">
            <xsl:variable name="result" as="element()*">
              <xsl:apply-templates select="collection()[2]/*" mode="office:text"/>
            </xsl:variable>
            <xsl:apply-templates select="$result" mode="post"/>
          </xsl:template>
          
          <xsl:template match="/wrapper" mode="office:text">
            <xsl:copy>
              <xsl:apply-templates select="*" mode="#current"/>
            </xsl:copy>
          </xsl:template>
          
          <xsl:template match="@*|node()" mode="post">
            <xsl:copy>
              <xsl:apply-templates select="@*|node()" mode="#current"/>
            </xsl:copy>
          </xsl:template>
          
          <!--
              Relativize image hrefs
          -->
          <xsl:template match="@xlink:href" mode="post">
            <xsl:attribute name="xlink:href" select="pf:relativize-uri(string(.), base-uri(collection()[2]/*))"/>
          </xsl:template>
          
          <!--
              Make it possible to reference non-existing images in tests
          -->
          <xsl:function name="pf:image-dimensions" as="xs:integer*">
            <xsl:param name="src" as="xs:anyURI"/>
            <xsl:sequence select="(1000,1000)"/>
          </xsl:function>
          
          <!--
              Suppress warnings about nested styles
          -->
          <xsl:function name="style:is-automatic-style" as="xs:boolean">
            <xsl:param name="style-name" as="xs:string"/>
            <xsl:param name="family" as="xs:string"/>
            <xsl:sequence select="true()"/>
          </xsl:function>
          
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
    
</p:pipeline>
