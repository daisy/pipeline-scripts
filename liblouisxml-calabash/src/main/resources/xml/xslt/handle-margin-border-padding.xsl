<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    xmlns:my="http://github.com/bertfrees"
    exclude-result-prefixes="xs brl lblxml my"
    version="2.0">

    <!-- Make margin-left and margin-right absolute -->
    <!-- Turn borders into lblxml:border and lblxml:side-border -->
    <!-- Turn padding into margin -->

    <xsl:param name="page-width" as="xs:integer" select="40"/>

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/style-functions.xsl" />
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()">
            <xsl:with-param name="left" select="0"/>
            <xsl:with-param name="right" select="0"/>
            <xsl:with-param name="width" select="$page-width"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="@*|text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:param name="left"/>
        <xsl:param name="right"/>
        <xsl:param name="width"/>
        <xsl:variable name="style" as="xs:string" select="string(@brl:style)"/>
        <xsl:variable name="display" as="xs:string" select="brl:get-property-or-default($style, 'display')"/>
        <xsl:choose>
            <xsl:when test="($display='block' or $display='list-item' or $display='toc') and
                (contains($style, 'margin') or contains($style, 'border') or contains($style, 'padding'))">
                <xsl:variable name="margin-left" select="number(brl:get-property-or-default($style, 'margin-left'))"/>
                <xsl:variable name="margin-right" select="number(brl:get-property-or-default($style, 'margin-right'))"/>
                <xsl:variable name="margin-top" select="number(brl:get-property-or-default($style, 'margin-top'))"/>
                <xsl:variable name="margin-bottom" select="number(brl:get-property-or-default($style, 'margin-bottom'))"/>
                <xsl:variable name="padding-left" select="number(brl:get-property-or-default($style, 'padding-left'))"/>
                <xsl:variable name="padding-right" select="number(brl:get-property-or-default($style, 'padding-right'))"/>
                <xsl:variable name="padding-top" select="number(brl:get-property-or-default($style, 'padding-top'))"/>
                <xsl:variable name="padding-bottom" select="number(brl:get-property-or-default($style, 'padding-bottom'))"/>
                <xsl:variable name="border-left" select="brl:get-property-or-default($style, 'border-left')"/>
                <xsl:variable name="border-right" select="brl:get-property-or-default($style, 'border-right')"/>
                <xsl:variable name="border-top" select="brl:get-property-or-default($style, 'border-top')"/>
                <xsl:variable name="border-bottom" select="brl:get-property-or-default($style, 'border-bottom')"/>
                <xsl:variable name="other-style" as="xs:string" select="brl:remove-style-values($style,
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
                            <xsl:with-param name="other-style" select="$other-style"/>
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
                            <xsl:with-param name="other-style" select="$other-style"/>
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
        <xsl:param name="other-style" as="xs:string"/>
        <div>
            <xsl:attribute name="brl:style" select="concat(
                'display: block;',
                'margin-top:', my:string(if ($border-left='none' and $border-right='none' and $border-top='none') 
                                         then $margin-top + $padding-top else $margin-top), ';',
                'margin-bottom:', my:string(if ($border-left='none' and $border-right='none' and $border-bottom='none')
                                        then $margin-bottom + $padding-bottom else $margin-bottom), ';',
                'page-break-before:', brl:get-property-or-default($other-style, 'page-break-before'), ';',
                'page-break-after:', brl:get-property-or-default($other-style, 'page-break-after'), ';',
                'page-break-inside:', brl:get-property-or-default($other-style, 'page-break-inside'), ';',
                'orphans:', brl:get-property-or-default($other-style, 'orphans'))"/>
            <xsl:if test="$border-top!='none'">
                <xsl:sequence select="my:create-border($border-top, $left + $margin-left,
                    $width - $margin-left - $margin-right)"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$border-left!='none' or $border-right!='none'">
                    <xsl:call-template name="handle-side-border">
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
                        <xsl:with-param name="other-style" select="brl:remove-style-values($other-style,
                            ('page-break-after', 'page-break-before', 'page-break-inside', 'orphans'))"/>
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
                        <xsl:with-param name="other-style" select="brl:remove-style-values($other-style,
                            ('page-break-after', 'page-break-before', 'page-break-inside', 'orphans'))"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$border-bottom!='none'">
                <xsl:sequence select="my:create-border($border-bottom, $left + $margin-left,
                    $width - $margin-left - $margin-right)"/>
            </xsl:if>
        </div>
    </xsl:template>
    
    <xsl:template name="handle-side-border">
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
        <xsl:param name="other-style" as="xs:string"/>
        <xsl:variable name="new-width"
            select="$width - max((-$left, $margin-left)) - max((-$right, $margin-right)) - 
            (if ($border-left='none') then 0 else 1) - (if ($border-right='none') then 0 else 1)"/>
        <lblxml:side-border>
            <xsl:attribute name="width" select="$new-width"/>
            <xsl:attribute name="margin-left" select="my:string(max((0, $left + $margin-left)))"/>
            <xsl:attribute name="margin-right" select="my:string(max((0, $right + $margin-right)))"/>
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
                <xsl:with-param name="other-style" select="brl:override-style($other-style, concat(
                    'text-align:', brl:get-property-or-inherited(., 'text-align'), ';',
                    'text-indent:', brl:get-property-or-inherited(., 'text-indent')
                    ))"/>
            </xsl:call-template>
        </lblxml:side-border>
    </xsl:template>
    
    <xsl:template name="handle-margin">
        <xsl:param name="left"/>
        <xsl:param name="right"/>
        <xsl:param name="width"/>
        <xsl:param name="margin-left" select="0"/>
        <xsl:param name="margin-right" select="0"/>
        <xsl:param name="margin-top" select="0"/>
        <xsl:param name="margin-bottom" select="0"/>
        <xsl:param name="other-style" as="xs:string"/>
        <xsl:variable name="left-absolute" select="max((0, $left + $margin-left))"/>
        <xsl:variable name="right-absolute" select="max((0, $right + $margin-right))"/>
        <xsl:variable name="margin-style" as="xs:string*">
            <xsl:if test="$margin-left != 0">
                <xsl:sequence select="concat('margin-left-absolute:', my:string($left-absolute))"/>
            </xsl:if>
            <xsl:if test="$margin-right != 0">
                <xsl:sequence select="concat('margin-right-absolute:', my:string($right-absolute))"/>
            </xsl:if>
            <xsl:if test="$margin-top != 0">
                <xsl:sequence select="concat('margin-top:', my:string($margin-top))"/>
            </xsl:if>
            <xsl:if test="$margin-bottom != 0">
                <xsl:sequence select="concat('margin-bottom:', my:string($margin-bottom))"/>
            </xsl:if>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="brl:style"
                select="brl:override-style($other-style, string-join($margin-style,';'))"/>
            <xsl:apply-templates select="node()">
                <xsl:with-param name="left" select="$left-absolute"/>
                <xsl:with-param name="right" select="$right-absolute"/>
                <xsl:with-param name="width" select="$width"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="my:create-border" as="element()">
        <xsl:param name="style" as="xs:string"/>
        <xsl:param name="left"/>
        <xsl:param name="width"/>
        <xsl:choose>
            <xsl:when test="$width = $page-width">
                <lblxml:border>
                    <xsl:attribute name="style" select="$style"/>
                </lblxml:border>
            </xsl:when>
            <xsl:otherwise>
                <lblxml:preformatted>
                    <lblxml:line>
                        <xsl:value-of select="concat(
                            my:repeat-char('&#xA0;', $left), 
                            my:repeat-char($style, $width))"/>
                    </lblxml:line>
                </lblxml:preformatted>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="my:string" as="xs:string">
        <xsl:param name="number" as="xs:double"/>
        <xsl:sequence select="format-number($number, '0')"/>
    </xsl:function>
    
    <xsl:function name="my:repeat-char" as="xs:string?">
        <xsl:param name="char" as="xs:string"/>
        <xsl:param name="times" />
        <xsl:if test="$times &gt; 0">
            <xsl:value-of select="concat($char, my:repeat-char($char, $times - 1))"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>