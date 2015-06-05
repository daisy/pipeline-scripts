<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:re="regex-utils"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <!-- ============ -->
    <!-- Query Syntax -->
    <!-- ============ -->
    
    <!--
        <any> = [ <ident> | <string> | <integer> ]
        # groups: 5
        $1: <ident>
        $4: <string>
        $5: <integer>
    -->
    <xsl:variable name="css:ANY_RE" select="re:or(($css:IDENT_RE,$css:STRING_RE,$css:INTEGER_RE))"/>
    
    <!--
        <feature> = '(' <ident> [ ':' <value> ]? ')'
        where <value> = <any> +
        # groups: 18
        $1: <ident>
        $5: <value>
    -->
    <xsl:variable name="css:FEATURE_RE" select="concat('\(\s*(',$css:IDENT_RE,')(\s*:\s*(',re:space-separated($css:ANY_RE),'))?\s*\)')"/>
    
    <!--
        <query> = <feature> +
        # groups: 19
    -->
    <xsl:variable name="css:QUERY_RE" select="concat('(',$css:FEATURE_RE,'\s*)+')"/>
    
</xsl:stylesheet>
