<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:re="regex-utils"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- ====== -->
    <!-- Syntax -->
    <!-- ====== -->
    
    <xsl:import href="regex-utils.xsl"/>
    
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
        <identifier>
        # groups: 2
    -->
    <xsl:variable name="css:IDENT_RE" select="'(\p{L}|_)(\p{L}|_|-)*'"/>
    
    <!--
        # groups: 5
    -->
    <xsl:variable name="css:IDENT_LIST_RE" select="re:space-separated($css:IDENT_RE)"/>
    
    <!--
        <integer>
        # groups: 2
    -->
    <xsl:variable name="css:INTEGER_RE" select="'(0|-?[1-9][0-9]*)(\.0*)?'"/>
    
    <!--
        non-negative <integer>
        # groups: 2
    -->
    <xsl:variable name="css:NON_NEGATIVE_INTEGER_RE" select="'(0|[1-9][0-9]*)(\.0*)?'"/>
    
    <!--
        <string>
        # groups: 0
    -->
    <xsl:variable name="css:STRING_RE">'.*?'|".*?"</xsl:variable>
    
    <!--
        content()
        # groups: 0
    -->
    <xsl:variable name="css:CONTENT_FN_RE" select="'content\(\)'"/>
    
    <!--
        attr(<name>)
        # groups: 4
        $1: <name>
    -->
    <xsl:variable name="css:ATTR_FN_RE" select="concat('attr\(\s*(',$css:IDENT_RE,')(\s+url)?\s*\)')"/>
    
    <!--
        string(<identifier>)
        # groups: 3
        $1: <identifier>
    -->
    <xsl:variable name="css:STRING_FN_RE" select="concat('string\(\s*(',$css:IDENT_RE,')\s*\)')"/>
    
    <!--
        counter(<identifier>,<style>?)
        # groups: 7
        $1: <identifier>
        $5: <style>
    -->
    <xsl:variable name="css:COUNTER_FN_RE" select="concat('counter\(\s*(',$css:IDENT_RE,')\s*(,\s*(',$css:IDENT_RE,')\s*)?\)')"/>
    
    <!--
        target-text(<target>)
        # groups: 5
        $1: <target>
    -->
    <xsl:variable name="css:TARGET_TEXT_FN_RE" select="concat('target-text\(\s*(',$css:ATTR_FN_RE,')\s*\)')"/>
    
    <!--
        target-string(<target>,<identifier>)
        # groups: 8
        $1: <target>
        $6: <identifier>
    -->
    <xsl:variable name="css:TARGET_STRING_FN_RE" select="concat('target-string\(\s*(',$css:ATTR_FN_RE,')\s*,\s*(',$css:IDENT_RE,')\s*\)')"/>
    
    <!--
        target-counter(<target>,<identifier>)
        # groups: 8
        $1: <target>
        $6: <identifier>
    -->
    <xsl:variable name="css:TARGET_COUNTER_FN_RE" select="concat('target-counter\(\s*(',$css:ATTR_FN_RE,')\s*,\s*(',$css:IDENT_RE,')\s*\)')"/>
    
    <!--
        leader(<pattern>)
        # groups: 1
        $1: <pattern>
    -->
    <xsl:variable name="css:LEADER_FN_RE" select="concat('leader\(\s*(',$css:BRAILLE_STRING_RE,')\s*\)')"/>
    
    <!--
        # groups: 46
        $1: <string>
        $2: content()
        $3: attr(<name>)
        $4:      <name>
        $8: string(<identifier>)
        $9:        <identifier>
        $12: counter(<identifier>,<style>?)
        $13:         <identifier>
        $17:                      <style>
        $20: target-text(<target>)
        $21:             <target>
        $26: target-string(<target>,<identifier>)
        $27:               <target>
        $32:                        <identifier>
        $35: target-counter(<target>,<identifier>)
        $36:                <target>
        $41:                         <identifier>
        $44: leader(<pattern>)
        $45:        <pattern>
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
    
    <xsl:variable name="css:CONTENT_LIST_RE" select="re:space-separated($css:CONTENT_RE)"/>
    
    <!--
        # groups: 2
    -->
    <xsl:variable name="css:DECLARATION_LIST_RE">([^'"\{\}]+|'.+?'|".+?"|\{([^'"\{\}]+|'.+?'|".+?")*\})*</xsl:variable>
    
    <!--
        # groups: 7
        $2: selector
        $6: declaration list
    -->
    <xsl:variable name="css:RULE_RE" select="re:concat(('(((@|::)',$css:IDENT_RE,')\s+)?\{(',$css:DECLARATION_LIST_RE, ')\}'))"/>
    
    <!-- ======= -->
    <!-- Parsing -->
    <!-- ======= -->
    
    <xsl:function name="css:property">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="$value instance of xs:integer">
                <css:property name="{$name}" value="{format-number($value, '0.0')}"/>
            </xsl:when>
            <xsl:otherwise>
                <css:property name="{$name}" value="{$value}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="css:parse-stylesheet" as="element()*">
        <xsl:param name="stylesheet" as="xs:string?"/>
        <xsl:if test="$stylesheet">
            <xsl:variable name="rules" as="element()*">
                <xsl:analyze-string select="$stylesheet" regex="{$css:RULE_RE}">
                    <xsl:matching-substring>
                        <xsl:element name="css:rule">
                            <xsl:if test="regex-group(1)!=''">
                                <xsl:attribute name="selector" select="regex-group(2)"/>
                            </xsl:if>
                            <xsl:attribute name="declaration-list" select="replace(regex-group(6), '(^\s+|\s+$)', '')"/>
                        </xsl:element>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="exists($rules)">
                    <xsl:sequence select="$rules"/>
                </xsl:when>
                <xsl:otherwise>
                    <css:rule declaration-list="{$stylesheet}"/>
                </xsl:otherwise>
            </xsl:choose>
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
    
    <xsl:function name="css:parse-content-list">
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
                            <css:content-fn/>
                        </xsl:when>
                        <!--
                            attr(<name>)
                        -->
                        <xsl:when test="regex-group(3)!=''">
                            <css:attr-fn name="{regex-group(4)}"/>
                        </xsl:when>
                        <!--
                            string(<identifier>)
                        -->
                        <xsl:when test="regex-group(8)!=''">
                            <css:string-fn identifier="{regex-group(9)}"/>
                        </xsl:when>
                        <!--
                            counter(<identifier>,<style>?)
                        -->
                        <xsl:when test="regex-group(12)!=''">
                            <xsl:element name="css:counter-fn">
                                <xsl:attribute name="identifier" select="regex-group(13)"/>
                                <xsl:if test="regex-group(17)!=''">
                                    <xsl:attribute name="style" select="regex-group(17)"/>
                                </xsl:if>
                            </xsl:element>
                        </xsl:when>
                        <!--
                            target-text(<target>)
                        -->
                        <xsl:when test="regex-group(20)!=''">
                            <css:target-text-fn target="{string($context/@*[name()=regex-group(22)])}"/>
                        </xsl:when>
                        <!--
                            target-string(<target>,<identifier>)
                        -->
                        <xsl:when test="regex-group(26)!=''">
                            <css:target-string-fn target="{string($context/@*[name()=regex-group(28)])}"
                                                  identifier="{regex-group(32)}"/>
                        </xsl:when>
                        <!--
                            target-counter(<target>,<identifier>)
                        -->
                        <xsl:when test="regex-group(35)!=''">
                            <css:target-counter-fn target="{string($context/@*[name()=regex-group(37)])}"
                                                   identifier="{regex-group(41)}"/>
                        </xsl:when>
                        <!--
                            leader(<pattern>)
                        -->
                        <xsl:when test="regex-group(44)!=''">
                            <css:leader-fn pattern="{substring(regex-group(45), 2, string-length(regex-group(45))-2)}"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <!-- ===================================== -->
    <!-- Validating, inheriting and defaulting -->
    <!-- ===================================== -->
    
    <xsl:template match="css:property" mode="css:validate">
        <xsl:param name="validate" as="xs:boolean"/>
        <xsl:if test="not($validate) or css:is-valid(@name, @value)">
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
        <xsl:variable name="declarations" as="element()*"
            select="css:parse-declaration-list(css:parse-stylesheet(
                      $context/@style)/self::css:rule[not(@selector)][1]/@declaration-list)"/>
        <xsl:variable name="declarations" as="element()*"
            select="if ('#all'=$properties) then $declarations else $declarations[@name=$properties and not(@name='#all')]"/>
        <xsl:variable name="declarations" as="element()*">
            <xsl:apply-templates select="$declarations" mode="css:validate">
                <xsl:with-param name="validate" select="$validate"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="properties" as="xs:string*" select="$properties[not(.='#all')]"/>
        <xsl:variable name="properties" as="xs:string*"
            select="if ($validate) then $properties[css:is-property(.)] else $properties"/>
        <xsl:variable name="declarations" as="element()*"
            select="(for $property in distinct-values($declarations/self::css:property/@name) return
                       $declarations/self::css:property[@name=$property][1],
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
    
    <xsl:template match="css:string" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('&quot;',@value,'&quot;')"/>
    </xsl:template>
    
    <xsl:template match="css:content-fn" mode="css:serialize" as="xs:string">
        <xsl:sequence select="'content()'"/>
    </xsl:template>
    
    <xsl:template match="css:attr-fn" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('attr(',@name,')')"/>
    </xsl:template>
    
    <xsl:template match="css:string-fn" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('string(',@identifier,')')"/>
    </xsl:template>
    
    <xsl:template match="css:counter-fn" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('counter(',@identifier,if (@style) then concat(', ', @style) else '',')')"/>
    </xsl:template>
    
    <xsl:template match="css:target-text-fn" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('target-text(',@target,')')"/>
    </xsl:template>
    
    <xsl:template match="css:target-string-fn" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('target-string(',@target,', ',@identifier,')')"/>
    </xsl:template>
    
    <xsl:template match="css:target-counter-fn" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('target-counter(',@target,', ',@identifier,')')"/>
    </xsl:template>
    
    <xsl:template match="css:leader-fn" mode="css:serialize" as="xs:string">
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
    
    <xsl:function name="css:style-attribute" as="attribute()?">
        <xsl:param name="style" as="xs:string"/>
        <xsl:if test="$style!=''">
            <xsl:attribute name="style" select="$style"/>
        </xsl:if>
    </xsl:function>
    
    <!-- ========== -->
    <!-- Evaluating -->
    <!-- ========== -->
    
    <xsl:template match="css:string" mode="css:eval" as="xs:string">
        <xsl:sequence select="string(@value)"/>
    </xsl:template>
    
    <xsl:template match="css:content-fn" mode="css:eval">
        <xsl:param name="context" as="element()?" select="()" tunnel="yes"/>
        <xsl:if test="$context">
            <xsl:sequence select="$context/child::node()"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:attr-fn" mode="css:eval" as="xs:string?">
        <xsl:param name="context" as="element()?" select="()" tunnel="yes"/>
        <xsl:if test="$context">
            <xsl:variable name="name" select="string(@name)"/>
            <xsl:sequence select="string($context/@*[name()=$name])"/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
