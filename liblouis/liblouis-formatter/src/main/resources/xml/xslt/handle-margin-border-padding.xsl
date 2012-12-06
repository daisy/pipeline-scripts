<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-result-prefixes="xs louis css"
    version="2.0">

    <!--
      * Make margin-left and margin-right absolute
      * Turn borders into louis:border and louis:box
      * Turn padding into margin
    -->
    <xsl:param name="page-width" select="40"/>

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl" />
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()">
            <xsl:with-param name="left" select="0"/>
            <xsl:with-param name="right" select="0"/>
            <xsl:with-param name="width" select="number($page-width)"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="@*|text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:param name="left"/>
        <xsl:param name="right"/>
        <xsl:param name="width"/>
        <xsl:variable name="display" as="xs:string?"
            select="if (ancestor::louis:toc) then 'toc-item' else css:get-property-value(., 'display', true(), true(), true())"/>
        <xsl:choose>
            <xsl:when test="$display and $display=('block','list-item','toc','toc-item') and matches(string(@style), 'margin|border|padding')">
                <xsl:variable name="margin-left" select="number(css:get-property-value(., 'margin-left', true(), true(), true()))"/>
                <xsl:variable name="margin-right" select="number(css:get-property-value(., 'margin-right', true(), true(), true()))"/>
                <xsl:variable name="margin-top" select="number(css:get-property-value(., 'margin-top', true(), true(), true()))"/>
                <xsl:variable name="margin-bottom" select="number(css:get-property-value(., 'margin-bottom', true(), true(), true()))"/>
                <xsl:variable name="padding-left" select="number(css:get-property-value(., 'padding-left', true(), true(), true()))"/>
                <xsl:variable name="padding-right" select="number(css:get-property-value(., 'padding-right', true(), true(), true()))"/>
                <xsl:variable name="padding-top" select="number(css:get-property-value(., 'padding-top', true(), true(), true()))"/>
                <xsl:variable name="padding-bottom" select="number(css:get-property-value(., 'padding-bottom', true(), true(), true()))"/>
                <xsl:variable name="border-left" select="css:get-property-value(., 'border-left', true(), true(), true())"/>
                <xsl:variable name="border-right" select="css:get-property-value(., 'border-right', true(), true(), true())"/>
                <xsl:variable name="border-top" select="css:get-property-value(., 'border-top', true(), true(), true())"/>
                <xsl:variable name="border-bottom" select="css:get-property-value(., 'border-bottom', true(), true(), true())"/>
                <xsl:variable name="style" select="css:remove-properties(string(@style),
                    ('margin-left', 'margin-right', 'margin-top', 'margin-bottom',
                    'padding-left', 'padding-right', 'padding-top', 'padding-bottom',
                    'border-left', 'border-right', 'border-top', 'border-bottom'))"/>
                <xsl:choose>
                    <xsl:when test="$border-left!='none' or $border-right!='none' or $border-top!='none' or $border-bottom!='none'">
                        <xsl:call-template name="handle-border">
                            <xsl:with-param name="left" select="$left"/>
                            <xsl:with-param name="right" select="$right"/>
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
                            <xsl:with-param name="left" select="$left"/>
                            <xsl:with-param name="right" select="$right"/>
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
                        <xsl:with-param name="left" select="$left"/>
                        <xsl:with-param name="right" select="$right"/>
                        <xsl:with-param name="width" select="$width"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="louis:toc">
        <xsl:param name="left"/>
        <xsl:param name="right"/>
        <xsl:param name="width"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="width" select="louis:to-string($width)"/>
            <xsl:attribute name="margin-left" select="louis:to-string($left)"/>
            <xsl:attribute name="margin-right" select="louis:to-string($right)"/>
            <xsl:apply-templates select="node()">
                <xsl:with-param name="left" select="$left + $right + number($page-width) - $width"/>
                <xsl:with-param name="right" select="0"/>
                <xsl:with-param name="width" select="number($page-width)"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="handle-border">
        <xsl:param name="left"/>
        <xsl:param name="right"/>
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
        <xsl:variable name="page-break-before"
            select="css:get-property-value(., 'page-break-before', true(), true(), false())"/>
        <xsl:variable name="page-break-after"
            select="css:get-property-value(., 'page-break-after', true(), true(), false())"/>
        <xsl:variable name="page-break-inside"
            select="css:get-property-value(., 'page-break-inside', true(), true(), false())"/>
        <xsl:variable name="orphans"
            select="css:get-property-value(., 'orphans', true(), true(), false())"/>
        <louis:div>
            <xsl:attribute name="style" select="concat(
                'display: block;',
                'margin-top:', louis:to-string(if ($border-left='none' and $border-right='none' and $border-top='none')
                                               then $margin-top + $padding-top else $margin-top), ';',
                'margin-bottom:', louis:to-string(if ($border-left='none' and $border-right='none' and $border-bottom='none')
                                                  then $margin-bottom + $padding-bottom else $margin-bottom), ';',
                'page-break-before:', $page-break-before, ';',
                'page-break-after:', $page-break-after, ';',
                'page-break-inside:', $page-break-inside, ';',
                'orphans:', $orphans)"/>
            <xsl:variable name="child-style"
                select="css:remove-properties($style, ('page-break-after', 'page-break-before', 'page-break-inside', 'orphans'))"/>
            <xsl:if test="$border-top!='none'">
                <xsl:sequence select="louis:create-border($border-top, $left + $margin-left, $width - $left - $right - $margin-left - $margin-right)"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$border-left!='none' or $border-right!='none'">
                    <xsl:call-template name="handle-vertical-border">
                        <xsl:with-param name="left" select="$left"/>
                        <xsl:with-param name="right" select="$right"/>
                        <xsl:with-param name="width" select="$width"/>
                        <xsl:with-param name="margin-left" select="$margin-left"/>
                        <xsl:with-param name="margin-right" select="$margin-right"/>
                        <xsl:with-param name="padding-left" select="$padding-left"/>
                        <xsl:with-param name="padding-right" select="$padding-right"/>
                        <xsl:with-param name="padding-top" select="$padding-top"/>
                        <xsl:with-param name="padding-bottom" select="$padding-bottom"/>
                        <xsl:with-param name="border-left" select="$border-left"/>
                        <xsl:with-param name="border-right" select="$border-right"/>
                        <xsl:with-param name="style" select="$child-style"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="handle-margin">
                        <xsl:with-param name="left" select="$left"/>
                        <xsl:with-param name="right" select="$right"/>
                        <xsl:with-param name="width" select="$width"/>
                        <xsl:with-param name="margin-left" select="$margin-left + $padding-left"/>
                        <xsl:with-param name="margin-right" select="$margin-right + $padding-right"/>
                        <xsl:with-param name="margin-top" select="if ($border-top='none') then 0 else $padding-top"/>
                        <xsl:with-param name="margin-bottom" select="if ($border-bottom='none') then 0 else $padding-bottom"/>
                        <xsl:with-param name="style" select="$child-style"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$border-bottom!='none'">
                <xsl:sequence select="louis:create-border($border-bottom, $left + $margin-left, $width - $left - $right - $margin-left - $margin-right)"/>
            </xsl:if>
        </louis:div>
    </xsl:template>
    
    <xsl:template name="handle-vertical-border">
        <xsl:param name="left"/>
        <xsl:param name="right"/>
        <xsl:param name="width"/>
        <xsl:param name="margin-left" select="0"/>
        <xsl:param name="margin-right" select="0"/>
        <xsl:param name="padding-left" select="0"/>
        <xsl:param name="padding-right" select="0"/>
        <xsl:param name="padding-top" select="0"/>
        <xsl:param name="padding-bottom" select="0"/>
        <xsl:param name="border-left" as="xs:string" select="'none'"/>
        <xsl:param name="border-right" as="xs:string" select="'none'"/>
        <xsl:param name="style" as="xs:string" select="string(@style)"/>
        <xsl:variable name="new-width"
            select="$width - max((-$left, $margin-left)) - max((-$right, $margin-right)) - 
            (if ($border-left='none') then 0 else 1) - (if ($border-right='none') then 0 else 1)"/>
        <xsl:if test="descendant::louis:toc">
            <xsl:message terminate="yes">No toc allowed inside an element with vertical borders</xsl:message>
        </xsl:if>
        <louis:box>
            <xsl:attribute name="width" select="louis:to-string($new-width)"/>
            <xsl:attribute name="margin-left" select="louis:to-string(max((0, $left + $margin-left)))"/>
            <xsl:attribute name="margin-right" select="louis:to-string(max((0, $right + $margin-right)))"/>
            <xsl:attribute name="border-left" select="$border-left"/>
            <xsl:attribute name="border-right" select="$border-right"/>
            <xsl:call-template name="handle-margin">
                <xsl:with-param name="left" select="0"/>
                <xsl:with-param name="right" select="0"/>
                <xsl:with-param name="width" select="$new-width"/>
                <xsl:with-param name="margin-left" select="$padding-left"/>
                <xsl:with-param name="margin-right" select="$padding-right"/>
                <xsl:with-param name="margin-top" select="$padding-top"/>
                <xsl:with-param name="margin-bottom" select="$padding-bottom"/>
                <xsl:with-param name="style" select="$style"/>
            </xsl:call-template>
        </louis:box>
    </xsl:template>
    
    <xsl:template name="handle-margin">
        <xsl:param name="left"/>
        <xsl:param name="right"/>
        <xsl:param name="width"/>
        <xsl:param name="margin-left" select="0"/>
        <xsl:param name="margin-right" select="0"/>
        <xsl:param name="margin-top" select="0"/>
        <xsl:param name="margin-bottom" select="0"/>
        <xsl:param name="style" as="xs:string" select="string(@style)"/>
        <xsl:variable name="left-absolute" select="max((0, $left + $margin-left))"/>
        <xsl:variable name="right-absolute" select="max((0, $right + $margin-right))"/>
        <xsl:variable name="margin-style" as="xs:string*">
            <xsl:if test="$margin-left != 0">
                <xsl:sequence select="concat('louis-abs-margin-left:', louis:to-string($left-absolute))"/>
            </xsl:if>
            <xsl:if test="$margin-right != 0">
                <xsl:sequence select="concat('louis-abs-margin-right:', louis:to-string($right-absolute))"/>
            </xsl:if>
            <xsl:if test="$margin-top != 0">
                <xsl:sequence select="concat('margin-top:', louis:to-string($margin-top))"/>
            </xsl:if>
            <xsl:if test="$margin-bottom != 0">
                <xsl:sequence select="concat('margin-bottom:', louis:to-string($margin-bottom))"/>
            </xsl:if>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="style"
                select="louis:append-properties($style, string-join($margin-style,';'))"/>
            <xsl:apply-templates select="node()">
                <xsl:with-param name="left" select="$left-absolute"/>
                <xsl:with-param name="right" select="$right-absolute"/>
                <xsl:with-param name="width" select="$width"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="louis:create-border" as="element()">
        <xsl:param name="style" as="xs:string"/>
        <xsl:param name="left"/>
        <xsl:param name="width"/>
        <louis:border>
            <xsl:value-of select="concat(
                louis:repeat-char('&#xA0;', $left), 
                louis:repeat-char($style, $width))"/>
        </louis:border>
    </xsl:function>
    
    <xsl:function name="louis:to-string" as="xs:string">
        <xsl:param name="number" as="xs:double"/>
        <xsl:sequence select="format-number($number, '0.0')"/>
    </xsl:function>
    
    <xsl:function name="louis:repeat-char" as="xs:string">
        <xsl:param name="char" as="xs:string"/>
        <xsl:param name="times" />
        <xsl:sequence select="if ($times &gt; 0) then concat($char, louis:repeat-char($char, $times - 1)) else ''"/>
    </xsl:function>
    
    <xsl:function name="louis:append-properties" as="xs:string">
        <xsl:param name="style" as="xs:string"/>
        <xsl:param name="append" as="xs:string"/>
        <xsl:variable name="remove" as="xs:string*"
            select="for $property in tokenize($append,';')
                      return normalize-space(substring-before($property,':'))"/>
        <xsl:sequence select="string-join((css:remove-properties($style, $remove), $append), ';')"/>
    </xsl:function>
    
</xsl:stylesheet>