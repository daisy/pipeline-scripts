<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:f="http://www.daisy.org/ns/functions-internal" xmlns:its="http://www.w3.org/2005/11/its"
  xmlns:pf="http://www.daisy.org/ns/functions" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:z="http://www.daisy.org/ns/z3998/authoring/" exclude-result-prefixes="#all" version="2.0">

  <xsl:import href="zedai-vocab-utils.xsl"/>

  <xsl:output method="xhtml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="base" select="base-uri(/)"/>

  <xsl:key name="refs" match="z:*[@ref]" use="tokenize(@ref,'\s+')"/>

  <xsl:template match="/">
    <xsl:call-template name="html">
      <xsl:with-param name="nodes" select="z:document/z:body/*"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="html">
    <xsl:param name="nodes" as="node()*"/>
    <!--TODO translate: xml:lang-->
    <!--TODO config: externalize the profile definition-->
    <html xml:lang="en">
      <head>
        <meta charset="UTF-8"/>
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
      <!--normalize adjacent z:entry elements into html:ul -->
      <xsl:for-each-group select="*" group-adjacent="empty(self::z:entry)">
        <xsl:choose>
          <xsl:when test="not(current-grouping-key())">
            <ul>
              <xsl:apply-templates mode="toc" select="current-group()"/>
            </ul>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="toc" select="current-group()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </nav>
  </xsl:template>

  <xsl:template match="z:entry" mode="toc">
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
  <xsl:template match="z:block[f:has-role(.,'figure')]" mode="#all">
    <figure>
      <xsl:apply-templates select="@*"/>
      <!--
        figure's objects:
        - tables or objects (images)
        the figure's top-level caption contains:
        - all captioning elements without @ref if there is an @associate on the parent
        - all captioning elements with @ref matching all the IDs of the figure's objects
      -->
      <xsl:variable name="objects" select="z:table|z:object"/>
      <xsl:variable name="captions"
        select=".[@associate]/(z:hd|z:caption|z:citation)[not(@ref)]
        | (z:hd|z:caption|z:citation)[f:references-all(.,$objects)]"
      />
      <!--we respect the document order: the caption is created either before or after
          the object depending on whether the first captioning element is found before
          or after.-->
      <xsl:if test="$captions[1] &lt;&lt; $objects[1]">
        <figcaption>
          <xsl:apply-templates select="f:simplify-captions($captions)" mode="caption"/>
        </figcaption>
      </xsl:if>
      <xsl:apply-templates select="*"/>
      <xsl:if test="$captions[1] >> $objects[1]">
        <figcaption>
          <xsl:apply-templates select="f:simplify-captions($captions)" mode="caption"/>
        </figcaption>
      </xsl:if>
    </figure>
  </xsl:template>

  <!--====== Annotation module ==================================-->

  <xsl:template match="z:annotation" mode="#all">
    <aside epub:type="annotation">
      <!--TODO better @role translation-->
      <!--<xsl:call-template name="role">
        <xsl:with-param name="roles" select="('annotation',@role)"/>
      </xsl:call-template>-->
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

  <!--Captions are handled in the templates of the captioned element-->
  <xsl:template match="z:caption" mode="#all"/>
  <xsl:template match="z:caption" mode="caption" priority="10">
    <xsl:choose>
      <xsl:when test="some $child in node() satisfies f:is-phrase($child)">
        <p>
          <xsl:apply-templates select="@*" mode="#default"/>
          <xsl:apply-templates mode="#default"/>
        </p>
      </xsl:when>
      <xsl:when test="@* except @ref">
        <div>
          <xsl:apply-templates select="@*" mode="#default"/>
          <xsl:apply-templates mode="#default"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="#default"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--====== Cite module ========================================-->

  <xsl:template match="z:citation" mode="#all">
    <xsl:if test="not(f:is-captioning(.))">
      <xsl:call-template name="citation"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="z:citation" mode="caption" priority="10">
      <xsl:call-template name="citation"/>
  </xsl:template>
  <xsl:template name="citation">
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

  <!--TODO Support @epub:describedat when standardized -->

  <xsl:template match="z:description[@xlink:href]" mode="#all">
    <xsl:message>[WARNING] Unsupported external description to '<xsl:value-of select="@xlink:href"
      />'.</xsl:message>
  </xsl:template>
  <xsl:template match="z:description" mode="#all"/>
  <xsl:template match="z:description" mode="details" priority="10">
    <xsl:choose>
      <xsl:when test="some $child in node() satisfies f:is-phrase($child)">
        <p>
          <xsl:apply-templates select="@*" mode="#default"/>
          <xsl:apply-templates mode="#default"/>
        </p>
      </xsl:when>
      <xsl:when test="@* except @ref">
        <div>
          <xsl:apply-templates select="@*" mode="#default"/>
          <xsl:apply-templates mode="#default"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="#default"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--====== Headings module ====================================-->
  <xsl:template match="z:h" mode="#all">
    <xsl:element name="{if (z:hpart) then 'hgroup' else 'h1'}">
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
    <!--
    Skip headings referencing tables and objects.
    They will be treated as captions under the 'caption' mode.
  -->
    <xsl:if test="not(f:is-captioning(.))">
      <xsl:call-template name="hd"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="z:hd" mode="caption" priority="10">
    <xsl:call-template name="hd"/>
  </xsl:template>
  <xsl:template name="hd">
    <xsl:choose>
      <!--figure are sectioning roots, it's safe to translate hd into h1-->
      <xsl:when test="parent::z:block[f:has-role(.,'figure')]">
        <h1>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates/>
        </h1>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:call-template name="role">
            <xsl:with-param name="roles" select="('bridgehead',@role)"/>
          </xsl:call-template>
          <xsl:apply-templates select="@* except @role" mode="#default"/>
          <xsl:apply-templates mode="#default"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
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
    <a rel="note" href="{concat('#',@ref)}">
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('noteref',@role)"/>
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
    </a>
  </xsl:template>

  <!--====== Object module ======================================-->
  <xsl:template match="z:object[f:is-image(.)]" mode="#all">
    <!--FIXME alt text: better translation of object children-->
    <!--Either:
     - direct children (implicit description[@by='author'])
     - description child
     - external desription-->
    <!--if part of a figure, simply copy
    else try to get captions-->
    <xsl:variable name="captions" select="../(z:hd|z:caption|z:citation)[f:references(.,current())]"/>
    <xsl:variable name="shared-captions"
      select="..[f:has-role(.,'figure')]/(z:hd|z:caption|z:citation)[f:references-all(.,../(z:object|z:table))]"/>
    <xsl:variable name="dedicated-captions" select="$captions except $shared-captions"/>
    <xsl:choose>
      <xsl:when test="$dedicated-captions">
        <figure>
          <xsl:if test="$dedicated-captions[1] &lt;&lt; .">
            <figcaption>
              <xsl:apply-templates select="f:simplify-captions($dedicated-captions)" mode="caption"/>
            </figcaption>
          </xsl:if>
          <img src="{@src}" alt="{.}">
            <xsl:apply-templates select="@*"/>
          </img>
          <xsl:if test="$dedicated-captions[1] >> .">
            <figcaption>
              <xsl:apply-templates select="f:simplify-captions($dedicated-captions)" mode="caption"/>
            </figcaption>
          </xsl:if>
        </figure>
      </xsl:when>
      <xsl:otherwise>
        <img src="{@src}" alt="{.}">
          <xsl:apply-templates select="@*"/>
        </img>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="z:object" mode="#all">
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
  <xsl:template match="z:pagebreak" mode="block">
    <div>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('pagebreak',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
    </div>
  </xsl:template>
  <xsl:template match="z:pagebreak">
    <span>
      <xsl:call-template name="role">
        <xsl:with-param name="roles" select="('pagebreak',@role)"/>
      </xsl:call-template>
      <xsl:apply-templates select="@* except @role"/>
    </span>
  </xsl:template>
  <xsl:template match="z:pagebreak/@value" mode="#all">
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
  <xsl:template match="z:table" mode="#all">
    <table>
      <xsl:apply-templates select="@*"/>
      <!--If the table is within a figure block, the caption has already been translated to a figcaption-->
      <xsl:if test="not(parent::z:block[@role='figure'])">
        <xsl:variable name="captions" select="key('refs',@xml:id)[self::z:hd|self::z:caption]"/>
        <xsl:variable name="descs" select="id(tokenize(@desc,'\s+'))[not(@xlink:href)]"/>
        <xsl:if test="$captions or $descs">
          <caption>
            <xsl:apply-templates
              select="if (count($captions)=1 and $captions[self::z:caption]) then $captions/node() else $captions"
              mode="caption"/>
            <xsl:if test="$descs">
              <!--TODO add CSS style to move out of the screen ?-->
              <details>
                <summary>Description</summary>
                <xsl:apply-templates select="$descs" mode="details"/>
              </details>
            </xsl:if>
          </caption>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates select="* except z:pagebreak"/>
      <!-- @colspan, @rowspan, @headers -->
    </table>
    <xsl:call-template name="table-final-pagebreaks"/>
  </xsl:template>
  <xsl:template match="z:colgroup" mode="#all">
    <colgroup>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="if(@span) then node() except z:col else node()"/>
    </colgroup>
  </xsl:template>
  <xsl:template match="z:col" mode="#all">
    <col>
      <xsl:apply-templates select="@*"/>
    </col>
  </xsl:template>
  <xsl:template match="z:colgroup/@span | z:col/@span" mode="#all">
    <xsl:copy/>
  </xsl:template>
  <xsl:template match="z:thead" mode="#all">
    <thead>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="* except z:pagebreak"/>
    </thead>
  </xsl:template>
  <xsl:template match="z:tbody" mode="#all">
    <tbody>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="* except z:pagebreak"/>
    </tbody>
  </xsl:template>
  <xsl:template match="z:tfoot" mode="#all">
    <tfoot>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="* except z:pagebreak"/>
    </tfoot>
  </xsl:template>
  <xsl:template match="z:tr" mode="#all">
    <tr>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="* except z:pagebreak"/>
    </tr>
  </xsl:template>
  <xsl:template name="th" match="z:th" mode="#all">
    <th>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="table-incell-pagebreaks"/>
      <xsl:apply-templates/>
    </th>
  </xsl:template>
  <xsl:template match="z:td[@scope]" mode="#all">
    <!-- Note: As td/@scope is not defined in HTML, td/@scope becomes th/@scope -->
    <xsl:call-template name="th"/>
  </xsl:template>
  <xsl:template match="z:td" mode="#all">
    <td>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="table-incell-pagebreaks"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>
  <xsl:template match="@colspan|@rowspan|@scope|@headers" mode="#all">
    <xsl:copy/>
  </xsl:template>
  <xsl:template name="table-incell-pagebreaks">
    <xsl:if test="position()=1">
      <!--pagebreak just before the current row-->
      <xsl:apply-templates select="../preceding-sibling::*[1][self::z:pagebreak]"/>
      <!--pagebreak at the end of the previous row-->
      <xsl:apply-templates
        select="../preceding-sibling::*[1][self::z:tr]/*[last()][self::z:pagebreak]"/>
    </xsl:if>
    <xsl:if test="position()=1 and not(../preceding-sibling::z:tr)">
      <!--pagebreak at the end of the previous header or body-->
      <xsl:apply-templates
        select="../parent::z:tbody/preceding-sibling::*[1][self::z:thead or self::z:tbody]/(*[last()]|*[last()]/*[last()])[self::z:pagebreak]"/>
      <xsl:apply-templates
        select="../parent::z:tfoot/preceding-sibling::*[1][self::z:tbody]/(*[last()]|*[last()]/*[last()])[self::z:pagebreak]"
      />
    </xsl:if>
    <!--pagebreak before the cell -->
    <xsl:apply-templates select="preceding-sibling::*[1][self::z:pagebreak]"/>
  </xsl:template>
  <xsl:template name="table-final-pagebreaks">
    <!--pagebreak after the last row-->
    <xsl:apply-templates select="*[last()][self::z:pagebreak]" mode="block"/>
    <!--pagebreak as the last child of the last row-->
    <xsl:apply-templates select="*[last()][self::z:tr]/*[last()][self::z:pagebreak]" mode="block"/>
    <!--pagebreak at the end of the last header or body-->
    <xsl:apply-templates
      select="*[last()][self::z:tbody|self::z:tfoot]/(*[last()]|*[last()]/*[last()])[self::z:pagebreak]"
      mode="block"/>
  </xsl:template>

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

  <!-- TODO differentiate from phrase level-->
  <!--<xsl:template match="z:span" mode="#all">
    <!-\- TODO translate: => CSS ? -\->
    <span>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
      <!-\- TODO translate: @role -\->
    </span>
  </xsl:template>-->


  <!--===========================================================-->
  <!-- Identity templates                                        -->
  <!--===========================================================-->

  <xsl:template match="comment()|processing-instruction()|text()">
    <xsl:copy/>
  </xsl:template>

  <!--===========================================================-->
  <!-- Global attributes                                         -->
  <!--===========================================================-->

  <xsl:template match="@xml:id">
    <xsl:attribute name="id" select="."/>
  </xsl:template>
  <xsl:template match="@base|@class|@xml:space|@xml:base|@xml:lang|@its:dir">
    <xsl:copy/>
    <!--TODO translate: @its:dir lro and rlo values -->
    <!--TODO translate: @its:translate-->
  </xsl:template>
  <xsl:template match="@role">
    <xsl:variable name="epub-type" select="pf:to-epub(.)"/>
    <xsl:if test="$epub-type">
      <xsl:attribute name="epub:type" select="$epub-type"/>
    </xsl:if>
  </xsl:template>

  <!--Do not copy attributes by default-->
  <xsl:template match="@*" mode="#all"/>

  <xsl:template name="role">
    <xsl:param name="roles" as="xs:string*"/>
    <xsl:variable name="role-string" select="normalize-space(string-join($roles,' '))"/>
    <xsl:attribute name="epub:type"
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

  <xsl:function name="f:has-role" as="xs:boolean">
    <xsl:param name="elem" as="element()"/>
    <xsl:param name="role" as="xs:string*"/>
    <xsl:sequence select="tokenize($elem/@role,'\s')=$role"/>
  </xsl:function>
  <xsl:function name="f:is-phrase" as="xs:boolean">
    <!--FIXME improve heuristics-->
    <xsl:param name="node" as="node()"/>
    <xsl:sequence
      select="$node/self::text()[normalize-space()] or $node/preceding-sibling::text()[normalize-space()]
      or $node/following-sibling::text()[normalize-space()]
      or $node/parent::z:p"
    />
  </xsl:function>
  <xsl:function name="f:is-block" as="xs:boolean">
    <!--FIXME improve heuristics-->
    <xsl:param name="node" as="node()"/>
    <xsl:sequence select="$node/(self::z:p or self::z:block)"/>
  </xsl:function>
  <xsl:function name="f:is-image" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:sequence
      select="starts-with($node/@srctype,'image/') or matches($node/@src,'\.(jpg|png|gif|svg)$')"/>
  </xsl:function>
  <xsl:function name="f:is-captioning" as="xs:boolean">
    <xsl:param name="elem" as="element()"/>
    <xsl:sequence
      select="$elem/../@associate or $elem/id(tokenize($elem/@ref,'\s'))[self::z:table|self::z:object]"/>
  </xsl:function>
  <xsl:function name="f:references" as="xs:boolean">
    <xsl:param name="ref" as="element()"/>
    <xsl:param name="elems" as="element()*"/>
    <xsl:sequence select="$ref/@ref and tokenize($ref/@ref,'\s')=$elems/@xml:id"/>
  </xsl:function>
  <xsl:function name="f:references-all" as="xs:boolean">
    <xsl:param name="ref" as="element()"/>
    <xsl:param name="elems" as="element()*"/>
    <xsl:sequence select="$ref/@ref and (every $id in $elems/@xml:id satisfies tokenize($ref/@ref,'\s')=$id)"/>
  </xsl:function>
  <xsl:function name="f:simplify-captions" as="node()*">
    <xsl:param name="captions" as="element()*"/>
    <xsl:sequence select="if (count($captions)=1 and $captions[self::z:caption]) then $captions/node() else $captions"/>
  </xsl:function>
</xsl:stylesheet>
