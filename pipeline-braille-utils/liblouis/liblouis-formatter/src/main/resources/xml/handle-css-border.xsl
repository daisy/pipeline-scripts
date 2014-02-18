<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!--
      * Turn borders into louis:border and louis:box
      * Turn padding into margin
    -->
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:template match="@*|text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="louis:page-layout">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:variable name="display" as="xs:string?" select="css:get-value(., 'display', true(), true(), true())"/>
        <xsl:choose>
            <xsl:when test="$display and $display=('block','list-item','toc-item') and matches(string(@style), 'border|padding')">
                <xsl:variable name="margin-left"    as="xs:integer" select="xs:integer(number(pxi:get-value-if-applies-or-default(., 'margin-left',    $display)))"/>
                <xsl:variable name="margin-right"   as="xs:integer" select="xs:integer(number(pxi:get-value-if-applies-or-default(., 'margin-right',   $display)))"/>
                <xsl:variable name="margin-top"     as="xs:integer" select="xs:integer(number(pxi:get-value-if-applies-or-default(., 'margin-top',     $display)))"/>
                <xsl:variable name="margin-bottom"  as="xs:integer" select="xs:integer(number(pxi:get-value-if-applies-or-default(., 'margin-bottom',  $display)))"/>
                <xsl:variable name="padding-left"   as="xs:integer" select="xs:integer(number(pxi:get-value-if-applies-or-default(., 'padding-left',   $display)))"/>
                <xsl:variable name="padding-right"  as="xs:integer" select="xs:integer(number(pxi:get-value-if-applies-or-default(., 'padding-right',  $display)))"/>
                <xsl:variable name="padding-top"    as="xs:integer" select="xs:integer(number(pxi:get-value-if-applies-or-default(., 'padding-top',    $display)))"/>
                <xsl:variable name="padding-bottom" as="xs:integer" select="xs:integer(number(pxi:get-value-if-applies-or-default(., 'padding-bottom', $display)))"/>
                <xsl:variable name="border-left"    as="xs:string" select="pxi:get-value-if-applies-or-default(., 'border-left',  $display)"/>
                <xsl:variable name="border-right"   as="xs:string" select="pxi:get-value-if-applies-or-default(., 'border-right', $display)"/>
                <xsl:variable name="border-top"     as="xs:string" select="pxi:get-value-if-applies-or-default(., 'border-top',   $display)"/>
                <xsl:variable name="border-bottom"  as="xs:string" select="pxi:get-value-if-applies-or-default(., 'border-bottom',$display)"/>
                <xsl:variable name="style" select="css:remove-from-declarations(string(@style),
                    ('margin-left', 'margin-right', 'margin-top', 'margin-bottom',
                     'padding-left', 'padding-right', 'padding-top', 'padding-bottom',
                     'border-left', 'border-right', 'border-top', 'border-bottom'))"/>
                <xsl:choose>
                    <xsl:when test="$border-left!='none' or $border-right!='none' or $border-top!='none' or $border-bottom!='none'">
                        <louis:div>
                            <xsl:variable name="style" select="css:remove-from-declarations($style, $css:paged-media-properties)"/>
                            <xsl:choose>
                                <xsl:when test="$border-left!='none' or $border-right!='none'">
                                    <xsl:attribute name="style"
                                                   select="pxi:join-declarations((
                                                             'display:block',
                                                             css:concretize-properties(., $css:paged-media-properties),
                                                             pxi:margin-style($margin-left,$margin-right,$margin-top,$margin-bottom)))"/>
                                    <louis:box>
                                        <xsl:attribute name="border-top" select="$border-top"/>
                                        <xsl:attribute name="border-bottom" select="$border-bottom"/>
                                        <xsl:attribute name="border-left" select="$border-left"/>
                                        <xsl:attribute name="border-right" select="$border-right"/>
                                        <xsl:copy>
                                            <xsl:apply-templates select="@*"/>
                                            <xsl:attribute name="style"
                                                           select="pxi:join-declarations(($style,
                                                                     pxi:margin-style($padding-left,$padding-right,$padding-top,$padding-bottom)))"/>
                                            <xsl:apply-templates select="node()"/>
                                        </xsl:copy>
                                    </louis:box>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="style"
                                           select="pxi:join-declarations((
                                                     'display:block',
                                                     css:concretize-properties(., $css:paged-media-properties),
                                                     pxi:margin-style($margin-left,
                                                                      $margin-right,
                                                                      $margin-top + (if ($border-top='none') then $padding-top else 0),
                                                                      $margin-bottom + (if ($border-bottom='none') then $padding-bottom else 0))))"/>
                                    <xsl:if test="$border-top!='none'">
                                        <louis:border style="{$border-top}"/>
                                    </xsl:if>
                                    <xsl:copy>
                                        <xsl:apply-templates select="@*"/>
                                        <xsl:attribute name="style"
                                                       select="pxi:join-declarations(($style,
                                                                 pxi:margin-style($padding-left,
                                                                                  $padding-right,
                                                                                  if ($border-top='none') then 0 else $padding-top,
                                                                                  if ($border-bottom='none') then 0 else $padding-bottom)))"/>
                                        <xsl:apply-templates select="node()"/>
                                    </xsl:copy>
                                    <xsl:if test="$border-bottom!='none'">
                                        <louis:border style="{$border-bottom}"/>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </louis:div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:attribute name="style"
                                           select="pxi:join-declarations(($style,
                                                     pxi:margin-style($margin-left + $padding-left,
                                                                      $margin-right + $padding-right,
                                                                      $margin-top + $padding-top,
                                                                      $margin-bottom + $padding-bottom)))"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="pxi:get-value-if-applies-or-default" as="xs:string">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="display" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="css:applies-to($property, $display)">
                <xsl:sequence select="css:get-value($element, $property, true(), true(), true())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="css:get-default-value($property)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="pxi:join-declarations" as="xs:string">
        <xsl:param name="declarations" as="xs:string*"/>
        <xsl:sequence select="string-join($declarations, '; ')"/>
    </xsl:function>
    
    <xsl:function name="pxi:margin-style" as="xs:string">
        <xsl:param name="margin-left" as="xs:integer"/>
        <xsl:param name="margin-right" as="xs:integer"/>
        <xsl:param name="margin-top" as="xs:integer"/>
        <xsl:param name="margin-bottom" as="xs:integer"/>
        <xsl:variable name="margin-style" as="xs:string*">
            <xsl:if test="$margin-left != 0">
                <xsl:sequence select="concat('margin-left:', format-number($margin-left, '0.0'))"/>
            </xsl:if>
            <xsl:if test="$margin-right != 0">
                <xsl:sequence select="concat('margin-right:', format-number($margin-right, '0.0'))"/>
            </xsl:if>
            <xsl:if test="$margin-top != 0">
                <xsl:sequence select="concat('margin-top:', format-number($margin-top, '0.0'))"/>
            </xsl:if>
            <xsl:if test="$margin-bottom != 0">
                <xsl:sequence select="concat('margin-bottom:', format-number($margin-bottom, '0.0'))"/>
            </xsl:if>
        </xsl:variable>
        <xsl:sequence select="string-join($margin-style, ';')"/>
    </xsl:function>
    
</xsl:stylesheet>
