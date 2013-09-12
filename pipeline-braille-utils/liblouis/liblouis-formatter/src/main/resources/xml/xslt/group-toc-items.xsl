<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/xslt/library.xsl"/>
    
    <xsl:variable name="page-width" select="number(pxi:get-page-layout-param(/*, 'louis:page-width'))"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@css:toc-item]">
        <xsl:element name="louis:toc-item">
            <xsl:apply-templates select="@style|@ref"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*[descendant::*[@css:toc-item]]">
        <xsl:variable name="this" as="element()" select="."/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*|text()[not(normalize-space()='')]"
                group-adjacent="boolean(
                    descendant-or-self::*[@css:toc-item]
                    and not(descendant-or-self::*[not(@css:toc-item) and @style]))
                    and self::*[normalize-space()='']">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <xsl:variable name="width" select="
                            (if ($this/ancestor::louis:box) then $this/ancestor::louis:box[1]/@width else $page-width)
                             - number(pxi:or-default(css:get-value(
                                $this, '-louis-reset-margin-right', true(), true(), false()), '0'))"/>
                        <xsl:for-each-group select="current-group()/descendant-or-self::*[@css:toc-item]"
                            group-adjacent="for $ref in (@ref) return base-uri(collection()/*[descendant::*[@xml:id=$ref]])">
                            <xsl:variable name="href" select="current-grouping-key()"/>
                            <xsl:for-each-group select="current-group()"
                                group-adjacent="for $ref in (@ref) return not(collection()//*[@xml:id=$ref]/ancestor::louis:box)">
                                <xsl:choose>
                                    <xsl:when test="current-grouping-key()">
                                        <xsl:element name="louis:div">
                                            <xsl:attribute name="style" select="'display:block;-louis-reset-margin-left:0'"/>
                                            <xsl:element name="louis:toc">
                                                <xsl:attribute name="href" select="$href"/>
                                                <xsl:attribute name="width" select="$width"/>
                                                <xsl:for-each select="current-group()">
                                                    <xsl:apply-templates select="."/>
                                                </xsl:for-each>
                                            </xsl:element>
                                        </xsl:element>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:for-each select="current-group()">
                                            <xsl:variable name="ref" select="@ref"/>
                                            <xsl:copy>
                                                <xsl:apply-templates select="@*[not(name()='style')]"/>
                                                <xsl:attribute name="style"
                                                               select="string-join((
                                                                         css:remove-from-declarations(string(@style), ('display')),
                                                                         'display: block'), ';')"/>
                                                <xsl:sequence select="string(collection()/descendant::*[@xml:id=$ref])"/>
                                            </xsl:copy>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each-group>
                        </xsl:for-each-group>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="current-group()">
                            <xsl:apply-templates select="."/>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="pxi:or-default" as="xs:string">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:sequence select="if ($value) then $value else $default"/>
    </xsl:function>
    
    <xsl:function name="pxi:get-page-layout-param">
        <xsl:param name="document" as="element()"/>
        <xsl:param name="param-name"/>
        <xsl:sequence select="$document/louis:page-layout//c:param[@name=$param-name]/@value"/>
    </xsl:function>
    
</xsl:stylesheet>
