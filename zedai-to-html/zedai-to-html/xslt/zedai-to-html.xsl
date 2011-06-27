<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2011/epub"
  xmlns:f="http://www.daisy.org/ns/functions" xmlns:its="http://www.w3.org/2005/11/its"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:z="http://www.daisy.org/ns/z3986/authoring/" exclude-result-prefixes="f xlink xs z"
  version="2.0">

  <xsl:output method="xml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes"/>

  <xsl:param name="base" select="base-uri()"/>

  <xsl:template match="/">
    <xsl:call-template name="html">
      <xsl:with-param name="nodes" select="z:document/z:body/*"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="html">
    <xsl:param name="nodes" as="node()*"/>
    <!--TODO translate: xml:lang-->
    <!--TODO config: externalize the profile definition-->
    <html xml:lang="en" profile="http://www.idpf.org/epub/30/profile/content/">
      <head>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
        <title><!--TODO translate: title--></title>
        <!--<meta name="dcterms:identifier" content="com.googlecode.zednext.alice"/>-->
        <!--<meta name="dcterms:publisher" content="CSU"/>-->
        <!--<meta name="dcterms:date" content="2010-03-27T13:50:05-02:00"/>-->
      </head>
      <body>
        <xsl:apply-templates select="$nodes"/>
      </body>
    </html>
  </xsl:template>

  <!--===========================================================-->
  <!-- Translation: Header                                       -->
  <!--===========================================================-->

  <!--TODO normalize: flatten meta -->
  <!--TODO translate: meta -->
  <!--<xsl:template match="z:meta">
    <meta>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </meta>
  </xsl:template>-->

  <!--===========================================================-->
  <!-- Translation: Section layer                                -->
  <!--===========================================================-->

  <!--====== Section module =====================================-->
  <xsl:template match="z:section">
    <section>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </section>
  </xsl:template>

  <!--====== Bibliography module ================================-->
  <xsl:template match="z:bibliography">
    <section>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('bibliography',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <!--TODO translate: bibliography/section[@role='custom']-->
      <xsl:apply-templates mode="bibliography"/>
    </section>
  </xsl:template>

  <xsl:template match="z:section" mode="bibliography">
    <section>
      <xsl:apply-templates select="@*"/>
      <!--TODO translate: bibliography/section[@role='custom']-->
      <xsl:apply-templates mode="bibliography"/>
    </section>
  </xsl:template>

  <xsl:template match="z:entry" mode="bibliography">
    <div>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('biblioentry',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!--====== Cover module =======================================-->

  <xsl:template match="z:cover">
    <section>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('cover',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  <xsl:template match="z:spine">
    <section>
      <xsl:apply-templates select="@*"/>
      <!--TODO translate: @role-->
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  <xsl:template match="z:frontcover">
    <section>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  <xsl:template match="z:backcover">
    <section>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  <xsl:template match="z:flaps">
    <section>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </section>
  </xsl:template>

  <!--====== Glossary module ====================================-->
  <!--TODO normalize: simple glossary => dl-->
  <!--TODO variants: handle the block variant-->
  <xsl:template match="z:glossary">
    <section>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('glossary',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <xsl:apply-templates mode="glossary"/>
    </section>
  </xsl:template>
  <xsl:template match="z:section" mode="glossary">
    <section>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="glossary"/>
    </section>
  </xsl:template>
  <xsl:template match="z:entry" mode="glossary">
    <dt>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('glossterm',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <xsl:apply-templates/>
    </dt>
  </xsl:template>

  <!--====== Index module =======================================-->

  <xsl:template match="z:index">
    <nav>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="index"/>
    </nav>
  </xsl:template>
  <xsl:template match="z:section" mode="index">
    <section>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="glossary"/>
    </section>
  </xsl:template>
  <xsl:template match="z:entry" mode="index">
    <!--FIXME normalize adjacent entries into ul -->
    <xsl:apply-templates/>
  </xsl:template>


  <!--====== Document partitions module =========================-->

  <xsl:template match="z:frontmatter">
    <section>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('frontmatter',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  <xsl:template match="z:bodymatter">
    <section>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('bodymatter',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  <xsl:template match="z:backmatter">
    <section>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('backmatter',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <xsl:apply-templates/>
    </section>
  </xsl:template>


  <!--====== ToC module =========================================-->

  <xsl:template match="z:toc">
    <nav>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('toc',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <xsl:apply-templates mode="toc"/>
    </nav>
  </xsl:template>

  <xsl:template match="z:entry" mode="toc">
    <!--FIXME normalize adjacent entries into ul -->
    <li>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  <xsl:template match="z:block" mode="toc">
    <div>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="toc"/>
    </div>
  </xsl:template>
  <xsl:template match="z:section" mode="toc">
    <section>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="toc"/>
    </section>
  </xsl:template>
  <xsl:template match="z:aside" mode="toc">
    <aside>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="toc"/>
    </aside>
  </xsl:template>

  <!--====== Verse module =======================================-->

  <xsl:template match="z:verse">
    <div>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="z:section" mode="verse">
    <section>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="verse"/>
    </section>
  </xsl:template>

  <!--===========================================================-->
  <!-- Translation: Block layer                                  -->
  <!--===========================================================-->

  <!--====== Block module =======================================-->

  <xsl:template match="z:block" mode="#all">
    <div>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="@associate" mode="#all">
    <xsl:attribute name="data-associate" select="."/>
  </xsl:template>

  <!--====== Annotation module ==================================-->

  <xsl:template match="z:annotation" mode="#all">
    <aside>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('annotation',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <xsl:apply-templates/>
    </aside>
  </xsl:template>
  <!--TODO variants: handle block annotations-->
  <xsl:template match="z:annoref" mode="#all">
    <a href="{@ref}">
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('annoref',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <xsl:apply-templates select="if (@value) then @value else *"/>
    </a>
  </xsl:template>
  <xsl:template match="z:annoref/@value">
    <xsl:value-of select="."/>
  </xsl:template>

  <!--====== Aside module =======================================-->

  <xsl:template match="z:aside" mode="#all">
    <aside>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </aside>
  </xsl:template>

  <!--====== Byline module ======================================-->

  <xsl:template match="z:byline" mode="#all">
    <p>
      <xsl:apply-templates select="@*"/>
      <!--TODO translate: @role-->
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <!--====== Caption module =====================================-->

  <xsl:template match="z:caption" mode="#all">
    <!--TODO normalize: captions-->
    <figcaption>
      <xsl:apply-templates select="@*"/>
      <!--TODO translate: @role-->
      <xsl:apply-templates/>
    </figcaption>
  </xsl:template>

  <!--====== Cite module ========================================-->

  <xsl:template match="z:citation" mode="#all">
    <!--TODO normalize: citation (e.g. within a quote) -->
    <cite>
      <xsl:apply-templates select="@*"/>
      <!--TODO translate: @role-->
      <xsl:apply-templates/>
    </cite>
  </xsl:template>

  <!--====== Code module ==================================-->

  <!--TODO variants: refine characterization -->
  <xsl:template match="z:code" mode="#all">
    <pre>
      <code>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates mode="code"/>
      </code>
    </pre>
  </xsl:template>
  <xsl:template match="z:code[f:is-phrase(.)]">
    <code>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="code"/>
    </code>
  </xsl:template>
  <xsl:template match="z:lngroup" mode="code">
    <div>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('dsy:lngroup',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <xsl:apply-templates mode="code"/>
    </div>
  </xsl:template>

  <!--====== Dateline module ==================================-->

  <xsl:template match="z:dateline">
    <p>
      <!--TODO translate: => time/@pubdate child ? -->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <!--====== Definition module ==================================-->

  <xsl:template match="z:definition">
    <p>
      <!--TODO translate: @role -->
      <!--TODO normalize: definition => dl/dd ? -->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <!--====== Description module =================================-->

  <xsl:template match="z:description">
    <!--TODO translate: description -->
  </xsl:template>

  <!--====== Headings module ====================================-->
  <xsl:template match="z:h" mode="#all">
    <xsl:element name="{if (z:hpart) then 'span' else 'h1'}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="z:hpart" mode="#all">
    <h1>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </h1>
  </xsl:template>
  <xsl:template match="z:hd" mode="#all">
    <p>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('bridgehead',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <b>
        <xsl:apply-templates/>
      </b>
    </p>
  </xsl:template>

  <!--====== List module ========================================-->

  <xsl:template match="z:list" mode="#all">
    <!--TODO normalize: page breaks-->
    <xsl:element name="{if (@type='ordered') then 'ol' else 'ul'}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="z:list[@type='ordered']/@start">
    <xsl:copy/>
  </xsl:template>
  <xsl:template match="z:item" mode="#all">
    <li>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!--====== Note module ========================================-->

  <!--TODO normalize: group adjacent nodes in a parent aside -->
  <xsl:template match="z:note">
    <aside>
      <!--TODO translate: @ref-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </aside>
  </xsl:template>
  <xsl:template match="z:noteref">
    <a rel="note">
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('notered',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
      <xsl:choose>
        <xsl:when test="@value">
          <sup>
            <xsl:value-of select="@value"/>
          </sup>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <!--====== Object module ======================================-->
  <xsl:template match="z:object[starts-with(@srctype,'image/')]">
    <img src="{@src}" alt=""/>
    <!--TODO translate: object children-->
    <!--Either:
     - direct children (implicit description[@by='author'])
     - description child
     - external desription-->
  </xsl:template>
  <xsl:template match="object">
    <xsl:message select="'object: unsuported media type'"/>
  </xsl:template>

  <!--====== Paragraph module ===================================-->

  <xsl:template match="z:p">
    <p>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <!--====== Pagebreak module ===================================-->

  <!--TODO normalize: page breaks-->
  <!--TODO variants: refine characterization-->
  <xsl:template match="z:pagebreak">
    <div>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('pagebreak',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
    </div>
  </xsl:template>
  <xsl:template match="z:pagebreak[f:is-phrase(.)]">
    <span>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('pagrebreak',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
    </span>
  </xsl:template>
  <xsl:template match="z:pagebreak/@value">
    <xsl:attribute name="title" select="."/>
  </xsl:template>

  <!--====== Quote module =======================================-->

  <!--TODO variants: refine characterization -->
  <!--TODO translate: citation child => @cite -->
  <xsl:template match="z:quote">
    <blockquote>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </blockquote>
  </xsl:template>
  <xsl:template match="z:quote[f:is-phrase(.)]">
    <q>
      <xsl:apply-templates select="@*"/>
      <!--TODO normalize: quotation marks-->
      <xsl:apply-templates/>
    </q>
  </xsl:template>

  <!--====== Transition module ==================================-->

  <xsl:template match="z:transition" mode="#all">
    <hr>
      <xsl:apply-templates select="@*"/>
    </hr>
  </xsl:template>

  <!--====== Table module =======================================-->
  <!--TODO translate: table module-->

  <!--===========================================================-->
  <!-- Translation: Phrase layer                                 -->
  <!--===========================================================-->

  <!--====== Span module ========================================-->

  <xsl:template match="z:span" mode="#all">
    <span>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>

  <!--====== Abbreviations module ===============================-->

  <xsl:template match="z:abbr" mode="#all">
    <abbr title="{normalize-space(id(@ref))}">
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </abbr>
  </xsl:template>
  <xsl:template match="z:expansion[not(ancestor::z:head)]" mode="#all">
    <!--
      expansions in the header are ignored (used for abbreviation's title attribute)
      expansions in the body are translated as spans
    -->
    <span>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>

  <!--====== Dialogue module ====================================-->

  <xsl:template match="z:d" mode="#all">
    <span>
      <!--TODO translate: @role-->
      <!--TODO normalize: quotation marks-->
      <!--TODO translate: conceptual link to speaker -->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>

  <!--====== Emphasis module ====================================-->

  <xsl:template match="z:emph" mode="#all">
    <em>
      <!-- TODO translate: => em vs strong ? -->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </em>
  </xsl:template>

  <!--====== Line module ========================================-->

  <xsl:template match="z:ln" mode="#all">
    <span>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </span>
    <br/>
  </xsl:template>

  <xsl:template match="z:lnum" mode="#all">
    <span>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>

  <xsl:template match="z:lngroup" mode="#all">
    <div>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>

  <!--====== Linking module =====================================-->

  <xsl:template match="z:ref" mode="#all">
    <a>
      <!--TODO translate: conceptual link ?-->
      <!--TODO translate: multiple @ref destinations ?-->
      <xsl:choose>
        <xsl:when test="@ref">
          <xsl:attribute name="href" select="concat('#',@ref)"/>
        </xsl:when>
        <xsl:when test="@xlink:href">
          <xsl:attribute name="href" select="@xlink:href"/>
          <xsl:attribute name="rel" select="'external'"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="@* except (@ref,@xlink:href)"/>
      <xsl:apply-templates mode="#current"/>
    </a>
  </xsl:template>

  <!--TODO translate: @continuation-->

  <!--====== Name module ========================================-->

  <xsl:template match="z:name" mode="#all">
    <!--TODO translate: => i, span, b ?-->
    <i>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </i>
  </xsl:template>

  <!--====== Num module =========================================-->

  <xsl:template match="z:num" mode="#all">
    <span>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:if test="@value">
        <xsl:attribute name="title" select="@value"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>

  <!--====== Sentence module ====================================-->

  <xsl:template match="z:s" mode="#all">
    <span>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>

  <!--====== Term module ========================================-->

  <!-- TODO translate: => i, dfn ? -->
  <xsl:template match="z:term" mode="#all">
    <xsl:element
      name="{if (id(@ref)=(parent::*,preceding-sibling::*,following-sibling::*)) 
               then 'dfn'
               else 'i'}">
      <!--TODO translate: @role-->
      <!--TODO translate: @ref-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>

  <!--====== Time module ========================================-->

  <xsl:template match="z:time" mode="#all">
    <time>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="@time">
        <xsl:attribute name="datetime" select="@time"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </time>
  </xsl:template>

  <!--====== Word module ========================================-->

  <xsl:template match="z:w" mode="#all">
    <span>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>
  <xsl:template match="z:wpart" mode="#all">
    <span>
      <!--TODO translate: @role-->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>

  <!--===========================================================-->
  <!-- Translation: Text layer                                   -->
  <!--===========================================================-->
  <!--====== Sup/sub module =====================================-->

  <xsl:template match="z:sub" mode="#all">
    <sub>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </sub>
  </xsl:template>

  <xsl:template match="z:sup" mode="#all">
    <sup>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </sup>
  </xsl:template>

  <!--====== Char module ========================================-->

  <xsl:template match="z:span" mode="#all">
    <!-- TODO translate: => CSS ? -->
    <span>
      <!-- TODO translate: @role -->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>


  <!--===========================================================-->
  <!-- Identity templates                                        -->
  <!--===========================================================-->

  <xsl:template match="comment()|processing-instruction()|text()">
    <xsl:copy/>
  </xsl:template>

  <!--===========================================================-->
  <!-- Global attributes                                         -->
  <!--===========================================================-->

  <xsl:template name="attr">
    <xsl:apply-templates select="@*"/>
  </xsl:template>

  <xsl:template match="@xml:id">
    <xsl:attribute name="id" select="."/>
  </xsl:template>
  <xsl:template match="@xml:space|@xml:base|@base|@xml:lang|@its:dir">
    <xsl:copy/>
    <!--TODO translate: @its:dir lro and rlo values -->
    <!--TODO translate: @its:translate-->
  </xsl:template>
  <xsl:template match="@role">
    <xsl:copy/>
    <!--TODO translate: @role -->
  </xsl:template>

  <xsl:template name="role">
    <xsl:param name="roles" as="xs:string*"/>
    <xsl:variable name="role-string" select="normalize-space(string-join($roles,' '))"/>
    <xsl:attribute name="role"
      select="string-join(distinct-values(tokenize($role-string,'\s+')),' ')"/>
  </xsl:template>
  <!--
    Use translation function for roles ? e.g.
      <xsl:function name="f:role">
        tbd
      </xsl:function>
    It can be called in:
      <span role="{f:role(@role,'explicit role values'}">
        <xsl:apply-templates select="@* except @role"/>
      </span>
  -->


  <!--===========================================================-->
  <!-- Keys                                                      -->
  <!--===========================================================-->

  <!--===========================================================-->
  <!-- Util functions                                            -->
  <!--===========================================================-->

  <xsl:function name="f:is-phrase" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:value-of
      select="$node/preceding-sibling::text()[normalize-space()]
      or $node/following-sibling::text()[normalize-space()]"
    />
  </xsl:function>
</xsl:stylesheet>
