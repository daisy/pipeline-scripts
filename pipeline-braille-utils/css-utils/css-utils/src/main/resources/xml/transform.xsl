<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:re="regex-utils"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:import href="query.xsl"/>
    
    <!-- ================= -->
    <!-- Text Transforming -->
    <!-- ================= -->
    
    <!--
        <text-transform> = 'translator' <query> | <ident> <args>
        where <args> = <any> *
        # groups: 31
        $1: <query>
        $21: <ident>
        $24: <args>
    -->
    <xsl:variable name="css:TRANSFORM_RE" select="concat('translator\s+(',$css:QUERY_RE,')|(',$css:IDENT_RE,')((\s+(',$css:ANY_RE,'))*)')"/>
    
    <xsl:function name="css:parse-text-transform" as="element()*">
        <xsl:param name="text-transform" as="xs:string"/>
        <xsl:analyze-string select="$text-transform" regex="{re:exact($css:TRANSFORM_RE)}">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="regex-group(1)!=''">
                        <css:ident value="translator"/>
                        <css:query value="{regex-group(1)}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <css:ident value="{regex-group(21)}"/>
                        <xsl:analyze-string select="regex-group(24)" regex="{$css:ANY_RE}">
                            <xsl:matching-substring>
                                <xsl:choose>
                                    <xsl:when test="regex-group(1)!=''">
                                        <css:ident value="{regex-group(1)}"/>
                                    </xsl:when>
                                    <xsl:when test="regex-group(4)!=''">
                                        <css:string value="{substring(regex-group(4), 2, string-length(regex-group(4))-2)}"/>
                                    </xsl:when>
                                    <xsl:when test="regex-group(5)!=''">
                                        <css:integer value="{regex-group(5)}"/>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:template match="text()" mode="css:text-transform">
        <xsl:sequence select="."/>
    </xsl:template>
    
</xsl:stylesheet>
