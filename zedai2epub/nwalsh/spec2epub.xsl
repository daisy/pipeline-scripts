<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:f="http://nwalsh.com/ns/functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
		xmlns:trd="http://www.w3.org/2001/10/trdoc-data.xsl"
                exclude-result-prefixes="f h html xs ncx trd"
                version="2.0">

<!-- See http://norman.walsh.name/2010/06/09/epubxpl -->
<!-- Version 1.1 -->

<xsl:import href="http://www.w3.org/2001/10/trdoc-data.xsl"/>

<xsl:key name="id" match="h:a|*" use="@id"/>

<xsl:output method="xhtml" encoding="utf-8" indent="yes"
	    omit-xml-declaration="yes"/>

<xsl:param name="strict" select="'1'"/>
<xsl:param name="base" required="yes"/>
<xsl:param name="chunkdepth" select="2"/>

<!-- ============================================================ -->
<!-- Weird code to split the input document because XProc can't   -->
<!-- pass in structured parameters, more's the pity.              -->
<!-- ============================================================ -->

<xsl:variable name="xmlman" select="/doc/manifest"/>

<xsl:template match="/" mode="split">
  <xsl:variable name="html">
    <xsl:copy-of select="/doc/h:html"/>
  </xsl:variable>

  <xsl:apply-templates select="$html"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:variable name="baseuri"
              select="if (ends-with($xmlman/@xml:base, '/'))
                      then $xmlman/@xml:base
                      else replace($xmlman/@xml:base, '^(.*/)([^/]+)$', '$1')"/>
<xsl:variable name="intradoc" select="concat($baseuri,'#')"/>
<xsl:variable name="website" select="substring-before(substring-after($baseuri,'//'),'/')"/>

<xsl:variable name="coveruri" select="resolve-uri('cover.html', $baseuri)"/>
<xsl:variable name="coverpath" select="substring-after($coveruri,'//')"/>

<xsl:variable name="toc"  select="/h:html/h:body/h:div[@class='toc']"/>
<xsl:variable name="body" select="/h:html/h:body/h:div[@class='body']"/>
<xsl:variable name="back" select="/h:html/h:body/h:div[@class='back']"/>
<xsl:variable name="head" select="($body/preceding-sibling::*) except $toc"/>

<xsl:preserve-space elements="*"/>

<xsl:template match="/">
  <xsl:variable name="phase0" as="document-node()">
    <xsl:apply-templates select="/" mode="phase0"/>
  </xsl:variable>

  <xsl:result-document href="/tmp/phase0.html"
                       encoding="utf-8" indent="yes" method="xml">
    <xsl:copy-of select="$phase0"/>
  </xsl:result-document>

  <xsl:variable name="phase1" as="document-node()">
    <xsl:apply-templates select="$phase0" mode="phase1"/>
  </xsl:variable>

  <xsl:result-document href="/tmp/phase1.html"
                       encoding="utf-8" indent="yes" method="xml">
    <xsl:copy-of select="$phase1"/>
  </xsl:result-document>

  <xsl:variable name="phase2" as="document-node()">
    <xsl:apply-templates mode="phase2" select="$phase1"/>
  </xsl:variable>

  <xsl:result-document href="/tmp/phase2.html"
                       encoding="utf-8" indent="yes" method="xml">
    <xsl:copy-of select="$phase2"/>
  </xsl:result-document>

  <xsl:variable name="phase3" as="document-node()">
    <xsl:apply-templates mode="phase3" select="$phase2"/>
  </xsl:variable>

  <xsl:result-document href="/tmp/phase3.html"
                       encoding="utf-8" indent="yes" method="xml">
    <xsl:copy-of select="$phase3"/>
  </xsl:result-document>

  <xsl:result-document href="{resolve-uri(concat($website,'/toc.ncx'), $base)}"
                       encoding="utf-8" indent="yes" method="xml">
    <xsl:apply-templates select="$phase3" mode="ncxtoc"/>
  </xsl:result-document>

  <xsl:result-document href="{resolve-uri(concat($website,'/content.opf'), $base)}"
                       encoding="utf-8" indent="yes" method="xml">
    <xsl:apply-templates select="$phase3" mode="package"/>
  </xsl:result-document>

  <xsl:result-document href="{concat($base,$coverpath)}"
                       encoding="utf-8" indent="no" method="xhtml">
    <html>
      <head>
        <xsl:copy-of
            select="($phase3/h:html/h:head/h:script
                     |$phase3/h:html/h:head/h:style
                     |$phase3/h:html/h:head/h:link[@rel='stylesheet'])"/>
        <title>…</title>
      </head>
      <body>
        <div>
          <xsl:copy-of select="$phase3//h:div[@class='head']"/>
        </div>
      </body>
    </html>
  </xsl:result-document>

  <xsl:apply-templates select="$phase3" mode="chunks"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="/" mode="phase0">
  <xsl:copy>
    <xsl:apply-templates mode="phase0"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="*" mode="phase0">
  <xsl:variable name="this" select="."/>

  <xsl:copy>
    <xsl:for-each select="@*">
      <xsl:choose>
        <xsl:when test="name(.) = 'id' or ($this/self::h:a and name(.) = 'name')">
          <xsl:variable name="attr" select="name(.)"/>
          <xsl:variable name="n1" select="if (starts-with(.,':'))
                                          then concat('_',substring(.,2))
                                          else ."/>
          <xsl:variable name="n2" select="translate($n1, ' ', '_')"/>
          <xsl:attribute name="{$attr}" select="$n2"/>
        </xsl:when>

        <xsl:when test="name(.) = 'href' and starts-with(.,'#')">
          <xsl:variable name="n1" select="if (starts-with(.,'#:'))
                                          then concat('#_',substring(.,3))
                                          else ."/>
          <xsl:variable name="n2" select="translate($n1, ' ', '_')"/>
          <xsl:attribute name="href" select="$n2"/>
        </xsl:when>
        <xsl:when test="name(.) = 'lang'">
          <xsl:attribute name="xml:lang" select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:apply-templates mode="phase0"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()" mode="phase0">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="/" mode="phase1">
  <xsl:copy>
    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:div[@class='toc']" mode="phase1"/>

<xsl:template match="h:div" mode="phase1">
  <xsl:variable name="toc" as="xs:string?" select="f:toc(.)"/>
  <xsl:variable name="chunk" as="xs:string?" select="f:chunk(.)"/>

  <xsl:copy>
    <xsl:for-each select="@*">
      <xsl:choose>
        <xsl:when test="$strict = '0'">
          <xsl:copy/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="name(.) != 'align'">
            <xsl:copy/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:if test="not(empty($toc))">
      <xsl:attribute name="toc" select="$toc"/>
    </xsl:if>

    <xsl:if test="not(empty($chunk))">
      <xsl:attribute name="chunk" select="$chunk"/>
    </xsl:if>

    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:head/h:link[@href]" mode="phase1">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="href" select="resolve-uri(@href,$baseuri)"/>
    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:img[@src]" mode="phase1">
  <xsl:copy>
    <xsl:for-each select="@*">
      <xsl:choose>
        <xsl:when test="$strict = '0'">
          <xsl:copy/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="name(.) != 'border'">
            <xsl:copy/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:attribute name="src" select="resolve-uri(@src, $baseuri)"/>
    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:object[@data]" mode="phase1">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="data" select="resolve-uri(@data, $baseuri)"/>
    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:a" mode="phase1">
  <xsl:copy>
    <xsl:copy-of select="@*[not(name(.) = 'name') and not(name(.) = 'shape')]"/>
    <xsl:if test="@href">
      <xsl:attribute name="href" select="resolve-uri(@href, $baseuri)"/>
    </xsl:if>
    <xsl:if test="@name">
      <xsl:attribute name="id" select="@name"/>
    </xsl:if>
    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:map" mode="phase1">
  <xsl:copy>
    <xsl:copy-of select="@*[not(name(.) = 'name')]"/>
    <xsl:if test="@name">
      <xsl:attribute name="id" select="@name"/>
    </xsl:if>
    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:br[@clear]" mode="phase1">
  <xsl:copy>
    <xsl:copy-of select="@*[not(name(.) = 'clear')]"/>
    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:table" mode="phase1">
  <xsl:copy>
    <xsl:for-each select="@*">
      <xsl:choose>
        <xsl:when test="$strict = '0'">
          <xsl:copy/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="name(.) != 'bgcolor' and name(.) != 'align'">
            <xsl:copy/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:td|h:th" mode="phase1">
  <xsl:copy>
    <xsl:for-each select="@*">
      <xsl:choose>
        <xsl:when test="$strict = '0'">
          <xsl:copy/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="name(.) != 'width'">
            <xsl:copy/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:ul|h:ol" mode="phase1">
  <xsl:copy>
    <xsl:for-each select="@*">
      <xsl:choose>
        <xsl:when test="$strict = '0'">
          <xsl:copy/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="name(.) != 'type'">
            <xsl:copy/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:hr" mode="phase1">
  <xsl:copy>
    <xsl:for-each select="@*">
      <xsl:choose>
        <xsl:when test="$strict = '0'">
          <xsl:copy/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="name(.) != 'noshade' and name(.) != 'size'">
            <xsl:copy/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:font" mode="phase1">
  <xsl:choose>
    <xsl:when test="$strict = '0'">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="phase1"/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="phase1"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="phase1">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="phase1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()" mode="phase1">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="/" mode="phase2">
  <xsl:copy>
    <xsl:apply-templates mode="phase2"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:div" mode="phase2">
  <xsl:variable name="playOrder" as="xs:integer">
    <xsl:number from="/" count="h:div[@toc]" level="any"/>
  </xsl:variable>

  <xsl:copy>
    <xsl:copy-of select="@*"/>

    <xsl:if test="@toc">
      <xsl:attribute name="playOrder" select="$playOrder + 1"/>
    </xsl:if>

    <xsl:if test="@chunk">
      <xsl:attribute name="chunk"
                     select="concat(resolve-uri(generate-id(.), $baseuri),'.html')"/>
    </xsl:if>

    <xsl:apply-templates mode="phase2"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:a[@id]" mode="phase2">
  <xsl:variable name="target" select="key('id', @id)"/>

  <xsl:choose>
    <xsl:when test="count($target) &gt; 1 and not($target[1] is .)">
      <xsl:message>Suppressing duplicate ID: <xsl:value-of select="@id"/></xsl:message>

      <xsl:choose>
        <xsl:when test="count(@*) = 1">
          <xsl:apply-templates mode="phase2"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy>
            <xsl:copy-of select="@*[name(.) != 'id']"/>
            <xsl:apply-templates mode="phase2"/>
          </xsl:copy>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="phase2"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="phase2">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="phase2"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()" mode="phase2">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="/" mode="phase3">
  <xsl:copy>
    <xsl:apply-templates mode="phase3"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:head/h:link[@href and @rel='stylesheet']" mode="phase3">
  <xsl:choose>
    <xsl:when test="$xmlman/file[@uri=current()/@href]">
      <!--
      <xsl:message>RESOLVE LINK: <xsl:value-of select="@href"/></xsl:message>
      <xsl:message>        BASE: <xsl:value-of select="$baseuri"/></xsl:message>
      <xsl:message>       LOCAL: <xsl:value-of select="$xmlman/file[@uri=current()/@href]/@fn"/></xsl:message>
      <xsl:message>      RESULT: <xsl:value-of select="f:relative-to(substring-after($baseuri,'//'), $xmlman/file[@uri=current()/@href]/@fn)"/></xsl:message>
      -->

      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:attribute name="href"
                       select="f:relative-to(substring-after($baseuri,'//'), $xmlman/file[@uri=current()/@href]/@fn)"/>
        <xsl:apply-templates mode="phase3"/>
      </xsl:copy>

    </xsl:when>
    <xsl:otherwise>
      <!--
      <xsl:message>ABSOLUTE LINK: <xsl:value-of select="@href"/></xsl:message>
      -->
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="phase3"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="h:img[@src]" mode="phase3">
  <xsl:choose>
    <xsl:when test="$xmlman/file[@uri=current()/@src]">
      <!--
      <xsl:message>RESOLVE IMG: <xsl:value-of select="@src"/></xsl:message>
      <xsl:message>       BASE: <xsl:value-of select="$baseuri"/></xsl:message>
      <xsl:message>      LOCAL: <xsl:value-of select="$xmlman/file[@uri=current()/@src]/@fn"/></xsl:message>
      <xsl:message>     RESULT: <xsl:value-of select="f:resolve-link($baseuri,$xmlman/file[@uri=current()/@src]/@fn)"/></xsl:message>
      -->
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:attribute name="src"
                       select="f:resolve-link($baseuri,$xmlman/file[@uri=current()/@src]/@fn)"/>
        <xsl:apply-templates mode="phase3"/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <!--
      <xsl:message>ABSOLUTE IMG: <xsl:value-of select="@src"/></xsl:message>
      -->
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="phase3"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="h:object[@data]" mode="phase3">
  <xsl:choose>
    <xsl:when test="$xmlman/file[@uri=current()/@data]">
      <!--
      <xsl:message>RESOLVE IMG: <xsl:value-of select="@data"/></xsl:message>
      <xsl:message>       BASE: <xsl:value-of select="$baseuri"/></xsl:message>
      <xsl:message>      LOCAL: <xsl:value-of select="$xmlman/file[@uri=current()/@data]/@fn"/></xsl:message>
      <xsl:message>     RESULT: <xsl:value-of select="f:resolve-link($baseuri,$xmlman/file[@uri=current()/@data]/@fn)"/></xsl:message>
      -->
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:attribute name="data"
                       select="f:resolve-link($baseuri,$xmlman/file[@uri=current()/@data]/@fn)"/>
        <xsl:apply-templates mode="phase3"/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <!--
      <xsl:message>ABSOLUTE IMG: <xsl:value-of select="@data"/></xsl:message>
      -->
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="phase3"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="h:object[@data]" mode="phase3">
  <xsl:variable name="chunkuri" select="ancestor::h:div[@chunk][1]/@chunk"/>

<!--
  <xsl:message>RESOLVE OBJECT: <xsl:value-of select="@data"/></xsl:message>
  <xsl:message>       AGAINST: <xsl:value-of select="$chunkuri"/></xsl:message>
  <xsl:message>        RESULT: <xsl:value-of select="f:resolve-uri(@data, $chunkuri)"/></xsl:message>
-->

  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="data" select="f:resolve-uri(@data, $chunkuri)"/>
    <xsl:apply-templates mode="phase3"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:a[starts-with(@href,$intradoc)]" mode="phase3">
  <xsl:variable name="id" select="substring-after(@href,'#')"/>
  <xsl:variable name="target" select="key('id',$id)"/>
  <xsl:variable name="tchunk"
                select="($target/ancestor-or-self::h:div[@chunk])[last()]/@chunk"/>
  <xsl:variable name="targeturi" select="concat($tchunk,'#',$id)"/>
  <xsl:variable name="chunkuri" select="ancestor::h:div[@chunk][1]/@chunk"/>

<!--
  <xsl:message>RESOLVE A: <xsl:value-of select="$targeturi"/></xsl:message>
  <xsl:message>  AGAINST: <xsl:value-of select="$chunkuri"/></xsl:message>
  <xsl:message>   RESULT: <xsl:value-of select="f:resolve-a-href($targeturi, $chunkuri)"/></xsl:message>
-->

  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="href" select="f:resolve-a-href($targeturi, $chunkuri)"/>
    <xsl:apply-templates mode="phase3"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="*" mode="phase3">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="phase3"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()" mode="phase3">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="/" mode="ncxtoc">
  <xsl:apply-templates select="h:html/h:body" mode="ncxtoc"/>
</xsl:template>

<xsl:template match="h:body" mode="ncxtoc"
              xmlns="http://www.daisy.org/z3986/2005/ncx/">

  <ncx version="2005-1" xml:lang="en">
    <head>
      <meta name="dtb:uid" content="xxx"/>
      <meta name="dtb:depth" content="-1"/>
      <meta name="dtb:totalPageCount" content="0"/>
      <meta name="dtb:maxPageNumber" content="0"/>
    </head>

    <docTitle>
      <text><xsl:value-of select="normalize-space(/h:html/h:head/h:title)"/></text>
    </docTitle>

    <navMap>
      <navPoint id="cover" playOrder="1">
        <navLabel>
          <text>
            <xsl:value-of select="normalize-space(/h:html/h:head/h:title)"/>
          </text>
        </navLabel>
        <content src="{substring-after($coverpath, '/')}"/>
      </navPoint>

      <xsl:apply-templates select="h:div" mode="navPoint"/>
    </navMap>
  </ncx>
</xsl:template>

<xsl:template match="h:div" mode="navPoint"
              xmlns="http://www.daisy.org/z3986/2005/ncx/">

  <xsl:choose>
    <xsl:when test="@toc">
      <navPoint id="{generate-id(.)}" playOrder="{@playOrder}">
        <xsl:if test="@class">
          <xsl:attribute name="class" select="@class"/>
        </xsl:if>

        <navLabel>
          <text>
            <xsl:value-of
                select="normalize-space((.//h:h1|.//h:h2|.//h:h3|.//h:h4|.//h:h5|.//h:h6)[1])"/>
          </text>
        </navLabel>

        <content>
          <xsl:attribute name="src">
            <xsl:choose>
              <xsl:when test="@chunk">
                <xsl:value-of
                    select="substring-after(@chunk, concat($website,'/'))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="chunk" select="ancestor::h:div[@chunk][1]"/>
                <xsl:value-of select="substring-after(concat($chunk/@chunk,'#',@toc), concat($website, '/'))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </content>

        <xsl:apply-templates select="h:div" mode="navPoint"/>
      </navPoint>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="h:div" mode="navPoint"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="/" mode="package"
              xmlns:dc="http://purl.org/dc/elements/1.1/"
              xmlns="http://www.idpf.org/2007/opf">
  <xsl:variable name="head" select="//h:div[@class='head']"/>
  <xsl:variable name="abstract"
                select="//h:div[h:h2/h:a[@name='abstract']]
                        |//h:div[@class='abstract' and h:h2]"/>

  <package version="2.0" unique-identifier="bookid">
    <metadata>
      <dc:identifier id="bookid">
        <xsl:value-of select="trd:thisVersionURI()"/>
      </dc:identifier>
      <dc:title>
        <xsl:value-of select="normalize-space(/h:html/h:head/h:title)"/>
      </dc:title>
      <dc:rights>
        <xsl:value-of select="normalize-space($head//h:p[@class='copyright'])"/>
      </dc:rights>
      <dc:publisher>W3C</dc:publisher>
      <dc:subject>Web technology</dc:subject>
      <dc:date>
        <xsl:value-of select="trd:getXSDate()"/>
      </dc:date>
      <dc:description>
        <xsl:for-each select="$abstract/h:p">
          <xsl:text>&lt;p&gt;</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>&lt;/p&gt;</xsl:text>
        </xsl:for-each>
      </dc:description>

      <xsl:variable name="editor-list" as="xs:string*">
        <xsl:call-template name="trd:getEditorsList"/>
      </xsl:variable>

      <xsl:for-each select="$editor-list">
        <xsl:if test="not(starts-with(.,','))">
          <dc:creator xmlns:opf="http://www.idpf.org/2007/opf" opf:file-as="{.}">
            <xsl:value-of select="."/>
          </dc:creator>
        </xsl:if>
      </xsl:for-each>

      <dc:language>en</dc:language>
      <meta name="cover" content="cover-image"/>
    </metadata>

    <manifest>
      <item id="ncxtoc" media-type="application/x-dtbncx+xml" href="toc.ncx"/>
      <item id="cover-image" href="cover-clipped.png" media-type="image/png"/>
      <item id="cover" href="{substring-after($coverpath,'/')}" media-type="application/xhtml+xml"/>

      <xsl:for-each select="$xmlman/file">
        <item id="{generate-id(.)}" href="{substring-after(@fn, concat($website,'/'))}"
              media-type="{@type}"/>
      </xsl:for-each>

      <xsl:apply-templates select="/h:html/h:body/h:div" mode="package"/>
    </manifest>

    <spine toc="ncxtoc">
      <itemref idref="cover" linear="no"/>
      <xsl:for-each select="/h:html/h:body//h:div">
        <xsl:if test="@chunk">
          <itemref idref="{generate-id(.)}"/>
        </xsl:if>
      </xsl:for-each>
    </spine>

    <guide>
      <reference href="{substring-after($coverpath, '/')}" type="cover" title="Cover"/>
    </guide>
  </package>
</xsl:template>

<xsl:template match="h:div" mode="package"
              xmlns="http://www.idpf.org/2007/opf">

  <xsl:if test="@chunk">
    <item id="{generate-id(.)}" href="{substring-after(@chunk, concat($website,'/'))}"
          media-type="application/xhtml+xml"/>
  </xsl:if>

  <xsl:apply-templates select="h:div" mode="package"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="/" mode="chunks">
  <xsl:apply-templates mode="chunks"/>
</xsl:template>

<xsl:template match="h:div" mode="chunks">
  <xsl:if test="@chunk">
    <xsl:result-document href="{concat($base,substring-after(@chunk,'//'))}">
      <html>
        <head>
          <xsl:copy-of select="/h:html/h:head/h:script
                               /h:html/h:head/h:style
                               |/h:html/h:head/h:link[@rel='stylesheet']"/>
          <title>Irrelevant, will never be displayed, right?</title>
        </head>
        <body>
          <div>
            <xsl:copy-of select="@*[not(local-name(.)='chunk')
                                    and not(local-name(.)='toc')
                                    and not(local-name(.)='playOrder')]"/>
            <xsl:apply-templates mode="partbody"/>
          </div>
        </body>
      </html>
    </xsl:result-document>
  </xsl:if>

  <xsl:apply-templates mode="chunks"/>
</xsl:template>

<xsl:template match="*" mode="chunks">
  <xsl:apply-templates mode="chunks"/>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()" mode="chunks"/>

<!-- ============================================================ -->

<xsl:template match="h:div" mode="partbody">
  <xsl:if test="not(@chunk)">
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name(.)='chunk')
                              and not(local-name(.)='toc')
                              and not(local-name(.)='playOrder')]"/>
      <xsl:apply-templates mode="partbody"/>
    </xsl:copy>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="partbody">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="partbody"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()" mode="partbody">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="f:id" as="xs:string">
  <xsl:param name="node" as="element(h:div)"/>
  <xsl:value-of select="($node/(.//h:h1|.//h:h2|.//h:h3|.//h:h4|.//h:h5|.//h:h6))[1]/h:a[@name][1]/@name"/>
</xsl:function>

<xsl:function name="f:toc" as="xs:string?">
  <xsl:param name="node" as="element(h:div)"/>

  <xsl:variable name="id" select="f:id($node)"/>

  <xsl:choose>
    <xsl:when test="$node/@class='div1' or $node/@class='div2' or $node/@class='div3'
                    or $node/@class='div4' or $node/@class='div5'">
      <xsl:value-of select="f:id($node)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:chunk" as="xs:string?">
  <xsl:param name="node" as="element(h:div)"/>
  <xsl:variable name="depth" select="xs:integer($chunkdepth)"/>

  <!-- Handling of chunkdepth is a bit of a hack -->
  <xsl:choose>
    <xsl:when test="$depth = 1 and $node/@class = 'div1'">
      <xsl:value-of select="'true'"/>
    </xsl:when>
    <xsl:when test="$depth = 2
                    and ($node/@class = 'div1'
                         or ($node/@class = 'div2'
                             and $node/preceding-sibling::h:div[@class='div2']))">
      <xsl:value-of select="'true'"/>
    </xsl:when>
    <xsl:when test="$depth = 3
                    and ($node/@class = 'div1'
                         or ($node/@class = 'div2'
                             and $node/preceding-sibling::h:div[@class='div2'])
                         or ($node/@class = 'div3'
                             and $node/preceding-sibling::h:div[@class='div3']))">
      <xsl:value-of select="'true'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:absolute-uri" as="xs:string">
  <xsl:param name="uri"/>
  <xsl:param name="baseuri"/>

  <xsl:choose>
    <xsl:when test="starts-with($uri, '#')">
      <xsl:value-of select="$uri"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="resolve-uri($uri, $baseuri)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:resolve-uri" as="xs:string">
  <xsl:param name="uri"/>
  <xsl:param name="baseuri"/>

  <xsl:choose>
    <xsl:when test="starts-with($uri, '#')">
      <xsl:value-of select="$uri"/>
    </xsl:when>
    <xsl:when test="string($baseuri) = ''">
      <xsl:value-of select="$uri"/>
    </xsl:when>
    <xsl:when test="starts-with($uri, 'mailto:')">
      <xsl:value-of select="$uri"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="uri-fr"
                    select="if (starts-with($uri, 'http://'))
                            then substring-after($uri, 'http://')
                            else $uri"/>
      <xsl:variable name="baseuri-fr"
                    select="if (starts-with($baseuri, 'http://'))
                            then substring-after($baseuri, 'http://')
                            else $baseuri"/>

      <xsl:variable name="uri-trim"
                    select="f:trim-common($uri-fr, $baseuri-fr)"/>

      <xsl:variable name="base-trim"
                    select="f:trim-common($baseuri-fr, $uri-fr)"/>

      <xsl:variable name="parts" as="xs:string*">
        <xsl:for-each select="(1 to count(tokenize($base-trim, '/'))-1)">
          <xsl:value-of select="'../'"/>
        </xsl:for-each>
      </xsl:variable>

      <xsl:value-of select="string-join(($parts, $uri-trim), '')"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:trim-common">
  <xsl:param name="uri"/>
  <xsl:param name="alt"/>

  <xsl:choose>
    <!-- special case -->
    <xsl:when test="not(contains($uri, '/')) and not(contains($alt, '/'))
                    and contains($uri, '#') and contains($alt,'#')
                    and substring-before($uri,'#') = substring-before($alt,'#')">
      <xsl:value-of select="concat('#',substring-after($uri,'#'))"/>
    </xsl:when>
    <xsl:when test="not(contains($uri, '/')) or not(contains($alt, '/'))">
      <xsl:value-of select="$uri"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="uri-p" select="tokenize($uri, '/')"/>
      <xsl:variable name="alt-p" select="tokenize($alt, '/')"/>
      <xsl:variable name="prefix" select="concat($uri-p[1], '/')"/>
      <xsl:choose>
        <xsl:when test="$uri-p[1] = $alt-p[1]">
          <xsl:value-of select="f:trim-common(substring-after($uri, $prefix),
                                              substring-after($alt, $prefix))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$uri"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="f:resolve-a-href" as="xs:string">
  <xsl:param name="to-uri"/>
  <xsl:param name="from-uri"/>

  <xsl:choose>
    <xsl:when test="contains($to-uri,'#') and contains($from-uri,'#')
                    and substring-before($to-uri,'#') = substring-before($from-uri,'#')">
      <xsl:value-of select="concat('#', substring-after($to-uri, '#'))"/>
    </xsl:when>

    <xsl:when test="starts-with($to-uri, $baseuri)">
      <xsl:value-of select="substring-after($to-uri, $baseuri)"/>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="$to-uri"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:resolve-link" as="xs:string">
  <xsl:param name="base-uri"/>
  <xsl:param name="lcl-uri"/>

  <xsl:variable name="base-path" select="substring-after($base-uri, '//')"/>

  <xsl:variable name="base-trimmed" select="f:trim-common($base-path, $lcl-uri)"/>
  <xsl:variable name="lcl-trimmed" select="f:trim-common($lcl-uri, $base-path)"/>

  <xsl:value-of select="f:relative-to($base-trimmed, $lcl-trimmed)"/>
</xsl:function>

<xsl:function name="f:relative-to" as="xs:string">
  <xsl:param name="from-uri"/>
  <xsl:param name="to-uri"/>

  <xsl:variable name="depth" select="count(tokenize($from-uri,'/'))"/>
  <xsl:variable name="dirs" as="xs:string*">
    <xsl:for-each select="(1 to $depth - 1)">
      <xsl:value-of select="'../'"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="backup" select="string-join($dirs, '')"/>

  <xsl:value-of select="concat($backup, $to-uri)"/>
</xsl:function>

</xsl:stylesheet>
