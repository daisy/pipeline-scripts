<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:include href="library.xsl"/>
    
    <!--
        don't unwrap root
    -->
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:apply-templates select="*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:param name="pending-properties" as="element()*" select="()" tunnel="yes"/>
        <xsl:variable name="specified-properties" as="element()*" select="css:parse-declaration-list(@style)"/>
        <!--
            because elements are unwrapped, inherit must be concretized
        -->
        <xsl:variable name="computed-properties" as="element()*"
                      select="for $p in distinct-values(($pending-properties/@name,$specified-properties/@name))
                              return if ((not($specified-properties[@name=$p]) and css:is-inherited($p))
                                          or $specified-properties[@name=$p][@value='inherit'])
                                     then $pending-properties[@name=$p][last()]
                                     else $specified-properties[@name=$p][last()]"/>
        <xsl:choose>
            <xsl:when test="not(self::css:box[@type='block'])
                            and descendant::css:box[@type='block']">
                <xsl:choose>
                    <xsl:when test="@css:*">
                        <xsl:element name="css:_">
                            <xsl:sequence select="@css:*"/>
                            <xsl:call-template name="apply-templates">
                                <xsl:with-param name="pending-properties" select="$computed-properties" tunnel="yes"/>
                            </xsl:call-template>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="apply-templates">
                            <xsl:with-param name="pending-properties" select="$computed-properties" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:sequence select="@* except @style"/>
                    <xsl:sequence select="css:style-attribute(css:serialize-declaration-list($computed-properties))"/>
                    <xsl:call-template name="apply-templates">
                        <xsl:with-param name="parent" select="." tunnel="yes"/>
                        <xsl:with-param name="pending-properties" select="()" tunnel="yes"/>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="apply-templates">
        <xsl:param name="parent" as="element()?" select="()" tunnel="yes"/>
        <xsl:for-each-group select="*|text()" group-adjacent="boolean(descendant-or-self::css:box)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:for-each select="current-group()">
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="matches(string-join(current-group()/string(.), ''), '^[\s&#x2800;]*$')
                                and not(current-group()/descendant-or-self::css:white-space or
                                current-group()/descendant-or-self::css:string-fn or
                                current-group()/descendant-or-self::css:counter-fn or
                                current-group()/descendant-or-self::css:target-text-fn or
                                current-group()/descendant-or-self::css:target-string-fn or
                                current-group()/descendant-or-self::css:target-counter-fn or
                                current-group()/descendant-or-self::css:leader-fn)">
                    <xsl:sequence select="current-group()"/>
                </xsl:when>
                <xsl:when test="$parent/self::css:box[@type='inline']">
                    <xsl:sequence select="current-group()"/>
                </xsl:when>
                <xsl:otherwise>
                    <css:box type="inline">
                        <xsl:sequence select="current-group()"/>
                    </css:box>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:sequence select="."/>
    </xsl:template>
    
</xsl:stylesheet>
