<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/ns/2011/obfl"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0" >
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl" />
    
    <xsl:include href="generate-obfl-layout-master.xsl"/>
    
    <xsl:param name="braille-translator-query" as="xs:string" select="''"/>
    
    <xsl:key name="page-stylesheet" match="/*[not(@css:flow)]" use="string(@css:page)"/>
    
    <xsl:function name="pxi:generate-layout-master-name" as="xs:string">
        <xsl:param name="page-stylesheet" as="xs:string"/>
        <xsl:variable name="elem" as="element()" select="(collection()[not(@css:flow)]/key('page-stylesheet', $page-stylesheet))[1]"/>
        <xsl:sequence select="generate-id($elem)"/>
    </xsl:function>
    
    <xsl:function name="pxi:generate-layout-master" as="element()">
        <xsl:param name="page-stylesheet" as="xs:string"/>
        <xsl:variable name="elem" as="element()" select="(collection()/*[not(@css:flow)]/key('page-stylesheet', $page-stylesheet))[1]"/>
        <xsl:sequence select="obfl:generate-layout-master(
                                $elem/string(@css:page),
                                pxi:generate-layout-master-name($page-stylesheet))"/>
    </xsl:function>

    <xsl:template name="main">
        <obfl version="2011-1" xml:lang="und" hyphenate="false">
            <xsl:for-each select="distinct-values(collection()/*[not(@css:flow)]/string(@css:page))">
                <xsl:sequence select="pxi:generate-layout-master(.)"/>
            </xsl:for-each>
            <xsl:variable name="volume-styles" as="xs:string*"
                          select="distinct-values(collection()/*[not(@css:flow)]/(self::*|descendant::*[@css:volume])/string(@css:volume))"/>
            <xsl:if test="count($volume-styles) &gt; 1">
                <xsl:message terminate="yes">Documents with more than one volume style are not supported.</xsl:message>
            </xsl:if>
            <xsl:variable name="volume-area-rules" as="element()*"
                          select="css:parse-stylesheet($volume-styles[1])[@selector=('@begin','@end')]"/>
            <xsl:variable name="volume-begin-content" as="element()*"
                          select="css:parse-content-list(
                                    css:parse-declaration-list($volume-area-rules[@selector='@begin'][1]/@style)
                                    [@name='content'][1]/@value, ())"/>
            <xsl:variable name="volume-end-content" as="element()*"
                          select="css:parse-content-list(
                                    css:parse-declaration-list($volume-area-rules[@selector='@end'][1]/@style)
                                    [@name='content'][1]/@value, ())"/>
            <xsl:if test="$volume-begin-content|$volume-end-content">
                <xsl:variable name="no-upper-limit" select="'1000'"/>
                <volume-template sheets-in-volume-max="{$no-upper-limit}">
                    <xsl:if test="$volume-begin-content">
                        <pre-content>
                            <sequence master="{pxi:generate-layout-master-name(
                                                 (collection()/*[not(@css:flow)])[1]/string(@css:page))}">
                                <xsl:apply-templates select="$volume-begin-content" mode="eval-volume-area-content-list">
                                    <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                                    <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
                                </xsl:apply-templates>
                            </sequence>
                        </pre-content>
                    </xsl:if>
                    <xsl:if test="$volume-end-content">
                        <post-content>
                            <sequence master="{pxi:generate-layout-master-name(
                                                 (collection()/*[not(@css:flow)])[last()]/string(@css:page))}">
                                <xsl:apply-templates select="$volume-end-content" mode="eval-volume-area-content-list">
                                    <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                                    <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
                                </xsl:apply-templates>
                            </sequence>
                        </post-content>
                    </xsl:if>
                </volume-template>
            </xsl:if>
            <!--
            <xsl:for-each select="collection()/*[@css:flow]">
                <xsl:variable name="flow" as="xs:string" select="@css:flow"/>
                <collection name="{$flow}">
                    <xsl:for-each select="*">
                        <item id="{@css:anchor}">
                            <xsl:apply-templates select=".">
                                <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                                <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
                            </xsl:apply-templates>
                        </item>
                    </xsl:for-each>
                </collection>
            </xsl:for-each>
            -->
            <xsl:apply-templates select="collection()/*[not(@css:flow)]">
                <xsl:with-param name="text-transform" tunnel="yes" select="'auto'"/>
                <xsl:with-param name="hyphens" tunnel="yes" select="'manual'"/>
            </xsl:apply-templates>
        </obfl>
    </xsl:template>
    
    <xsl:template match="/*" priority="0.6">
        <xsl:element name="sequence">
            <xsl:attribute name="master" select="pxi:generate-layout-master-name(string(@css:page))"/>
            <xsl:if test="@css:counter-set-page">
                <xsl:attribute name="initial-page-number" select="@css:counter-set-page"/>
            </xsl:if>
            <xsl:next-match/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="/*/@css:counter-set-page|
                         /*/@css:page|
                         /*/@css:page_left|
                         /*/@css:page_right|
                         /*/@css:volume"/>
    
    <xsl:template match="/css:_">
        <xsl:apply-templates select="@*|node()"/>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block']" name="block">
        <block>
            <xsl:apply-templates select="@* except (@css:string-entry|@css:string-set)"/>
            <xsl:apply-templates select="@css:string-entry"/>
            <xsl:apply-templates select="@css:string-set"/>
            <xsl:apply-templates/>
            <!-- <xsl:apply-templates select="@css:id" mode="anchor"/> -->
        </block>
    </xsl:template>
    
    <xsl:template match="css:box[@type='inline']">
        <xsl:variable name="attrs" as="attribute()*">
            <xsl:apply-templates select="@* except (@css:string-entry|@css:string-set)"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="exists($attrs)">
                <!--
                    FIXME: - nested spans are a problem - id on a span is a problem
                -->
                <span>
                    <xsl:sequence select="$attrs"/>
                    <xsl:apply-templates select="@css:string-entry"/>
                    <xsl:apply-templates select="@css:string-set"/>
                    <xsl:apply-templates/>
                    <!-- <xsl:apply-templates select="@css:id" mode="anchor"/> -->
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="@css:string-entry"/>
                <xsl:apply-templates select="@css:string-set"/>
                <xsl:apply-templates/>
                <!-- <xsl:apply-templates select="@css:id" mode="anchor"/> -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:box[@css:hyphens]" priority="0.6">
        <xsl:next-match>
            <xsl:with-param name="hyphens" tunnel="yes" select="@css:hyphens"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="css:box[@css:text-transform]" priority="0.7">
        <xsl:next-match>
            <xsl:with-param name="text-transform" tunnel="yes" select="@css:text-transform"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="css:box/@type|
                         css:box/@name|
                         css:box/@part"/>
    
    <xsl:template match="@css:hyphens">
        <!--
            'hyphens:auto' corresponds with 'hyphenate="true"'. 'hyphens:manual' corresponds with
            'hyphenate="false"'. For 'hyphens:none' all SHY and ZWSP characters are removed from the
            text.
        -->
        <xsl:attribute name="hyphenate" select="if (.='auto') then 'true' else 'false'"/>
    </xsl:template>
    
    <xsl:template match="@css:text-transform">
        <!--
            'text-transform:auto' corresponds with 'translate=""'. 'text-transform:none' would
            normally correspond with 'translate="pre-translated"', but because "pre-translated"
            currently delegates to a non-configurable bypass translator, 'translate=""' is used here
            too. Other values of text-transform are currently handled by translating prior to
            formatting when possible and otherwise (i.e. for content generated while formatting)
            ignored. FIXME: make use of style elements.
        -->
    </xsl:template>
    
    <xsl:template match="@css:collapsing-margins"/>
    
    <xsl:template match="@css:margin-left|
                         @css:margin-right|
                         @css:margin-top|
                         @css:margin-bottom">
        <xsl:attribute name="{local-name()}" select="format-number(xs:integer(number(.)), '0')"/>
    </xsl:template>
    
    <xsl:template match="@css:line-height">
        <xsl:attribute name="row-spacing" select="format-number(xs:integer(number(.)), '0.0')"/>
    </xsl:template>
    
    <!--
        blocks with both line-height and margins or borders
    -->
    <xsl:template match="css:box[@type='block' and @css:line-height and (@css:margin-top or @css:margin-bottom or @css:border-top or @css:border-bottom)]">
      <block>
          <xsl:apply-templates select="@* except (@css:string-entry|@css:string-set|
                                                  @css:line-height|
                                                  @css:text-align|@css:text-indent|@page-break-inside)"/>
          <xsl:apply-templates select="@css:string-entry|@css:string-set"/>
          <block>
              <xsl:apply-templates select="@css:line-height|
                                           @css:text-align|@css:text-indent|@page-break-inside|@css:orphans|@css:widows"/>
              <xsl:apply-templates/>
              <!-- <xsl:apply-templates select="@css:id" mode="anchor"/> -->
          </block>
      </block>
    </xsl:template>
    
    <xsl:template match="css:box[@type='block' and not(child::css:box[@type='block']) and @css:text-indent]/@css:margin-left"/>
    
    <xsl:template match="css:box[@type='block' and not(child::css:box[@type='block'])]/@css:text-indent">
        <xsl:variable name="text-indent" as="xs:integer" select="xs:integer(number(.))"/>
        <xsl:variable name="margin-left" as="xs:integer" select="(parent::*/@css:margin-left/xs:integer(number(.)),0)[1]"/>
        <xsl:if test="parent::*[@name or not(preceding-sibling::css:box)]">
            <xsl:attribute name="first-line-indent" select="format-number($margin-left + $text-indent, '0')"/>
        </xsl:if>
        <xsl:if test="$margin-left &gt; 0">
            <xsl:attribute name="text-indent" select="format-number($margin-left, '0')"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@css:text-indent"/>
    
    <xsl:template match="@css:text-align">
        <xsl:attribute name="align" select="."/>
    </xsl:template>
    
    <xsl:template match="@css:_obfl-vertical-position">
        <xsl:attribute name="vertical-position" select="."/>
    </xsl:template>
    
    <xsl:template match="@css:_obfl-vertical-align">
        <xsl:attribute name="vertical-align" select="."/>
    </xsl:template>
    
    <xsl:template match="@css:page-break-before[.='always']">
        <xsl:attribute name="break-before" select="'page'"/>
    </xsl:template>
    
    <xsl:template match="@css:page-break-after[.='avoid']">
        <xsl:attribute name="keep-with-next" select="'1'"/>
        <!--
            keep-with-next="1" requires that keep="all". This gives it a slighly different meaning
            than "page-break-after: avoid", but it will do.
        -->
        <xsl:if test="not(parent::*/@css:page-break-inside[.='avoid'])">
            <xsl:attribute name="keep" select="'all'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@css:page-break-inside[.='avoid']">
        <xsl:attribute name="keep" select="'all'"/>
    </xsl:template>
    
    <xsl:template match="@css:border-left|
                         @css:border-right">
        <xsl:choose>
            <xsl:when test=".='none'">
                <xsl:attribute name="{local-name()}-style" select="'none'"/>
            </xsl:when>
            <xsl:when test=".=('⠇','⠿','⠸')">
                <xsl:attribute name="{local-name()}-style" select="'solid'"/>
                <xsl:choose>
                    <xsl:when test=".='⠿'">
                        <xsl:attribute name="{local-name()}-width" select="'2'"/>
                    </xsl:when>
                    <xsl:when test=".='⠇'">
                        <xsl:attribute name="{local-name()}-align"
                                       select="if (local-name()='border-left') then 'outer' else 'inner'"/>
                    </xsl:when>
                    <xsl:when test=".='⠸'">
                        <xsl:attribute name="{local-name()}-align"
                                       select="if (local-name()='border-right') then 'outer' else 'inner'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="concat(local-name(),':',.,' not supported yet')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@css:border-top|
                         @css:border-bottom">
        <xsl:choose>
            <xsl:when test=".='none'">
                <xsl:attribute name="{local-name()}-style" select="'none'"/>
            </xsl:when>
            <xsl:when test=".=('⠉','⠛','⠒','⠿','⠶','⠤')">
                <xsl:attribute name="{local-name()}-style" select="'solid'"/>
                <xsl:choose>
                    <xsl:when test=".=('⠛','⠶')">
                        <xsl:attribute name="{local-name()}-width" select="'2'"/>
                    </xsl:when>
                    <xsl:when test=".='⠿'">
                        <xsl:attribute name="{local-name()}-width" select="'3'"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test=".=('⠉','⠛')">
                        <xsl:attribute name="{local-name()}-align"
                                       select="if (local-name()='border-top') then 'outer' else 'inner'"/>
                    </xsl:when>
                    <xsl:when test=".=('⠶','⠤')">
                        <xsl:attribute name="{local-name()}-align"
                                       select="if (local-name()='border-top') then 'inner' else 'outer'"/>
                    </xsl:when>
                    <xsl:when test=".='⠒'">
                        <xsl:attribute name="{local-name()}-align"
                                       select="'center'"/>
                    </xsl:when>
                    
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="concat(local-name(),':',.,' not supported yet')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@css:orphans|@css:widows">
        <xsl:attribute name="{local-name()}" select="."/>
    </xsl:template>
    
    <xsl:template match="css:string[@name]">
        <xsl:if test="@scope">
            <xsl:message select="concat('string(',@name,', ',@scope,'): second argument not supported')"/>
        </xsl:if>
        <xsl:if test="@css:white-space">
            <xsl:message select="concat('white-space:',@css:white-space,' could not be applied to ',
                                        (if (@target) then 'target-string' else 'string'),'(',@name,')')"/>
        </xsl:if>
        <xsl:variable name="target" as="xs:string?"
                      select="if (@target) then @target else
                              if (ancestor::*/@css:flow[not(.='normal')]) then ancestor::*/@css:anchor else ()"/>
        <xsl:variable name="target" as="element()?"
                      select="if ($target) then collection()//*[@css:id=$target][1] else ."/>
        <xsl:if test="$target">
            <xsl:apply-templates select="css:string(@name, $target)" mode="eval-string"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:string[@value]" mode="eval-string">
        <xsl:call-template name="text">
            <xsl:with-param name="text" select="string(@value)"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="css:counter[@target][@name='page']">
        <xsl:param name="text-transform" as="xs:string" tunnel="yes"/>
        <xsl:param name="hyphens" as="xs:string" tunnel="yes"/>
        <xsl:if test="@css:white-space">
            <xsl:message select="concat('white-space:',@css:white-space,' could not be applied to target-counter(page)')"/>
        </xsl:if>
        <xsl:if test="not($text-transform=('auto','none'))">
            <!--
                FIXME: make use of style element
            -->
            <xsl:message select="concat('text-transform:',$text-transform,' could not be applied to target-counter(page)')"/>
        </xsl:if>
        <xsl:if test="$hyphens='none'">
            <!--
                FIXME: make use of style element
            -->
            <xsl:message select="'hyphens:none could not be applied to target-counter(page)'"/>
        </xsl:if>
        <page-number ref-id="{@target}" number-format="{if (@style=('roman', 'upper-roman', 'lower-roman', 'upper-alpha', 'lower-alpha'))
                                                        then @style else 'default'}"/>
    </xsl:template>
    
    <xsl:template match="css:leader">
        <leader pattern="{@pattern}" position="100%" align="right"/>
    </xsl:template>
    
    <xsl:template match="css:box/@css:id">
        <xsl:variable name="id" as="xs:string" select="."/>
        <xsl:if test="collection()//css:counter[@target=$id]">
            <xsl:attribute name="id" select="$id"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:box/@css:id" mode="anchor">
        <xsl:variable name="id" as="xs:string" select="."/>
        <xsl:if test="collection()/*[@css:flow]/*/@css:anchor=$id">
            <anchor item="{$id}"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:box/@css:anchor"/>
    
    <xsl:template match="css:box/@css:string-entry|
                         css:box/@css:string-set">
        <xsl:apply-templates select="css:parse-string-set(.)" mode="parse-string-set"/>
    </xsl:template>
    
    <xsl:template match="css:string-set" mode="parse-string-set">
        <xsl:variable name="value" as="xs:string*">
            <xsl:apply-templates select="css:parse-content-list(@value, ())" mode="eval-string-set"/>
        </xsl:variable>
        <marker class="{@name}" value="{string-join($value,'')}"/>
    </xsl:template>
    
    <xsl:template match="css:string[@value]" mode="eval-string-set" as="xs:string">
        <xsl:sequence select="string(@value)"/>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:call-template name="text">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="text">
        <xsl:param name="text" as="xs:string" required="yes"/>
        <xsl:param name="text-transform" as="xs:string" tunnel="yes"/>
        <xsl:param name="hyphens" as="xs:string" tunnel="yes"/>
        <xsl:variable name="text" as="xs:string">
            <xsl:choose>
                <!--
                    text-transform values 'none' and 'auto' are handled during formatting. A
                    translation is performed only when there are non-braille characters in the text.
                -->
                <xsl:when test="$text-transform=('none','auto')">
                    <xsl:value-of select="$text"/>
                </xsl:when>
                <!--
                    Other values are handled by translating prior to formatting.
                -->
                <xsl:otherwise>
                    <xsl:value-of select="pf:text-transform($braille-translator-query,
                                                            $text,
                                                            concat('text-transform:',$text-transform))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="text" as="xs:string" select="translate($text,'&#x2800;',' ')"/>
        <xsl:choose>
            <!--
                For 'hyphens:none' all SHY and ZWSP characters are removed from the text in advance.
            -->
            <xsl:when test="$hyphens='none'">
                <xsl:value-of select="replace($text,'[&#x00AD;&#x200B;]','')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:white-space">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="css:white-space/text()">
        <xsl:analyze-string select="." regex="\n">
            <xsl:matching-substring>
                <br/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="\s+">
                    <xsl:matching-substring>
                        <xsl:value-of select="concat(replace(.,'.','&#x00A0;'),'&#x200B;')"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="@*|*">
        <xsl:message terminate="yes">Coding error</xsl:message>
    </xsl:template>
    
    <!-- ================================== -->
    <!-- MODE eval-volume-area-content-list -->
    <!-- ================================== -->
    
    <xsl:template match="css:string[@value]" mode="eval-volume-area-content-list">
        <xsl:value-of select="@value"/>
    </xsl:template>
    
    <xsl:template match="css:flow[@from]" mode="eval-volume-area-content-list">
        <xsl:variable name="flow" as="xs:string" select="@from"/>
        <block>
            <xsl:apply-templates select="collection()/*[@css:flow=$flow]/*"/>
        </block>
    </xsl:template>
    
    <xsl:template match="css:attr" mode="eval-volume-area-content-list">
        <xsl:message>attr() function not supported in volume area</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:content" mode="eval-volume-area-content-list">
        <xsl:message>content() function not supported in volume area</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:string[@name][not(@target)]" mode="eval-volume-area-content-list">
        <xsl:message>string() function not supported in volume area</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:counter[not(@target)]" mode="eval-volume-area-content-list">
        <xsl:message>counter() function not supported in volume area</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:text[@target]" mode="eval-volume-area-content-list">
        <xsl:message>target-text() function not supported in volume area</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:string[@name][@target]" mode="eval-volume-area-content-list">
        <xsl:message>target-string() function not supported in volume area</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:counter[@target]" mode="eval-volume-area-content-list">
        <xsl:message>target-counter() function not supported in volume area</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:leader" mode="eval-volume-area-content-list">
        <xsl:message>leader() function not supported in volume area</xsl:message>
    </xsl:template>
    
    <xsl:template match="*" mode="eval-volume-area-content-list">
        <xsl:message terminate="yes">Coding error</xsl:message>
    </xsl:template>
    
</xsl:stylesheet>
