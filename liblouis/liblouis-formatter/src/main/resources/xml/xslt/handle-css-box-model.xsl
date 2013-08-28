<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!--
      * Make margin-left and margin-right absolute
      * Turn borders into louis:border and louis:box
      * Turn padding into margin
    -->
    <xsl:param name="page-width"/>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()">
            <xsl:with-param name="left-absolute" select="0"/>
            <xsl:with-param name="right-absolute" select="0"/>
            <xsl:with-param name="width" select="number($page-width)"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="@*|text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="louis:page-layout">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:param name="left-absolute"/>
        <xsl:param name="right-absolute"/>
        <xsl:param name="width"/>
        <xsl:variable name="display" as="xs:string?" select="css:get-value(., 'display', true(), true(), true())"/>
        <xsl:choose>
            <xsl:when test="$display and $display=('block','list-item','toc-item') and matches(string(@style), 'margin|border|padding')">
                <xsl:variable name="margin-left"    select="number(pxi:or-default(pxi:get-value-if-applies(., 'margin-left',    $display), '0'))"/>
                <xsl:variable name="margin-right"   select="number(pxi:or-default(pxi:get-value-if-applies(., 'margin-right',   $display), '0'))"/>
                <xsl:variable name="margin-top"     select="number(pxi:or-default(pxi:get-value-if-applies(., 'margin-top',     $display), '0'))"/>
                <xsl:variable name="margin-bottom"  select="number(pxi:or-default(pxi:get-value-if-applies(., 'margin-bottom',  $display), '0'))"/>
                <xsl:variable name="padding-left"   select="number(pxi:or-default(pxi:get-value-if-applies(., 'padding-left',   $display), '0'))"/>
                <xsl:variable name="padding-right"  select="number(pxi:or-default(pxi:get-value-if-applies(., 'padding-right',  $display), '0'))"/>
                <xsl:variable name="padding-top"    select="number(pxi:or-default(pxi:get-value-if-applies(., 'padding-top',    $display), '0'))"/>
                <xsl:variable name="padding-bottom" select="number(pxi:or-default(pxi:get-value-if-applies(., 'padding-bottom', $display), '0'))"/>
                <xsl:variable name="border-left"    select="pxi:or-default(pxi:get-value-if-applies(., 'border-left',  $display), 'none')"/>
                <xsl:variable name="border-right"   select="pxi:or-default(pxi:get-value-if-applies(., 'border-right', $display), 'none')"/>
                <xsl:variable name="border-top"     select="pxi:or-default(pxi:get-value-if-applies(., 'border-top',   $display), 'none')"/>
                <xsl:variable name="border-bottom"  select="pxi:or-default(pxi:get-value-if-applies(., 'border-bottom',$display), 'none')"/>
                <xsl:variable name="style" select="css:remove-from-declarations(string(@style),
                    ('margin-left', 'margin-right', 'margin-top', 'margin-bottom',
                    'padding-left', 'padding-right', 'padding-top', 'padding-bottom',
                    'border-left', 'border-right', 'border-top', 'border-bottom'))"/>
                <xsl:choose>
                    <xsl:when test="$border-left!='none' or $border-right!='none' or $border-top!='none' or $border-bottom!='none'">
                        <xsl:call-template name="handle-border">
                            <xsl:with-param name="left-absolute" select="$left-absolute"/>
                            <xsl:with-param name="right-absolute" select="$right-absolute"/>
                            <xsl:with-param name="width" select="$width"/>
                            <xsl:with-param name="margin-left" select="$margin-left"/>
                            <xsl:with-param name="margin-right" select="$margin-right"/>
                            <xsl:with-param name="margin-top" select="$margin-top"/>
                            <xsl:with-param name="margin-bottom" select="$margin-bottom"/>
                            <xsl:with-param name="padding-left" select="$padding-left"/>
                            <xsl:with-param name="padding-right" select="$padding-right"/>
                            <xsl:with-param name="padding-top" select="$padding-top"/>
                            <xsl:with-param name="padding-bottom" select="$padding-bottom"/>
                            <xsl:with-param name="border-left" select="$border-left"/>
                            <xsl:with-param name="border-right" select="$border-right"/>
                            <xsl:with-param name="border-top" select="$border-top"/>
                            <xsl:with-param name="border-bottom" select="$border-bottom"/>
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="handle-margin">
                            <xsl:with-param name="left-absolute" select="$left-absolute"/>
                            <xsl:with-param name="right-absolute" select="$right-absolute"/>
                            <xsl:with-param name="width" select="$width"/>
                            <xsl:with-param name="margin-left" select="$margin-left + $padding-left"/>
                            <xsl:with-param name="margin-right" select="$margin-right + $padding-right"/>
                            <xsl:with-param name="margin-top" select="$margin-top + $padding-top"/>
                            <xsl:with-param name="margin-bottom" select="$margin-bottom + $padding-bottom"/>
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()">
                        <xsl:with-param name="left-absolute" select="$left-absolute"/>
                        <xsl:with-param name="right-absolute" select="$right-absolute"/>
                        <xsl:with-param name="width" select="$width"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="handle-border">
        <xsl:param name="left-absolute"/>
        <xsl:param name="right-absolute"/>
        <xsl:param name="width"/>
        <xsl:param name="margin-left" select="0"/>
        <xsl:param name="margin-right" select="0"/>
        <xsl:param name="margin-top" select="0"/>
        <xsl:param name="margin-bottom" select="0"/>
        <xsl:param name="padding-left" select="0"/>
        <xsl:param name="padding-right" select="0"/>
        <xsl:param name="padding-top" select="0"/>
        <xsl:param name="padding-bottom" select="0"/>
        <xsl:param name="border-left" as="xs:string" select="'none'"/>
        <xsl:param name="border-right" as="xs:string" select="'none'"/>
        <xsl:param name="border-top" as="xs:string" select="'none'"/>
        <xsl:param name="border-bottom" as="xs:string" select="'none'"/>
        <xsl:param name="style" as="xs:string" select="string(@style)"/>
        <xsl:variable name="new-left-absolute" select="max((0, $left-absolute + $margin-left))"/>
        <xsl:variable name="new-right-absolute" select="max((0, $right-absolute + $margin-right))"/>
        <xsl:variable name="margin-style" as="xs:string*">
            <xsl:if test="$margin-left != 0">
                <xsl:sequence select="concat('-louis-reset-margin-left:', pxi:to-string($new-left-absolute))"/>
            </xsl:if>
            <xsl:if test="$margin-right != 0">
                <xsl:sequence select="concat('-louis-reset-margin-right:', pxi:to-string($new-right-absolute))"/>
            </xsl:if>
            <xsl:sequence select="concat('margin-top:', pxi:to-string(
                if ($border-left='none' and $border-right='none' and $border-top='none')
                  then $margin-top + $padding-top
                  else $margin-top))"/>
            <xsl:sequence select="concat('margin-bottom:', pxi:to-string(
                if ($border-left='none' and $border-right='none' and $border-bottom='none')
                  then $margin-bottom + $padding-bottom
                  else $margin-bottom))"/>
        </xsl:variable>
        <louis:div>
            <xsl:attribute name="style"
                select="string-join(('display:block',
                                     css:concretize-properties(., $css:paged-media-properties),
                                     $margin-style), ';')"/>
            <xsl:variable name="child-style"
                select="css:remove-from-declarations($style, $css:paged-media-properties)"/>
            <xsl:choose>
                <xsl:when test="$border-left!='none' or $border-right!='none'">
                    <xsl:variable name="new-width"
                        select="$width - $new-left-absolute + $left-absolute - $new-right-absolute + $right-absolute
                                - (if ($border-left='none') then 0 else 1) - (if ($border-right='none') then 0 else 1)"/>
                    <louis:box>
                        <xsl:attribute name="width" select="pxi:to-string($new-width)"/>
                        <xsl:attribute name="border-top" select="$border-top"/>
                        <xsl:attribute name="border-bottom" select="$border-bottom"/>
                        <xsl:attribute name="border-left" select="$border-left"/>
                        <xsl:attribute name="border-right" select="$border-right"/>
                        <xsl:call-template name="handle-margin">
                            <xsl:with-param name="left-absolute" select="0"/>
                            <xsl:with-param name="right-absolute" select="0"/>
                            <xsl:with-param name="width" select="$new-width"/>
                            <xsl:with-param name="margin-left" select="$padding-left"/>
                            <xsl:with-param name="margin-right" select="$padding-right"/>
                            <xsl:with-param name="margin-top" select="$padding-top"/>
                            <xsl:with-param name="margin-bottom" select="$padding-bottom"/>
                            <xsl:with-param name="style" select="$child-style"/>
                        </xsl:call-template>
                    </louis:box>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$border-top!='none'">
                        <xsl:sequence select="pxi:create-border($border-top, $width - $left-absolute - $right-absolute - $margin-left - $margin-right)"/>
                    </xsl:if>
                    <xsl:call-template name="handle-margin">
                        <xsl:with-param name="left-absolute" select="$left-absolute"/>
                        <xsl:with-param name="right-absolute" select="$right-absolute"/>
                        <xsl:with-param name="width" select="$width"/>
                        <xsl:with-param name="margin-left" select="$margin-left + $padding-left"/>
                        <xsl:with-param name="margin-right" select="$margin-right + $padding-right"/>
                        <xsl:with-param name="margin-top" select="if ($border-top='none') then 0 else $padding-top"/>
                        <xsl:with-param name="margin-bottom" select="if ($border-bottom='none') then 0 else $padding-bottom"/>
                        <xsl:with-param name="style" select="$child-style"/>
                    </xsl:call-template>
                    <xsl:if test="$border-bottom!='none'">
                        <xsl:sequence select="pxi:create-border($border-bottom, $width - $left-absolute - $right-absolute - $margin-left - $margin-right)"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </louis:div>
    </xsl:template>
    
    <xsl:template name="handle-margin">
        <xsl:param name="width"/>
        <xsl:param name="left-absolute"/>
        <xsl:param name="right-absolute"/>
        <xsl:param name="margin-left" select="0"/>
        <xsl:param name="margin-right" select="0"/>
        <xsl:param name="margin-top" select="0"/>
        <xsl:param name="margin-bottom" select="0"/>
        <xsl:param name="style" as="xs:string" select="string(@style)"/>
        <xsl:variable name="new-left-absolute" select="max((0, $left-absolute + $margin-left))"/>
        <xsl:variable name="new-right-absolute" select="max((0, $right-absolute + $margin-right))"/>
        <xsl:variable name="margin-style" as="xs:string*">
            <xsl:if test="$margin-left != 0">
                <xsl:sequence select="concat('-louis-reset-margin-left:', pxi:to-string($new-left-absolute))"/>
            </xsl:if>
            <xsl:if test="$margin-right != 0">
                <xsl:sequence select="concat('-louis-reset-margin-right:', pxi:to-string($new-right-absolute))"/>
            </xsl:if>
            <xsl:if test="$margin-top != 0">
                <xsl:sequence select="concat('margin-top:', pxi:to-string($margin-top))"/>
            </xsl:if>
            <xsl:if test="$margin-bottom != 0">
                <xsl:sequence select="concat('margin-bottom:', pxi:to-string($margin-bottom))"/>
            </xsl:if>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="style" select="pxi:append-declarations($style, string-join($margin-style,';'))"/>
            <xsl:apply-templates select="node()">
                <xsl:with-param name="left-absolute" select="$new-left-absolute"/>
                <xsl:with-param name="right-absolute" select="$new-right-absolute"/>
                <xsl:with-param name="width" select="$width - $new-left-absolute + $left-absolute - $new-right-absolute + $right-absolute"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="pxi:create-border" as="element()">
        <xsl:param name="style" as="xs:string"/>
        <xsl:param name="width"/>
        <louis:border>
            <xsl:value-of select="pxi:repeat-char($style, $width)"/>
        </louis:border>
    </xsl:function>
    
    <xsl:function name="pxi:to-string" as="xs:string">
        <xsl:param name="number" as="xs:double"/>
        <xsl:sequence select="format-number($number, '0.0')"/>
    </xsl:function>
    
    <xsl:function name="pxi:or-default" as="xs:string">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:sequence select="if ($value) then $value else $default"/>
    </xsl:function>
    
    <xsl:function name="pxi:repeat-char" as="xs:string">
        <xsl:param name="char" as="xs:string"/>
        <xsl:param name="times" />
        <xsl:sequence select="if ($times &gt; 0) then concat($char, pxi:repeat-char($char, $times - 1)) else ''"/>
    </xsl:function>
    
    <xsl:function name="pxi:get-value-if-applies" as="xs:string?">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="display" as="xs:string"/>
        <xsl:if test="css:applies-to($property, $display)">
            <xsl:sequence select="css:get-value($element, $property, true(), true(), true())"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="pxi:append-declarations" as="xs:string">
        <xsl:param name="style" as="xs:string"/>
        <xsl:param name="append" as="xs:string"/>
        <xsl:variable name="remove" as="xs:string*"
            select="for $declaration in tokenize($append,';')
                      return normalize-space(substring-before($declaration,':'))"/>
        <xsl:sequence select="string-join((css:remove-from-declarations($style, $remove), $append), ';')"/>
    </xsl:function>
    
</xsl:stylesheet>
