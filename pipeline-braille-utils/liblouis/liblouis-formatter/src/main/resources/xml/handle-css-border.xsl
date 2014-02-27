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
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@css:display and matches(string(@style), 'border|padding')]">
        <xsl:variable name="display" as="xs:string" select="string(@css:display)"/>
        <xsl:variable name="margin-left"    as="xs:integer" select="xs:integer(number(css:get-value(., 'margin-left',    true(), true(), true())))"/>
        <xsl:variable name="margin-right"   as="xs:integer" select="xs:integer(number(css:get-value(., 'margin-right',   true(), true(), true())))"/>
        <xsl:variable name="margin-top"     as="xs:integer" select="xs:integer(number(css:get-value(., 'margin-top',     true(), true(), true())))"/>
        <xsl:variable name="margin-bottom"  as="xs:integer" select="xs:integer(number(css:get-value(., 'margin-bottom',  true(), true(), true())))"/>
        <xsl:variable name="padding-left"   as="xs:integer" select="xs:integer(number(css:get-value(., 'padding-left',   true(), true(), true())))"/>
        <xsl:variable name="padding-right"  as="xs:integer" select="xs:integer(number(css:get-value(., 'padding-right',  true(), true(), true())))"/>
        <xsl:variable name="padding-top"    as="xs:integer" select="xs:integer(number(css:get-value(., 'padding-top',    true(), true(), true())))"/>
        <xsl:variable name="padding-bottom" as="xs:integer" select="xs:integer(number(css:get-value(., 'padding-bottom', true(), true(), true())))"/>
        <xsl:variable name="border-left"    as="xs:string" select="css:get-value(., 'border-left',   true(), true(), true())"/>
        <xsl:variable name="border-right"   as="xs:string" select="css:get-value(., 'border-right',  true(), true(), true())"/>
        <xsl:variable name="border-top"     as="xs:string" select="css:get-value(., 'border-top',    true(), true(), true())"/>
        <xsl:variable name="border-bottom"  as="xs:string" select="css:get-value(., 'border-bottom', true(), true(), true())"/>
        <xsl:variable name="style" as="xs:string?" select="css:remove-from-declarations(string(@style),
                    ('margin-left', 'margin-right', 'margin-top', 'margin-bottom',
                     'padding-left', 'padding-right', 'padding-top', 'padding-bottom',
                     'border-left', 'border-right', 'border-top', 'border-bottom'))"/>
        <xsl:choose>
            <xsl:when test="$border-left!='none' or $border-right!='none' or $border-top!='none' or $border-bottom!='none'">
                <louis:div>
                    <xsl:attribute name="css:display" select="'block'"/>
                    <xsl:variable name="style" as="xs:string?"
                                  select="css:remove-from-declarations(($style,'')[1], $css:paged-media-properties)"/>
                    <xsl:choose>
                        <xsl:when test="$border-left!='none' or $border-right!='none'">
                            <xsl:sequence select="pxi:maybe-style-attr((
                                                    css:concretize-properties(., $css:paged-media-properties),
                                                    pxi:margin-style($margin-left,$margin-right,$margin-top,$margin-bottom)))"/>
                            <louis:box>
                                <xsl:attribute name="border-top" select="$border-top"/>
                                <xsl:attribute name="border-bottom" select="$border-bottom"/>
                                <xsl:attribute name="border-left" select="$border-left"/>
                                <xsl:attribute name="border-right" select="$border-right"/>
                                <xsl:copy>
                                    <xsl:apply-templates select="@*[not(name()='style')]"/>
                                    <xsl:sequence select="pxi:maybe-style-attr(($style,
                                                            pxi:margin-style($padding-left,$padding-right,$padding-top,$padding-bottom)))"/>
                                    <xsl:apply-templates select="node()"/>
                                </xsl:copy>
                            </louis:box>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="pxi:maybe-style-attr((
                                                    css:concretize-properties(., $css:paged-media-properties),
                                                    pxi:margin-style($margin-left,
                                                                     $margin-right,
                                                                     $margin-top + (if ($border-top='none') then $padding-top else 0),
                                                                     $margin-bottom + (if ($border-bottom='none') then $padding-bottom else 0))))"/>
                            <xsl:if test="$border-top!='none'">
                                <css:block>
                                    <louis:border pattern="{$border-top}"/>
                                </css:block>
                            </xsl:if>
                            <xsl:copy>
                                <xsl:apply-templates select="@*[not(name()='style')]"/>
                                <xsl:sequence select="pxi:maybe-style-attr(($style,
                                                        pxi:margin-style($padding-left,
                                                                         $padding-right,
                                                                         if ($border-top='none') then 0 else $padding-top,
                                                                         if ($border-bottom='none') then 0 else $padding-bottom)))"/>
                                <xsl:apply-templates select="node()"/>
                            </xsl:copy>
                            <xsl:if test="$border-bottom!='none'">
                                <css:block>
                                    <louis:border pattern="{$border-bottom}"/>
                                </css:block>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </louis:div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*[not(name()='style')]"/>
                    <xsl:sequence select="pxi:maybe-style-attr(($style,
                                            pxi:margin-style($margin-left + $padding-left,
                                                             $margin-right + $padding-right,
                                                             $margin-top + $padding-top,
                                                             $margin-bottom + $padding-bottom)))"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="pxi:margin-style" as="xs:string?">
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
        <xsl:if test="exists($margin-style)">
            <xsl:sequence select="string-join($margin-style, '; ')"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="pxi:maybe-style-attr" as="attribute()?">
        <xsl:param name="declarations" as="xs:string*"/>
        <xsl:if test="exists($declarations)">
            <xsl:attribute name="style" select="string-join($declarations, '; ')"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>
