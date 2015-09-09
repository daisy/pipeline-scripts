<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/ns/2011/obfl"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:re="regex-utils"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <!--
        css-utils [2.0.0,3.0.0)
    -->
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:function name="obfl:generate-layout-master">
        <xsl:param name="page-stylesheet" as="xs:string"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:variable name="rules" as="element()*" select="css:parse-stylesheet($page-stylesheet)"/>
        <xsl:variable name="properties" as="element()*"
                      select="css:parse-declaration-list($rules[not(@selector)]/@declaration-list)"/>
        <xsl:variable name="size" as="xs:string"
                      select="($properties[@name='size'][css:is-valid(.)]/@value, css:initial-value('size'))[1]"/>
        <xsl:variable name="top-left" as="element()*">
            <xsl:apply-templates select="pxi:margin-content($rules, '@top-left')" mode="eval-content-list"/>
        </xsl:variable>
        <xsl:variable name="top-center" as="element()*">
            <xsl:apply-templates select="pxi:margin-content($rules, '@top-center')" mode="eval-content-list"/>
        </xsl:variable>
        <xsl:variable name="top-right" as="element()*">
            <xsl:apply-templates select="pxi:margin-content($rules, '@top-right')" mode="eval-content-list"/>
        </xsl:variable>
        <xsl:variable name="bottom-left" as="element()*">
            <xsl:apply-templates select="pxi:margin-content($rules, '@bottom-left')" mode="eval-content-list"/>
        </xsl:variable>
        <xsl:variable name="bottom-center" as="element()*">
            <xsl:apply-templates select="pxi:margin-content($rules, '@bottom-center')" mode="eval-content-list"/>
        </xsl:variable>
        <xsl:variable name="bottom-right" as="element()*">
            <xsl:apply-templates select="pxi:margin-content($rules, '@bottom-right')" mode="eval-content-list"/>
        </xsl:variable>
        <xsl:variable name="empty-string" as="element()">
            <string value=""/>
        </xsl:variable>
        <layout-master name="{$name}" duplex="false"
                            page-width="{tokenize($size, '\s+')[1]}" page-height="{tokenize($size, '\s+')[2]}">
            <default-template>
                <header>
                    <xsl:if test="exists(($top-left, $top-center, $top-right))">
                        <field>
                            <xsl:sequence select="if (exists($top-left)) then $top-left else $empty-string"/>
                        </field>
                        <field>
                            <xsl:sequence select="if (exists($top-center)) then $top-center else $empty-string"/>
                        </field>
                        <field>
                            <xsl:sequence select="if (exists($top-right)) then $top-right else $empty-string"/>
                        </field>
                    </xsl:if>
                </header>
                <footer>
                    <xsl:if test="exists(($bottom-left, $bottom-center, $bottom-right))">
                        <field>
                            <xsl:sequence select="if (exists($bottom-left)) then $bottom-left else $empty-string"/>
                        </field>
                        <field>
                            <xsl:sequence select="if (exists($bottom-center)) then $bottom-center else $empty-string"/>
                        </field>
                        <field>
                            <xsl:sequence select="if (exists($bottom-right)) then $bottom-right else $empty-string"/>
                        </field>
                    </xsl:if>
                </footer>
            </default-template>
        </layout-master>
    </xsl:function>
    
    <xsl:template match="css:string[@value]" mode="eval-content-list">
        <string value="{string(@value)}"/>
    </xsl:template>
    
    <xsl:template match="css:counter[not(@target)][@name='page']" mode="eval-content-list">
        <current-page style="{if (@style=('roman', 'upper-roman', 'lower-roman', 'upper-alpha', 'lower-alpha'))
                                   then @style else 'default'}"/>
    </xsl:template>
    
    <xsl:template match="css:string[@name][not(@target)]" mode="eval-content-list">
        <marker-reference marker="{@name}" direction="backward" scope="sequence"/>
    </xsl:template>
    
    <xsl:template match="css:attr" mode="eval-content-list">
        <xsl:message>attr() function not supported in page header and footer</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:content" mode="eval-content-list">
        <xsl:message>content() function not supported in page header and footer</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:text[@target]" mode="eval-content-list">
        <xsl:message>target-text() function not supported in page header and footer</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:string[@name][@target]" mode="eval-content-list">
        <xsl:message>target-string() function not supported in page header and footer</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:counter[@target]" mode="eval-content-list">
        <xsl:message>target-counter() function not supported in page header and footer</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:counter[not(@target)][not(@name='page')]" mode="eval-content-list">
        <xsl:message>counter() function not supported in page header and footer for other counters than 'page'</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:leader" mode="eval-content-list">
        <xsl:message>leader() function not supported in page header and footer</xsl:message>
    </xsl:template>
    
    <xsl:template match="*" mode="eval-content-list">
        <xsl:message terminate="yes">Coding error</xsl:message>
    </xsl:template>
    
    <xsl:function name="pxi:margin-content" as="element()*">
        <xsl:param name="margin-rules" as="element()*"/>
        <xsl:param name="selector" as="xs:string"/>
        <xsl:sequence select="css:parse-content-list(
                                css:parse-declaration-list($margin-rules[@selector=$selector][1]/@declaration-list)
                                [@name='content'][1]/@value, ())"/>
    </xsl:function>
    
</xsl:stylesheet>
