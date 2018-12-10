<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns="" xpath-default-namespace=""
                exclude-result-prefixes="#all">
    
    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl"/>
    
    <!--
        the smil
    -->
    <xsl:variable name="smil" select="collection()[1]/*"/>
    <!--
        the corresponding content document(s) in spine order
    -->
    <xsl:variable name="html" select="collection()[position()&gt;1]/*"/>

    <xsl:template match="/smil/body/seq">
        <xsl:variable name="missing-pars" as="element()*">
            <xsl:for-each select="$html//*[self::html:h1 or
                                           self::html:h2 or
                                           self::html:h3 or
                                           self::html:h4 or
                                           self::html:h5 or
                                           self::html:h6]">
                <xsl:variable name="id" as="xs:string" select="@id"/>
                <xsl:variable name="base-uri" select="base-uri(root()/*)"/>
                <xsl:if test="not(exists($smil//par[text/resolve-uri(@src,base-uri())=concat($base-uri,'#',$id)]))">
                    <par id="par_{$id}">
                        <text src="{pf:relativize-uri(concat($base-uri,'#',$id),base-uri($smil))}"/>
                    </par>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="(par,$missing-pars)">
                <xsl:sort select="index-of($html[base-uri(.)=resolve-uri(substring-before(current()/text/@src,'#'),base-uri(.))],$html)"/>
                <xsl:sort select="$html[base-uri(.)=resolve-uri(substring-before(current()/text/@src,'#'),base-uri(.))]
                                  //*[@id=substring-after(current()/text/@src,'#')][1]/count(preceding::*|ancestor::*)"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
