<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:re="regex-utils"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:import href="regex-utils.xsl"/>
    <xsl:import href="counters.xsl"/>
    
    <!-- ====== -->
    <!-- Syntax -->
    <!-- ====== -->
    
    <!--
        <color>
        # groups: 0
    -->
    <xsl:variable name="css:COLOR_RE" select="'#[0-9A-F]{6}'"/>
    
    <!--
        <braille-character>
        # groups: 0
    -->
    <xsl:variable name="css:BRAILLE_CHAR_RE" select="'\p{IsBraillePatterns}'"/>
    
    <!--
        <braille-string>
        # groups: 0
    -->
    <xsl:variable name="css:BRAILLE_STRING_RE">'\p{IsBraillePatterns}*?'|"\p{IsBraillePatterns}*?"</xsl:variable>
    
    <!--
        <ident>
        # groups: 2
    -->
    <xsl:variable name="css:IDENT_RE" select="'(\p{L}|_)(\p{L}|_|-)*'"/>
    
    <!--
        # groups: 5
    -->
    <xsl:variable name="css:IDENT_LIST_RE" select="re:space-separated($css:IDENT_RE)"/>
    
    <!--
        <integer>
        # groups: 0
    -->
    <xsl:variable name="css:INTEGER_RE" select="'0|-?[1-9][0-9]*'"/>

    
    <!--
        non-negative <integer>
        # groups: 0
    -->
    <xsl:variable name="css:NON_NEGATIVE_INTEGER_RE" select="'0|[1-9][0-9]*'"/>
    
    <!--
        <string>
        # groups: 0
    -->
    <xsl:variable name="css:STRING_RE">'[^']*'|"[^"]*"</xsl:variable>
    
    <!--
        content()
        # groups: 0
    -->
    <xsl:variable name="css:CONTENT_FN_RE" select="'content\(\)'"/>
    
    <!--
        attr(<name>)
        # groups: 3
        $1: <name>
    -->
    <xsl:variable name="css:ATTR_FN_RE" select="concat('attr\(\s*(',$css:IDENT_RE,')\s*\)')"/>
    
    <!--
        url(<string>) | attr(<name> url)
        #groups: 5
        $1: <string>
        $2: <name>
    -->
    <xsl:variable name="css:URL_RE" select="concat('url\(\s*(',$css:STRING_RE,')\s*\)|attr\(\s*(',$css:IDENT_RE,')(\s+url)?\s*\)')"/>
    
    <!--
        string(<ident>)
        # groups: 3
        $1: <ident>
    -->
    <xsl:variable name="css:STRING_FN_RE" select="concat('string\(\s*(',$css:IDENT_RE,')\s*\)')"/>
    
    <!--
        counter(<ident>,<counter-style>?)
        # groups: 7
        $1: <ident>
        $5: <counter-style>
    -->
    <xsl:variable name="css:COUNTER_FN_RE" select="concat('counter\(\s*(',$css:IDENT_RE,')\s*(,\s*(',$css:IDENT_RE,')\s*)?\)')"/>
    
    <!--
        target-text(<url>)
        # groups: 6
        $1: <url>
    -->
    <xsl:variable name="css:TARGET_TEXT_FN_RE" select="concat('target-text\(\s*(',$css:URL_RE,')\s*\)')"/>
    
    <!--
        target-string(<url>,<ident>)
        # groups: 9
        $1: <url>
        $7: <ident>
    -->
    <xsl:variable name="css:TARGET_STRING_FN_RE" select="concat('target-string\(\s*(',$css:URL_RE,')\s*,\s*(',$css:IDENT_RE,')\s*\)')"/>
    
    <!--
        target-counter(<url>,<ident>,<counter-style>?)
        # groups: 13
        $1: <url>
        $7: <ident>
        $11: <counter-style>
    -->
    <xsl:variable name="css:TARGET_COUNTER_FN_RE" select="concat('target-counter\(\s*(',$css:URL_RE,')\s*,\s*(',$css:IDENT_RE,')\s*(,\s*(',$css:IDENT_RE,')\s*)?\)')"/>
    
    <!--
        leader(<braille-string>)
        # groups: 1
        $1: <braille-string>
    -->
    <xsl:variable name="css:LEADER_FN_RE" select="concat('leader\(\s*(',$css:BRAILLE_STRING_RE,')\s*\)')"/>
    
    <!--
        # groups: 51
        $1: <string>
        $2: content()
        $3: attr(<name>)
        $4:      <name>
        $7: string(<ident>)
        $8:        <ident>
        $11: counter(<ident>,<counter-style>?)
        $12:         <ident>
        $16:                 <counter-style>
        $19: target-text(<url>)
        $20:             <url>
        $26: target-string(<url>,<ident>)
        $27:               <url>
        $33:                     <ident>
        $36: target-counter(<url>,<ident>,<counter-style>?)
        $37:                <url>
        $43:                      <ident>
        $47:                              <counter-style>
        $50: leader(<braille-string>)
        $51:        <braille-string>
    -->
    <xsl:variable name="css:CONTENT_RE" select="concat('(',$css:STRING_RE,')|
                                                        (',$css:CONTENT_FN_RE,')|
                                                        (',$css:ATTR_FN_RE,')|
                                                        (',$css:STRING_FN_RE,')|
                                                        (',$css:COUNTER_FN_RE,')|
                                                        (',$css:TARGET_TEXT_FN_RE,')|
                                                        (',$css:TARGET_STRING_FN_RE,')|
                                                        (',$css:TARGET_COUNTER_FN_RE,')|
                                                        (',$css:LEADER_FN_RE,')')"/>
    
    <!--
        # groups: ?
    -->
    <xsl:variable name="css:CONTENT_LIST_RE" select="re:space-separated($css:CONTENT_RE)"/>
    
    <!--
        # groups: ?
        $1: <ident>
        $4: <content-list>
    -->
    <xsl:variable name="css:STRING_SET_PAIR_RE" select="concat('(',$css:IDENT_RE,')\s+(',$css:CONTENT_LIST_RE,')')"/>
    
    <!--
        #groups: 5
        $1: <ident>
        $5: <integer>
    -->
    <xsl:variable name="css:COUNTER_SET_PAIR_RE" select="concat('(',$css:IDENT_RE,')(\s+(',$css:INTEGER_RE,'))?')"/>
    
    <!--
        # groups: 1
    -->
    <xsl:variable name="css:DECLARATION_LIST_RE">([^'"\{\}]+|'[^']*'|"[^"]*")*</xsl:variable>
    
    <!--
        # groups: 8
        $2: selector
        $6: declaration list
    -->
    <xsl:variable name="css:RULE_RE" select="concat('(((@|::)',$css:IDENT_RE,')\s+)?\{(
                                                       (
                                                         ',$css:DECLARATION_LIST_RE,'
                                                         |
                                                         \{(',$css:DECLARATION_LIST_RE,')\}
                                                       )*
                                                     )\}')"/>
    
    <!-- ======= -->
    <!-- Parsing -->
    <!-- ======= -->
    
    <xsl:function name="css:property">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="$value instance of xs:integer">
                <css:property name="{$name}" value="{format-number($value, '0')}"/>
            </xsl:when>
            <xsl:otherwise>
                <css:property name="{$name}" value="{$value}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="@css:*" mode="css:attribute-as-property" as="element()">
        <css:property name="{local-name()}" value="{string()}"/>
    </xsl:template>
    
    <xsl:template match="css:property" mode="css:property-as-attribute" as="attribute()">
        <xsl:attribute name="css:{@name}" select="@value"/>
    </xsl:template>
    
    <xsl:function name="css:parse-stylesheet" as="element()*">
        <xsl:param name="stylesheet" as="xs:string?"/>
        <xsl:if test="$stylesheet">
            <xsl:variable name="declarations" as="xs:string"
                          select="replace($stylesheet, $css:RULE_RE, '', 'x')"/>
            <xsl:if test="not(normalize-space($declarations)='')">
                <css:rule declaration-list="{$declarations}"/>
            </xsl:if>
            <xsl:analyze-string select="$stylesheet" regex="{$css:RULE_RE}" flags="x">
                <xsl:matching-substring>
                    <xsl:element name="css:rule">
                        <xsl:if test="regex-group(1)!=''">
                            <xsl:attribute name="selector" select="regex-group(2)"/>
                        </xsl:if>
                        <xsl:attribute name="declaration-list" select="replace(regex-group(6), '(^\s+|\s+$)', '')"/>
                    </xsl:element>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:parse-declaration-list" as="element()*">
        <xsl:param name="declaration-list" as="xs:string?"/>
        <xsl:if test="$declaration-list">
            <xsl:for-each select="tokenize($declaration-list, ';')[not(normalize-space(.)='')]">
                <xsl:sequence select="css:property(
                                        normalize-space(substring-before(.,':')),
                                        replace(substring-after(.,':'), '(^\s+|\s+$)', ''))"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:parse-content-list" as="element()*">
        <xsl:param name="content-list" as="xs:string?"/>
        <xsl:param name="context" as="element()?"/>
        <xsl:if test="$content-list">
            <xsl:analyze-string select="$content-list" regex="{$css:CONTENT_RE}" flags="x">
                <xsl:matching-substring>
                    <xsl:choose>
                        <!--
                            <string>
                        -->
                        <xsl:when test="regex-group(1)!=''">
                            <css:string value="{substring(regex-group(1), 2, string-length(regex-group(1))-2)}"/>
                        </xsl:when>
                        <!--
                            content()
                        -->
                        <xsl:when test="regex-group(2)!=''">
                            <css:content/>
                        </xsl:when>
                        <!--
                            attr(<name>)
                        -->
                        <xsl:when test="regex-group(3)!=''">
                            <css:attr name="{regex-group(4)}"/>
                        </xsl:when>
                        <!--
                            string(<ident>)
                        -->
                        <xsl:when test="regex-group(7)!=''">
                            <css:string name="{regex-group(8)}"/>
                        </xsl:when>
                        <!--
                            counter(<ident>,<counter-style>?)
                        -->
                        <xsl:when test="regex-group(11)!=''">
                            <xsl:element name="css:counter">
                                <xsl:attribute name="name" select="regex-group(12)"/>
                                <xsl:if test="regex-group(16)!=''">
                                    <xsl:attribute name="style" select="regex-group(16)"/>
                                </xsl:if>
                            </xsl:element>
                        </xsl:when>
                        <!--
                            target-text(<url>)
                        -->
                        <xsl:when test="regex-group(19)!=''">
                            <css:text target="{if (regex-group(21)!='')
                                               then substring(regex-group(21), 2, string-length(regex-group(21))-2)
                                               else string($context/@*[name()=regex-group(22)])}"/>
                        </xsl:when>
                        <!--
                            target-string(<url>,<ident>)
                        -->
                        <xsl:when test="regex-group(26)!=''">
                            <css:string target="{if (regex-group(28)!='')
                                                 then substring(regex-group(28), 2, string-length(regex-group(28))-2)
                                                 else string($context/@*[name()=regex-group(29)])}"
                                        name="{regex-group(33)}"/>
                        </xsl:when>
                        <!--
                            target-counter(<url>,<ident>,<counter-style>?)
                        -->
                        <xsl:when test="regex-group(36)!=''">
                            <xsl:element name="css:counter">
                                <xsl:attribute name="target" select="if (regex-group(38)!='')
                                                                     then substring(regex-group(38), 2, string-length(regex-group(38))-2)
                                                                     else string($context/@*[name()=regex-group(39)])"/>
                                <xsl:attribute name="name" select="regex-group(43)"/>
                                <xsl:if test="regex-group(47)!=''">
                                    <xsl:attribute name="style" select="regex-group(47)"/>
                                </xsl:if>
                            </xsl:element>
                        </xsl:when>
                        <!--
                            leader(<braille-string>)
                        -->
                        <xsl:when test="regex-group(50)!=''">
                            <css:leader pattern="{substring(regex-group(51), 2, string-length(regex-group(51))-2)}"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:parse-string-set" as="element()*">
        <xsl:param name="pairs" as="xs:string?"/>
        <!--
            force eager matching
        -->
        <xsl:variable name="regexp" select="concat($css:STRING_SET_PAIR_RE,'(\s*,|$)')"/>
        <xsl:if test="$pairs">
            <xsl:analyze-string select="$pairs" regex="{$regexp}" flags="x">
                <xsl:matching-substring>
                    <css:string-set name="{regex-group(1)}" value="{regex-group(4)}"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:parse-counter-set" as="element()*">
        <xsl:param name="pairs" as="xs:string?"/>
        <xsl:param name="initial" as="xs:integer"/>
        <xsl:if test="$pairs">
            <xsl:analyze-string select="$pairs" regex="{$css:COUNTER_SET_PAIR_RE}" flags="x">
                <xsl:matching-substring>
                    <css:counter-set name="{regex-group(1)}"
                                     value="{if (regex-group(5)!='') then regex-group(5) else format-number($initial,'0')}"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <!-- ===================================== -->
    <!-- Validating, inheriting and defaulting -->
    <!-- ===================================== -->
    
    <xsl:template match="css:property" mode="css:validate">
        <xsl:param name="validate" as="xs:boolean"/>
        <xsl:if test="not($validate) or css:is-valid(.)">
            <xsl:sequence select="."/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:property" mode="css:inherit">
        <xsl:param name="concretize-inherit" as="xs:boolean"/>
        <xsl:param name="concretize-initial" as="xs:boolean"/>
        <xsl:param name="validate" as="xs:boolean"/>
        <xsl:param name="context" as="element()"/>
        <xsl:choose>
            <xsl:when test="@value='inherit' and $concretize-inherit">
                <xsl:sequence select="if ($context/parent::*)
                                      then css:specified-properties(@name, true(), $concretize-initial, $validate, $context/parent::*)
                                      else css:property(@name, 'initial')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:property" mode="css:default">
        <xsl:param name="concretize-initial" as="xs:boolean"/>
        <xsl:choose>
            <xsl:when test="@value='initial' and $concretize-initial">
                <xsl:sequence select="css:property(@name, css:initial-value(@name))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="css:specified-properties" as="element()*">
        <xsl:param name="properties"/>
        <xsl:param name="concretize-inherit" as="xs:boolean"/>
        <xsl:param name="concretize-initial" as="xs:boolean"/>
        <xsl:param name="validate" as="xs:boolean"/>
        <xsl:param name="context" as="element()"/>
        <xsl:variable name="properties" as="xs:string*"
                      select="if ($properties instance of xs:string)
                              then tokenize(normalize-space($properties), ' ')
                              else $properties"/>
        <xsl:variable name="declarations" as="element()*">
            <xsl:apply-templates select="$context/@css:*[local-name()=$properties]" mode="css:attribute-as-property"/>
        </xsl:variable>
        <xsl:variable name="declarations" as="element()*"
            select="(css:parse-declaration-list(css:parse-stylesheet(
                       $context/@style)/self::css:rule[not(@selector)][last()]/@declaration-list),
                     $declarations)"/>
        <xsl:variable name="declarations" as="element()*"
            select="if ('#all'=$properties) then $declarations else $declarations[@name=$properties and not(@name='#all')]"/>
        <xsl:variable name="declarations" as="element()*">
            <xsl:apply-templates select="$declarations" mode="css:validate">
                <xsl:with-param name="validate" select="$validate"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="properties" as="xs:string*" select="$properties[not(.='#all')]"/>
        <xsl:variable name="properties" as="xs:string*"
            select="if ($validate) then $properties[.=$css:properties] else $properties"/>
        <xsl:variable name="declarations" as="element()*"
            select="(for $property in distinct-values($declarations/self::css:property/@name) return
                       $declarations/self::css:property[@name=$property][last()],
                     for $property in distinct-values($properties) return
                       if ($declarations/self::css:property[@name=$property]) then ()
                       else if (css:is-inherited($property)) then css:property($property, 'inherit')
                       else css:property($property, 'initial'))"/>
        <xsl:variable name="declarations" as="element()*">
            <xsl:apply-templates select="$declarations" mode="css:inherit">
                <xsl:with-param name="concretize-inherit" select="$concretize-inherit"/>
                <xsl:with-param name="concretize-initial" select="$concretize-initial"/>
                <xsl:with-param name="validate" select="$validate"/>
                <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:apply-templates select="$declarations" mode="css:default">
            <xsl:with-param name="concretize-initial" select="$concretize-initial"/>
        </xsl:apply-templates>
    </xsl:function>
    
    <!-- =========== -->
    <!-- Serializing -->
    <!-- =========== -->
    
    <xsl:template match="css:rule" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat(if (@selector) then concat(@selector, ' ') else '', '{ ', @declaration-list, ' }')"/>
    </xsl:template>
    
    <xsl:template match="css:property" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat(@name,': ',@value)"/>
    </xsl:template>
    
    <xsl:template match="css:string-set" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat(@name,' ',@value)"/>
    </xsl:template>
    
    <xsl:template match="css:counter-set" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat(@name,' ',@value)"/>
    </xsl:template>
    
    <xsl:template match="css:string[@value]" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('&quot;',@value,'&quot;')"/>
    </xsl:template>
    
    <xsl:template match="css:content" mode="css:serialize" as="xs:string">
        <xsl:sequence select="'content()'"/>
    </xsl:template>
    
    <xsl:template match="css:attr" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('attr(',@name,')')"/>
    </xsl:template>
    
    <xsl:template match="css:string[@name][not(@target)]" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('string(',@name,')')"/>
    </xsl:template>
    
    <xsl:template match="css:counter" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('counter(',@name,if (@style) then concat(', ', @style) else '',')')"/>
    </xsl:template>
    
    <xsl:template match="css:text[@target]" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('target-text(url(&quot;',@target,'&quot;))')"/>
    </xsl:template>
    
    <xsl:template match="css:string[@name][@target]" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('target-string(url(&quot;',@target,'&quot;), ',@name,')')"/>
    </xsl:template>
    
    <xsl:template match="css:counter[@target]" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('target-counter(url(&quot;',@target,'&quot;), ',@name,if (@style) then concat(', ', @style) else '',')')"/>
    </xsl:template>
    
    <xsl:template match="css:leader" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('leader(&quot;',@pattern,'&quot;)')"/>
    </xsl:template>
    
    <xsl:function name="css:serialize-stylesheet" as="xs:string">
        <xsl:param name="rules" as="element()*"/>
        <xsl:variable name="serialized-rules" as="xs:string*">
            <xsl:apply-templates select="$rules" mode="css:serialize"/>
        </xsl:variable>
        <xsl:sequence select="string-join($serialized-rules, ' ')"/>
    </xsl:function>
    
    <xsl:function name="css:serialize-declaration-list" as="xs:string">
        <xsl:param name="declarations" as="element()*"/>
        <xsl:variable name="serialized-declarations" as="xs:string*">
            <xsl:apply-templates select="$declarations" mode="css:serialize"/>
        </xsl:variable>
        <xsl:sequence select="string-join($serialized-declarations, '; ')"/>
    </xsl:function>
    
    <xsl:function name="css:serialize-content-list" as="xs:string">
        <xsl:param name="components" as="element()*"/>
        <xsl:variable name="serialized-components" as="xs:string*">
            <xsl:apply-templates select="$components" mode="css:serialize"/>
        </xsl:variable>
        <xsl:sequence select="string-join($serialized-components, ' ')"/>
    </xsl:function>
    
    <xsl:function name="css:serialize-string-set" as="xs:string">
        <xsl:param name="pairs" as="element()*"/>
        <xsl:variable name="serialized-pairs" as="xs:string*">
            <xsl:apply-templates select="$pairs" mode="css:serialize"/>
        </xsl:variable>
        <xsl:sequence select="string-join($serialized-pairs, ', ')"/>
    </xsl:function>
    
    <xsl:function name="css:serialize-counter-set" as="xs:string">
        <xsl:param name="pairs" as="element()*"/>
        <xsl:variable name="serialized-pairs" as="xs:string*">
            <xsl:apply-templates select="$pairs" mode="css:serialize"/>
        </xsl:variable>
        <xsl:sequence select="string-join($serialized-pairs, ' ')"/>
    </xsl:function>
    
    <xsl:function name="css:style-attribute" as="attribute()?">
        <xsl:param name="style" as="xs:string?"/>
        <xsl:if test="$style and $style!=''">
            <xsl:attribute name="style" select="$style"/>
        </xsl:if>
    </xsl:function>
    
    <!-- ========== -->
    <!-- Evaluating -->
    <!-- ========== -->
    
    <xsl:template match="css:string[@value]" mode="css:eval" as="xs:string">
        <xsl:sequence select="string(@value)"/>
    </xsl:template>
    
    <xsl:template match="css:content" mode="css:eval">
        <xsl:param name="context" as="element()?" select="()" tunnel="yes"/>
        <xsl:if test="$context">
            <xsl:sequence select="$context/child::node()"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:attr" mode="css:eval" as="xs:string?">
        <xsl:param name="context" as="element()?" select="()" tunnel="yes"/>
        <xsl:if test="$context">
            <xsl:variable name="name" select="string(@name)"/>
            <xsl:sequence select="string($context/@*[name()=$name])"/>
        </xsl:if>
    </xsl:template>
    
    <!-- ======= -->
    <!-- Strings -->
    <!-- ======= -->
    
    <xsl:function name="css:string" as="element()*">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="context" as="element()"/>
        <xsl:variable name="last-set" as="element()?"
                      select="$context/(self::*|preceding::*|ancestor::*)
                              [contains(@css:string-set,$name) or contains(@css:string-entry,$name)]
                              [last()]"/>
        <xsl:if test="$last-set">
            <xsl:variable name="value" as="xs:string?"
                          select="(css:parse-string-set($last-set/@css:string-entry),
                                   css:parse-string-set($last-set/@css:string-set))
                                  [@name=$name][last()]/@value"/>
            <xsl:sequence select="if ($value) then css:parse-content-list($value, $context)
                                  else css:string($name, $last-set/(preceding::*|ancestor::*)[last()])"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>
