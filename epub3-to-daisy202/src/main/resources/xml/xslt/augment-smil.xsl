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
    
    <xsl:variable name="smil-base-uri" select="base-uri($smil)"/>
    
    <xsl:key name="absolute-id" match="*[@id]" use="concat(base-uri(root()/*),'#',@id)"/>
    
    <xsl:variable name="referenced-html-elements" as="element()*">
        <xsl:for-each select="//text">
            <xsl:variable name="absolute-src" select="resolve-uri(@src,$smil-base-uri)"/>
            <xsl:variable name="referenced-element" as="element()*" select="$html/key('absolute-id',$absolute-src)"/>
            <xsl:if test="count($referenced-element)=0">
                <xsl:message terminate="yes"
                             select="concat('SMIL &quot;',replace($smil-base-uri,'^.*/([^/]+)^','$1'),
                                            '&quot; references a non-existing element &quot;',$absolute-src,'&quot;')"/>
            </xsl:if>
            <xsl:if test="count($referenced-element)&gt;1">
                <xsl:message terminate="yes"
                             select="concat('Reference &quot;',@src,'&quot; in SMIL &quot;',
                                            replace($smil-base-uri,'^.*/([^/]+)^','$1'),'&quot; is ambiguous')"/>
            </xsl:if>
            <xsl:sequence select="$referenced-element"/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template match="/smil/body/seq">
        <xsl:variable name="missing-pars" as="element()*">
            <xsl:for-each select="$html">
                <xsl:variable name="html-base-uri" select="base-uri(.)"/>
                <xsl:for-each select="//*[self::html:h1 or
                                          self::html:h2 or
                                          self::html:h3 or
                                          self::html:h4 or
                                          self::html:h5 or
                                          self::html:h6 or
                                          self::html:span[matches(@class,'(^|\s)page-(front|normal|special)(\s|$)')]]">
                    <xsl:variable name="id" as="xs:string" select="@id"/>
                    <xsl:variable name="absolute-id" select="concat($html-base-uri,'#',$id)"/>
                    <xsl:choose>
                        <xsl:when test="$referenced-html-elements intersect .">
                            <!-- The SMIL already references the element. No need to do anything. -->
                        </xsl:when>
                        <xsl:when test="$referenced-html-elements/ancestor::* intersect .">
                            <!--
                                The SMIL already references a containing element. FIXME: Unlikely to
                                happen for headings, but less unlikely for page numbers.
                            -->
                            <xsl:message terminate="yes">FIXME</xsl:message>
                        </xsl:when>
                        <xsl:when test="$referenced-html-elements/descendant::* intersect .">
                            <!--
                                The SMIL already references a contained element. Happens if the
                                granularity is too fine, e.g. for word-level synchronization.
                                FIXME: Merge all the segments into a single par.
                            -->
                            <xsl:message terminate="yes">FIXME</xsl:message>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- in case there are multiple html files and colliding ids, add a suffix -->
                            <xsl:variable name="par-id" as="xs:string"
                                          select="concat(
                                                    'par_',$id,
                                                    if (
                                                      count(
                                                        $html//*[self::html:h1 or self::html:h2 or
                                                                 self::html:h3 or self::html:h4 or
                                                                 self::html:h5 or self::html:h6 or
                                                                 self::html:span[
                                                                   matches(@class,'(^|\s)page-(front|normal|special)(\s|$)')]]
                                                                [@id=$id]
                                                      )&gt;1
                                                    ) then concat('_',generate-id(.))
                                                      else '')"/>
                            <par id="{$par-id}">
                                <text src="{pf:relativize-uri(concat($html-base-uri,'#',$id),$smil-base-uri)}"/>
                            </par>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
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
