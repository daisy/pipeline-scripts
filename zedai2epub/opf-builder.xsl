<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.idpf.org/2007/opf"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:opf="http://www.idpf.org/2007/opf" 
  xmlns:f="http://www.daisy.org/ns/functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:z="http://www.daisy.org/ns/z3986/authoring/" exclude-result-prefixes="f xs z" version="2.0">

  <xsl:output method="xml" indent="yes"/>
  
  
  <xsl:template match="/">
    <xsl:variable name="chunks" select="//*[@chunk]"/>
    <package version="2.0" unique-identifier="uid">
      <metadata>
        <!--Required Metadata-->
        <dc:identifier id="uid"><xsl:value-of select="z:document/z:head/z:meta[@property='dcterms:identifier']/@content"/></dc:identifier>
        <dc:language><xsl:value-of select="(/z:document/@xml:lang,/z:document/z:body/@xml:lang,'en')[1]"/></dc:language>
        <dc:title><xsl:value-of select="f:doc-title(/)"/></dc:title>
        <!--Optional Metadata-->
        <dc:creator><xsl:value-of select="f:doc-author(/)"/></dc:creator>
        <!--<dc:publisher>TBD</dc:publisher>--><!--TODO get publisher-->
        <!--<dc:date opf:event="publication">TBD</dc:date>--><!--TODO get publication date-->
        <!--<dc:date opf:event="creation">TBD</dc:date>--><!--TODO get creation date-->
        <meta name="generator" content="DAISY Pipeline 2" />
      </metadata>
      <manifest>
        <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml" />
        <xsl:for-each select="$chunks">
          <itemref id="{generate-id()}" href="{@chunk}" media-type="application/xhtml+xml"/>
        </xsl:for-each>
      </manifest>
      <spine toc="ncx">
        <xsl:for-each select="$chunks">
          <itemref idref="{generate-id()}"/>
        </xsl:for-each>
      </spine>
      <!--<guide>
        <!-\-TODO create the OPF guide-\->
      </guide>-->
    </package>
  </xsl:template>

  <xsl:function name="f:doc-author" as="xs:string">
    <xsl:param name="doc" as="document-node()"/>
    <xsl:value-of select="normalize-space($doc//*[@property='dcterms:creator'][1])"/>
  </xsl:function>  
  <xsl:function name="f:doc-title" as="xs:string">
    <xsl:param name="doc" as="document-node()"/>
    <xsl:value-of select="normalize-space($doc//*[@property='dcterms:title'][1])"/>
  </xsl:function>
</xsl:stylesheet>
