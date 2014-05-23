<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:html="http://www.w3.org/1999/xhtml">

    <xsl:template match="/*">
        <d:messages>
            <xsl:for-each select="*">
                <xsl:apply-templates select="*">
                    <xsl:with-param name="base-uri" select="base-uri(.)" tunnel="yes"/>
                    <xsl:with-param name="fileset" select="/*/*[1]" tunnel="yes"/>
                    <xsl:with-param name="xml-documents" select="/*/*[position() &gt; 1]" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </d:messages>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:apply-templates select="@*|*"/>
    </xsl:template>

    <xsl:template
        match="html:*[@href]/@href | html:*[@src]/@src | html:*[@cite]/@cite | html:*[@longdesc]/@longdesc | html:object[@data]/@data | html:form[@action]/@action | html:head[@profile]/@profile">
        <xsl:param name="base-uri" tunnel="yes"/>
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:param name="xml-documents" tunnel="yes"/>

        <xsl:variable name="uri" select="resolve-uri(tokenize(string(.),'#')[1],$base-uri)"/>
        <xsl:variable name="fragment" select="tokenize(string(.),'#')[2]"/>

        <xsl:choose>
            <xsl:when test=".=''">
                <d:message severity="error">
                    <d:desc>The reference in the attribute "<xsl:value-of select="name()"/>" at <xsl:value-of
                            select="concat('/',string-join(for $e in (ancestor-or-self::*) return concat($e/name(),'[',(count($e/preceding-sibling::*[name()=$e/name()])+1),']'),'/'))"/> is
                        empty.</d:desc>
                    <d:file>
                        <xsl:value-of select="$base-uri"/>
                    </d:file>
                    <d:was>
                        <xsl:value-of select="string(.)"/>
                    </d:was>
                </d:message>
            </xsl:when>
            <xsl:when test="matches(.,'^\w+:') and not(starts-with(.,'file:'))">
                <xsl:message select="concat('reference to external resource skipped: ',.)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="not($fileset/d:file/resolve-uri(@href,base-uri(.)) = $uri)">
                        <d:message severity="error">
                            <d:desc>The reference in the attribute "<xsl:value-of select="name()"/>" at <xsl:value-of
                                    select="concat('/',string-join(for $e in (ancestor-or-self::*) return concat($e/name(),'[',(count($e/preceding-sibling::*[name()=$e/name()])+1),']'),'/'))"/> points
                                to a resource that is not included in the DAISY 2.02 fileset.</d:desc>
                            <d:file>
                                <xsl:value-of select="$base-uri"/>
                            </d:file>
                            <d:was>
                                <xsl:value-of select="string(.)"/>
                            </d:was>
                        </d:message>
                    </xsl:when>
                    <xsl:when test="$fragment and not($xml-documents[base-uri()=$uri]//@id=$fragment)">
                        <d:message severity="error">
                            <d:desc>The reference in the attribute "<xsl:value-of select="name()"/>" at <xsl:value-of
                                    select="concat('/',string-join(for $e in (ancestor-or-self::*) return concat($e/name(),'[',(count($e/preceding-sibling::*[name()=$e/name()])+1),']'),'/'))"/> points
                                to a id in the target resource that does not exist.</d:desc>
                            <d:file>
                                <xsl:value-of select="$base-uri"/>
                            </d:file>
                            <d:was>
                                <xsl:value-of select="string(.)"/>
                            </d:was>
                        </d:message>
                    </xsl:when>
                    <xsl:when
                        test="$fragment and $fileset/d:file[resolve-uri(@href,base-uri(.))=$uri]/@media-type = 'application/smil+xml' and not($xml-documents[base-uri(.)=$uri]//*[@id=$fragment]/local-name()=('par','text'))">
                        <d:message severity="error">
                            <d:desc>The reference in the attribute "<xsl:value-of select="name()"/>" at <xsl:value-of
                                    select="concat('/',string-join(for $e in (ancestor-or-self::*) return concat($e/name(),'[',(count($e/preceding-sibling::*[name()=$e/name()])+1),']'),'/'))"/> points
                                to an element in a SMIL-file which is neither a "par" nor a "text" element.</d:desc>
                            <d:file>
                                <xsl:value-of select="$base-uri"/>
                            </d:file>
                            <d:was>
                                <xsl:value-of select="string(.)"/>
                            </d:was>
                        </d:message>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

        <!--
           // InterDocURICheckerD202Delegate
           for referer in fileset[xml- and html-files] {
               for reference in referer.references {
                   if !matches(reference, regex.URI_REMOTE) and !startsWith(reference, "#") {
                       path = reference.stripFragment()
                       fragment = reference.getFragment()
                       uri = resolve-uri(base-uri(referer), path)
                       if uri is not in fileset {
                           concat('The URI ',reference,' points to a file that is not in included in the DAISY 2.02 fileset')
                       } else if fragment!='' {
                           if uri is SMIL {
                               if not(smil//text[@id=$fragment] or smil//par[@id=$fragment]) {
                                   concat('The URI ',reference,' does not resolve correctly')
                               }
                           } else {
                               if not(xml//@id=$fragment) then {
                                   concat('The URI ',reference,' does not resolve correctly')
                               }
                           }
                       }
                   }
               }
           }
           -->

    </xsl:template>

</xsl:stylesheet>
