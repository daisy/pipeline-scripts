<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:louis="http://liblouis.org/liblouis">
    
    <xsl:template match="louis:semantics|louis:styles|louis:page-layout">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:sequence select="@*"/>
            <xsl:variable name="preserve_space" as="xs:boolean" select="ancestor-or-self::*[@xml:space][1]/@xml:space='preserve'"/>
            <xsl:for-each-group select="*|text()" group-adjacent="boolean(self::*[@louis:style])">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <xsl:for-each select="current-group()">
                            <xsl:apply-templates select="."/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <!--
                                if text is only whitespace for indentation, leave it
                            -->
                            <xsl:when test="not($preserve_space) and
                                            not(current-group()/self::*) and
                                            pxi:whitespace-only(pxi:group-as-string(current-group()))">
                                <xsl:sequence select="current-group()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="content" as="node()*">
                                    <xsl:for-each-group select="current-group()" group-adjacent="boolean(self::*)">
                                        <xsl:choose>
                                            <xsl:when test="current-grouping-key()">
                                                <xsl:for-each select="current-group()">
                                                    <xsl:apply-templates select="."/>
                                                </xsl:for-each>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <!--
                                                    NOTE: liblouisutdml trims leading/trailing spaces
                                                -->
                                                <xsl:choose>
                                                    <xsl:when test="$preserve_space">
                                                        <xsl:analyze-string select="pxi:group-as-string(current-group())" regex="\n">
                                                            <xsl:matching-substring>
                                                                <!--
                                                                    (hack) because liblouisutdml doesn't want to start with a line-break
                                                                -->
                                                                <xsl:if test="position()=1">
                                                                    <xsl:value-of select="'&#xA0;'"/>
                                                                </xsl:if>
                                                                <xsl:element name="louis:line-break"/>
                                                            </xsl:matching-substring>
                                                            <xsl:non-matching-substring>
                                                                <xsl:value-of select="replace(., '^[\s&#x2800;]|[\s&#x2800;]$', '&#xA0;')"/>
                                                            </xsl:non-matching-substring>
                                                        </xsl:analyze-string>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="pxi:squeeze(pxi:group-as-string(current-group()))"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each-group>
                                </xsl:variable>
                                <!--
                                    wrap in a louis:block if a block follows
                                -->
                                <xsl:choose>
                                    <xsl:when test="last() > position()">
                                        <xsl:element name="louis:block">
                                            <xsl:sequence select="$content"/>
                                        </xsl:element>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="$content"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="pxi:group-as-string" as="xs:string">
        <xsl:param name="group"/>
        <xsl:sequence select="string-join($group/string(.), '')"/>
    </xsl:function>
    
    <xsl:function name="pxi:squeeze" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="replace($string, '[\s&#x2800;]+', ' ')"/>
    </xsl:function>
    
    <xsl:function name="pxi:whitespace-only" as="xs:boolean">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="normalize-space(pxi:squeeze($string))=''"/>
    </xsl:function>
    
</xsl:stylesheet>
