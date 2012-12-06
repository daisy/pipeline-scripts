<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
    exclude-result-prefixes="xs louis css z"
    version="2.0">
  
  <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl" />
  
  <!--
    @parameter node: the input node (element or text)
    @returns: the typeform string:
      A string with the same length as the string-value of the input node, 
      where each character indicates the typeform (italic, bold, etc.) of the
      corresponding character in the string-value. The typeform values are:
      - 0 = plain text
      - 1 = italic (font-style: italic/oblique)
      - 2 = bold (font-weight: bold)
      - 4 = underline (text-decoration: underline)
      These values can be added for multiple emphasis. Whitespace is preserved.
    @see http://liblouis.googlecode.com/svn/documentation/liblouis.html#lou_translateString
  -->
  <xsl:function name="louis:get-typeform" as="xs:string">
    <xsl:param name="node" as="node()"/>
    <xsl:choose>
      <xsl:when test="$node/self::*">
        <xsl:sequence select="string-join(for $child in $node/child::node() return louis:get-typeform($child), '')"/>
      </xsl:when>
      <xsl:when test="$node/self::text()">
        <xsl:variable name="typeform" as="xs:integer*">
          <xsl:if test="css:get-property-value($node/parent::*, 'font-style', true(), true(), false())=('italic','oblique')">
            <xsl:sequence select="1"/>
          </xsl:if>
          <xsl:if test="css:get-property-value($node/parent::*, 'font-weight', true(), true(), false())='bold'">
            <xsl:sequence select="2"/>
          </xsl:if>
          <xsl:if test="css:get-property-value($node/parent::*, 'text-decoration', true(), true(), false())='underline'">
            <xsl:sequence select="4"/>
          </xsl:if>
        </xsl:variable>
        <xsl:sequence select="louis:repeat-char(codepoints-to-string(sum($typeform) + 48), string-length($node))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="louis:repeat-char" as="xs:string">
    <xsl:param name="char" as="xs:string"/>
    <xsl:param name="times" />
    <xsl:sequence select="string-join(for $i in 1 to $times return $char, '')"/>
  </xsl:function>
    
</xsl:stylesheet>
