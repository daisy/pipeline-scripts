<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions">

    <xsl:output indent="yes"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*/*[1]"/>

    <xsl:template match="*[local-name()='text'][tokenize(@src,'#')[last()]=/*/*[1]/descendant::*/@id]">
        <xsl:variable name="fragment" select="tokenize(@src,'#')[last()]"/>
        <xsl:variable name="mapping" select="(/*/*[1]/descendant::*[@id=$fragment])[1]"/>
        <xsl:variable name="new-href" select="f:relative-to(tokenize(replace($mapping/@from,'[^/]+$',''),'/+'),tokenize($mapping/@to,'/+'),'')"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="src" select="concat($new-href,'#',$fragment)"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="f:relative-to">
        <!-- TODO: copied from create-package-doc.fileset-to-manifest.xsl; should place f:relative-to in for instance file-utils to avoid code duplication -->
        <xsl:param name="from"/>
        <xsl:param name="to"/>
        <xsl:param name="relation"/>
        
        <xsl:choose>
            <xsl:when test="count($to) &lt;= 1 and count($from) = 0">
                <xsl:value-of select="concat($relation,$to)"/>
            </xsl:when>
            <xsl:when test="string-length($relation) &gt; 0">
                <xsl:value-of
                    select="f:relative-to(subsequence($from,2), subsequence($to,min((count($to),2))), concat(
                       if (count($from) and string-length($from[1])) then '../' else '',
                       $relation,
                       if (count($to) &gt; 1 and string-length($to[1])) then concat($to[1],'/') else ''
                    ))"
                />
            </xsl:when>
            <xsl:when test="count($to) &gt; 1 and $to[1]=$from[1]">
                <xsl:value-of select="f:relative-to(subsequence($from,2), subsequence($to,min((count($to),2))), '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="f:relative-to(subsequence($from,2), subsequence($to,min((count($to),2))), concat(
                       if (count($from) and string-length($from[1])) then '../' else '',
                       if (count($to) &gt; 1 and string-length($to[1])) then concat($to[1],'/') else ''
                    ))"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
