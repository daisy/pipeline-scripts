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
        <xsl:variable name="top-left" as="element()*">
            <xsl:apply-templates select="pxi:margin-content($rules,'@top-left')" mode="eval-content-list"/>
        </xsl:variable>
        <xsl:variable name="top-center" as="element()*">
            <xsl:apply-templates select="pxi:margin-content($rules,'@top-center')" mode="eval-content-list"/>
        </xsl:variable>
        <xsl:variable name="top-right" as="element()*">
            <xsl:apply-templates select="pxi:margin-content($rules,'@top-right')" mode="eval-content-list"/>
        </xsl:variable>
        <xsl:variable name="bottom-left" as="element()*">
            <xsl:apply-templates select="pxi:margin-content($rules,'@bottom-left')" mode="eval-content-list"/>
        </xsl:variable>
        <xsl:variable name="bottom-center" as="element()*">
            <xsl:apply-templates select="pxi:margin-content($rules,'@bottom-center')" mode="eval-content-list"/>
        </xsl:variable>
        <xsl:variable name="bottom-right" as="element()*">
            <xsl:apply-templates select="pxi:margin-content($rules,'@bottom-right')" mode="eval-content-list"/>
        </xsl:variable>
        <xsl:variable name="properties" as="element()*"
                      select="css:parse-declaration-list($rules[not(@selector)]/@declaration-list)"/>
        <xsl:variable name="margin-top" as="xs:string"
                      select="($properties[@name='margin-top'][css:is-valid(.)]/@value, 'auto')[1]"/>
        <xsl:variable name="margin-bottom" as="xs:string"
                      select="($properties[@name='margin-bottom'][css:is-valid(.)]/@value, 'auto')[1]"/>
        <xsl:variable name="empty-string" as="element()">
            <string value=""/>
        </xsl:variable>
        <header>
            <xsl:if test="exists(($top-left, $top-center, $top-right)) or $margin-top!='auto'">
                <xsl:if test="$margin-top!='auto' and xs:integer($margin-top) &gt; 1">
                    <xsl:attribute name="row-spacing">
                        <xsl:value-of select="format-number(xs:integer($margin-top), '0.0')"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="exists(($top-left, $top-center, $top-right))">
                        <field>
                            <xsl:sequence select="if (exists($top-left)) then $top-left else $empty-string"/>
                        </field>
                        <field>
                            <xsl:sequence select="if (exists($top-center)) then $top-center else $empty-string"/>
                        </field>
                        <field>
                            <xsl:sequence select="if (exists($top-right)) then $top-right else $empty-string"/>
                        </field>
                    </xsl:when>
                    <xsl:otherwise>
                        <field/><!-- Empty field required for header to pass through obfl-to-pef -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </header>

        <xsl:choose>
            <xsl:when test="$margin-bottom!='auto' and xs:integer($margin-bottom) &gt; 0">
                <xsl:call-template name="createNFooters">
                    <xsl:with-param name="times" select="xs:integer($margin-bottom)"/>
	            <xsl:with-param name="bottom-left" select="$bottom-left"/>
                    <xsl:with-param name="bottom-center" select="$bottom-center"/>
	            <xsl:with-param name="bottom-right" select="$bottom-right"/>
                </xsl:call-template>
            </xsl:when>
            <!-- TODO: move otherwise logic to createNFooters -->
            <xsl:otherwise>
                <!-- Margin auto or margin = 0 -->
                <footer>
                    <xsl:if test="exists(($bottom-left, $bottom-center, $bottom-right)) or $margin-bottom!='auto'">
                        <xsl:choose>
                            <xsl:when test="exists(($bottom-left, $bottom-center, $bottom-right))">
                                <field>
                                    <xsl:sequence select="if (exists($bottom-left)) then $bottom-left else $empty-string"/>
                                </field>
                                <field>
                                    <xsl:sequence select="if (exists($bottom-center)) then $bottom-center else $empty-string"/>
                                </field>
                                <field>
                                    <xsl:sequence select="if (exists($bottom-right)) then $bottom-right else $empty-string"/>
                                </field>
                            </xsl:when>
                            <xsl:otherwise>
                                <field/><!-- Empty field required for footer to pass through obfl-to-pef -->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </footer>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="createNFooters">
	  <xsl:param name="times" select="1"/>
	  <xsl:param name="bottom-left"/>
	  <xsl:param name="bottom-center"/>
	  <xsl:param name="bottom-right"/>
      <xsl:variable name="empty-string" as="element()">
          <string value=""/>
      </xsl:variable>
	
      <!-- template is applied already once even if $times == 1 --> 
      <xsl:if test="$times &gt; 1">
	    <xsl:call-template name="createNFooters">
		  <xsl:with-param name="times" select="$times - 1"/>
                  <xsl:with-param name="bottom-left" select="if (exists($bottom-left)) then $bottom-left else $empty-string" as="element()"/>
                  <xsl:with-param name="bottom-center" select="if (exists($bottom-center)) then $bottom-center else $empty-string" as="element()"/>
                  <xsl:with-param name="bottom-right" select="if (exists($bottom-right)) then $bottom-right else $empty-string" as="element()"/>
	    </xsl:call-template>
      </xsl:if>
      <footer>
             <field>
               <xsl:sequence select="if (exists($bottom-left)) then $bottom-left else $empty-string"/>
             </field>
             <field>
               <xsl:sequence select="if (exists($bottom-center)) then $bottom-center else $empty-string"/>
             </field>
             <field>
               <xsl:sequence select="if (exists($bottom-right)) then $bottom-right else $empty-string"/>
             </field>
      </footer>
    </xsl:template>
    
    <xsl:function name="pxi:margin-content" as="element()*">
        <xsl:param name="margin-rules" as="element()*"/>
        <xsl:param name="selector" as="xs:string"/>
        <xsl:variable name="properties" as="element()*"
                      select="css:parse-declaration-list($margin-rules[@selector=$selector][1]/@declaration-list)"/>
        <xsl:variable name="white-space" as="xs:string" select="($properties[@name='white-space']/@value,'normal')[1]"/>
        <xsl:variable name="text-transform" as="xs:string" select="($properties[@name='text-transform']/@value,'auto')[1]"/>
        <xsl:if test="$white-space!='normal'">
            <xsl:message select="concat('white-space:',$white-space,' could not be applied to ',$selector)"/>
        </xsl:if>
        <xsl:if test="not($text-transform=('none','auto'))">
            <xsl:message select="concat('text-transform:',$text-transform,' could not be applied to ',$selector)"/>
        </xsl:if>
        <xsl:sequence select="css:parse-content-list($properties[@name='content'][1]/@value, ())"/>
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
    
</xsl:stylesheet>
