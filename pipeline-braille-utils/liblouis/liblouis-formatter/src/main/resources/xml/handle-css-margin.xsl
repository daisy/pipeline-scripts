<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!--
      * Combine margin-left and margin-right with left and right
      * Add @width attribute on louis:box
      * Insert line of dots in louis:border
      * Lower-bound text-indent
    -->
    <xsl:param name="louis:page-width" as="xs:string"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:template match="@*|text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="louis:page-layout">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="louis:border">
        <xsl:param name="current-width" as="xs:integer" select="xs:integer(number($louis:page-width))" tunnel="yes"/>
        <xsl:copy>
            <xsl:value-of select="pxi:repeat-char(@pattern, $current-width)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="louis:box">
        <xsl:param name="current-width" as="xs:integer" select="xs:integer(number($louis:page-width))" tunnel="yes"/>
        <xsl:copy>
            <xsl:variable name="new-width" as="xs:integer"
                          select="$current-width
                                  - (if (@border-left='none') then 0 else 1)
                                  - (if (@border-right='none') then 0 else 1)"/>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="width" select="$new-width"/>
            <xsl:apply-templates select="node()">
                <xsl:with-param name="real-left" select="0" tunnel="yes"/>
                <xsl:with-param name="real-right" select="0" tunnel="yes"/>
                <xsl:with-param name="current-left" select="0" tunnel="yes"/>
                <xsl:with-param name="current-right" select="0" tunnel="yes"/>
                <xsl:with-param name="current-text-indent" select="0" tunnel="yes"/>
                <xsl:with-param name="current-width" select="$new-width" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[matches(string(@style), 'margin-left|margin-right|left|right|text-indent')]">
        <xsl:param name="real-left" as="xs:integer" select="0" tunnel="yes"/>
        <xsl:param name="real-right" as="xs:integer" select="0" tunnel="yes"/>
        <xsl:param name="current-left" as="xs:integer" select="0" tunnel="yes"/>
        <xsl:param name="current-right" as="xs:integer" select="0" tunnel="yes"/>
        <xsl:param name="current-text-indent" as="xs:integer" select="0" tunnel="yes"/>
        <xsl:param name="current-width" as="xs:integer" select="xs:integer(number($louis:page-width))" tunnel="yes"/>
        <xsl:variable name="margin-left" as="xs:integer" select="xs:integer(number(css:get-value(., 'margin-left', true(), true(), true())))"/>
        <xsl:variable name="margin-right" as="xs:integer" select="xs:integer(number(css:get-value(., 'margin-right', true(), true(), true())))"/>
        <xsl:variable name="text-indent" as="xs:integer" select="xs:integer(number(css:get-value(., 'text-indent', true(), true(), true())))"/>
        <xsl:variable name="left"  as="xs:string?" select="css:get-value(., 'left', false(), false(), true())"/>
        <xsl:variable name="right" as="xs:string?" select="css:get-value(., 'right', false(), false(), true())"/>
        <xsl:variable name="new-left" as="xs:integer"
                      select="(if ($left and not($left='inherit')) then xs:integer(number($left)) else $real-left) + $margin-left"/>
        <xsl:variable name="new-right" as="xs:integer"
                      select="(if ($right and not($right='inherit')) then xs:integer(number($right)) else $real-right) + $margin-right"/>
        <xsl:variable name="corrected-left" as="xs:integer" select="max((0, $new-left))"/>
        <xsl:variable name="corrected-right" as="xs:integer" select="max((0, $new-right))"/>
        <xsl:variable name="corrected-text-indent" as="xs:integer" select="max((- $corrected-left, $text-indent))"/>
        <xsl:copy>
          <xsl:apply-templates select="@*[not(name()='style')]"/>
          <xsl:sequence select="pxi:maybe-style-attr((
                                  css:remove-from-declarations(string(@style),
                                    ('left', 'right', 'margin-left', 'margin-right','text-indent')),
                                  if ($corrected-left != $current-left)
                                    then concat('left:', format-number($corrected-left, '0.0'))
                                    else (),
                                  if ($corrected-right != $current-right)
                                    then concat('right:', format-number($corrected-right, '0.0'))
                                    else (),
                                  if ($corrected-text-indent != $current-text-indent)
                                    then concat('text-indent:', format-number($corrected-text-indent, '0.0'))
                                    else ()))"/>
          <xsl:apply-templates select="node()">
            <xsl:with-param name="real-left" select="$new-left" tunnel="yes"/>
            <xsl:with-param name="real-right" select="$new-right" tunnel="yes"/>
            <xsl:with-param name="current-left" select="$corrected-left" tunnel="yes"/>
            <xsl:with-param name="current-right" select="$corrected-right" tunnel="yes"/>
            <xsl:with-param name="current-text-indent" select="$corrected-text-indent" tunnel="yes"/>
            <xsl:with-param name="current-width" tunnel="yes"
                            select="$current-width + $current-left + $current-right - $corrected-left - $corrected-right"/>
          </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="pxi:repeat-char" as="xs:string">
        <xsl:param name="char" as="xs:string"/>
        <xsl:param name="times" as="xs:integer"/>
        <xsl:sequence select="if ($times &gt; 0) then concat($char, pxi:repeat-char($char, $times - 1)) else ''"/>
    </xsl:function>
    
    <xsl:function name="pxi:maybe-style-attr" as="attribute()?">
        <xsl:param name="declarations" as="xs:string*"/>
        <xsl:if test="exists($declarations)">
            <xsl:attribute name="style" select="string-join($declarations, '; ')"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>
