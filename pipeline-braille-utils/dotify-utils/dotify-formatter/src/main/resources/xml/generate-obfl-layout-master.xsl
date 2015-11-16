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
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:variable name="empty-string" as="element()">
        <string value=""/>
    </xsl:variable>
    
    <xsl:variable name="empty-field" as="element()">
        <field>
            <xsl:sequence select="$empty-string"/>
        </field>
    </xsl:variable>
    
    <xsl:function name="obfl:generate-layout-master">
        <xsl:param name="page-stylesheet" as="xs:string?"/>
        <xsl:param name="page-right-stylesheet" as="xs:string?"/>
        <xsl:param name="page-left-stylesheet" as="xs:string?"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:variable name="rules" as="element()*" select="css:parse-stylesheet($page-stylesheet)"/>
        <xsl:variable name="properties" as="element()*"
                      select="css:parse-declaration-list($rules[not(@selector)]/@declaration-list)"/>
        <xsl:variable name="size" as="xs:string"
                      select="($properties[@name='size'][css:is-valid(.)]/@value, css:initial-value('size'))[1]"/>
        <layout-master name="{$name}" duplex="true" page-number-variable="page"
                       page-width="{tokenize($size, '\s+')[1]}" page-height="{tokenize($size, '\s+')[2]}">
            <xsl:if test="exists($page-right-stylesheet)">
                <!--
                    FIXME: is this influenced by initial-page-number?
                -->
                <template use-when="(= (% $page 2) 1)">
                    <xsl:call-template name="template">
                        <xsl:with-param name="rules" select="css:parse-stylesheet($page-right-stylesheet)"/>
                    </xsl:call-template>
                </template>
            </xsl:if>
            <xsl:if test="exists($page-left-stylesheet)">
                <template use-when="(= (% $page 2) 0)">
                    <xsl:call-template name="template">
                        <xsl:with-param name="rules" select="css:parse-stylesheet($page-left-stylesheet)"/>
                    </xsl:call-template>
                </template>
            </xsl:if>
            <default-template>
                <xsl:call-template name="template">
                    <xsl:with-param name="rules" select="$rules"/>
                </xsl:call-template>
            </default-template>
        </layout-master>
    </xsl:function>
    
    <xsl:template name="template">
        <xsl:param name="rules" as="element()*" required="yes"/>
        <xsl:variable name="top-left" as="element()*" select="pxi:fields($rules,'@top-left')"/>
        <xsl:variable name="top-center" as="element()*" select="pxi:fields($rules,'@top-center')"/>
        <xsl:variable name="top-right" as="element()*" select="pxi:fields($rules,'@top-right')"/>
        <xsl:variable name="bottom-left" as="element()*" select="pxi:fields($rules,'@bottom-left')"/>
        <xsl:variable name="bottom-center" as="element()*" select="pxi:fields($rules,'@bottom-center')"/>
        <xsl:variable name="bottom-right" as="element()*" select="pxi:fields($rules,'@bottom-right')"/>
        <xsl:variable name="properties" as="element()*"
                      select="css:parse-declaration-list($rules[not(@selector)]/@declaration-list)"/>
        <xsl:variable name="margin-top" as="xs:integer"
                      select="($properties[@name='margin-top'][css:is-valid(.)]/xs:integer(@value),0)[1]"/>
        <xsl:variable name="margin-bottom" as="xs:integer"
                      select="($properties[@name='margin-bottom'][css:is-valid(.)]/xs:integer(@value),0)[1]"/>
        <xsl:choose>
            <xsl:when test="exists(($top-left, $top-center, $top-right)) or $margin-top &gt; 0">
                <xsl:call-template name="headers">
                    <xsl:with-param name="times" select="$margin-top"/>
                    <xsl:with-param name="left" select="$top-left"/>
                    <xsl:with-param name="center" select="$top-center"/>
                    <xsl:with-param name="right" select="$top-right"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <header/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="exists(($bottom-left, $bottom-center, $bottom-right)) or $margin-bottom &gt; 0">
                <xsl:call-template name="footers">
                    <xsl:with-param name="times" select="$margin-bottom"/>
                    <xsl:with-param name="left" select="$bottom-left"/>
                    <xsl:with-param name="center" select="$bottom-center"/>
                    <xsl:with-param name="right" select="$bottom-right"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <footer/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="headers"> <!-- obfl:header* -->
        <xsl:param name="times" as="xs:integer" required="yes"/>
        <xsl:param name="left" as="element()*" required="yes"/> <!-- obfl:field* -->
        <xsl:param name="center" as="element()*" required="yes"/> <!-- obfl:field* -->
        <xsl:param name="right" as="element()*" required="yes"/> <!-- obfl:field* -->
        <xsl:if test="exists(($left, $center, $right)) or $times &gt; 0">
            <header>
                <xsl:sequence select="($left,$empty-field)[1]"/>
                <xsl:sequence select="($center,$empty-field)[1]"/>
                <xsl:sequence select="($right,$empty-field)[1]"/>
            </header>
            <xsl:call-template name="headers">
                <xsl:with-param name="times" select="$times - 1"/>
                <xsl:with-param name="left" select="$left[position()&gt;1]"/>
                <xsl:with-param name="center" select="$center[position()&gt;1]"/>
                <xsl:with-param name="right" select="$right[position()&gt;1]"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="footers"> <!-- obfl:footer* -->
        <xsl:param name="times" as="xs:integer" required="yes"/>
        <xsl:param name="left" as="element()*" required="yes"/> <!-- obfl:field* -->
        <xsl:param name="center" as="element()*" required="yes"/> <!-- obfl:field* -->
        <xsl:param name="right" as="element()*" required="yes"/> <!-- obfl:field* -->
        <xsl:if test="exists(($left, $center, $right)) or $times &gt; 0">
            <xsl:call-template name="footers">
                <xsl:with-param name="times" select="$times - 1"/>
                <xsl:with-param name="left" select="$left[position()&lt;last()]"/>
                <xsl:with-param name="center" select="$center[position()&lt;last()]"/>
                <xsl:with-param name="right" select="$right[position()&lt;last()]"/>
            </xsl:call-template>
            <footer>
                <xsl:sequence select="($empty-field,$left)[last()]"/>
                <xsl:sequence select="($empty-field,$center)[last()]"/>
                <xsl:sequence select="($empty-field,$right)[last()]"/>
            </footer>
        </xsl:if>
    </xsl:template>
    
    <xsl:function name="pxi:fields" as="element()*"> <!-- obfl:field* -->
        <xsl:param name="margin-rules" as="element()*"/>
        <xsl:param name="selector" as="xs:string"/>
        <xsl:variable name="properties" as="element()*"
                      select="css:parse-declaration-list($margin-rules[@selector=$selector][1]/@declaration-list)"/>
        <xsl:variable name="white-space" as="xs:string" select="($properties[@name='white-space']/@value,'normal')[1]"/>
        <xsl:variable name="text-transform" as="xs:string" select="($properties[@name='text-transform']/@value,'auto')[1]"/>
        <xsl:if test="not($text-transform=('none','auto'))">
            <xsl:message select="concat('text-transform:',$text-transform,' could not be applied to ',$selector)"/>
        </xsl:if>
        <xsl:variable name="content" as="element()*">
            <xsl:apply-templates select="css:parse-content-list($properties[@name='content'][1]/@value,())" mode="eval-content-list">
                <xsl:with-param name="white-space" select="$white-space"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:for-each-group select="$content" group-ending-with="obfl:br">
            <field>
                <xsl:sequence select="if (current-group()[not(self::obfl:br)])
                                      then current-group()[not(self::obfl:br)]
                                      else $empty-string"/>
            </field>
        </xsl:for-each-group>
    </xsl:function>
    
    <xsl:template match="css:string[@value]" mode="eval-content-list">
        <xsl:param name="white-space" as="xs:string" select="'normal'"/>
        <xsl:choose>
            <xsl:when test="$white-space=('pre-wrap','pre-line')">
                <!--
                    TODO: wrapping is not allowed, warn if content is clipped
                -->
                <xsl:analyze-string select="string(@value)" regex="\n">
                    <xsl:matching-substring>
                        <br/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:choose>
                            <xsl:when test="$white-space='pre-wrap'">
                                <string value="{replace(.,'\s','&#x00A0;')}"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <string value="{.}"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <string value="{string(@value)}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:counter[not(@target)][@name='page']" mode="eval-content-list">
        <xsl:param name="white-space" as="xs:string" select="'normal'"/>
        <xsl:if test="$white-space!='normal'">
            <xsl:message select="concat('white-space:',$white-space,' could not be applied to target-counter(',@name,')')"/>
        </xsl:if>
        <current-page number-format="{if (@style=('roman', 'upper-roman', 'lower-roman', 'upper-alpha', 'lower-alpha'))
                                      then @style else 'default'}"/>
    </xsl:template>
    
    <xsl:template match="css:string[@name][not(@target)]" mode="eval-content-list">
        <xsl:param name="white-space" as="xs:string" tunnel="yes" select="'normal'"/>
        <xsl:if test="$white-space!='normal'">
            <xsl:message select="concat('white-space:',$white-space,' could not be applied to target-string(',@name,')')"/>
        </xsl:if>
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
    
</xsl:stylesheet>
