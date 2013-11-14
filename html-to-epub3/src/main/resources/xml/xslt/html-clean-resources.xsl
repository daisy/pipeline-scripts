<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
    xmlns:pf="http://www.daisy.org/ns/pipeline/functions" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>

    <xsl:output indent="yes"/>


    <!--TODO implement a custom HTML-compliant base-uri() function-->
    <xsl:variable name="doc-base"
        select="if (/html/head/base[@href][1]) then resolve-uri(normalize-space(/html/head/base[@href][1]/@href),base-uri(/)) else base-uri(/)"/>


    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>


    <!--TODO handle SVG references-->
    <!--TODO filter references to self-->


    <!--<xsl:template match="/processing-instruction('xml-stylesheet')">
        <xsl:variable name="href" select="replace(.,'^.*href=(&amp;apos;|&quot;)(.*?)\1.*$','$2')"/>
        <xsl:variable name="type" select="replace(.,'^.*type=(&amp;apos;|&quot;)(.*?)\1.*$','$2')"/>
        <!-\-TODO-\->
        <xsl:copy-of select="."/>
    </xsl:template>-->

    <xsl:template match="link">
        <!--
            External resources: icon, prefetch, stylesheet + pronunciation
            Hyperlinks:  alternate, author, help, license, next, prev, search
        -->
        <!--Note: outbound hyperlinks that resolve outside the EPUB Container are not Publication Resources-->
        <!--TODO warning for remote external resources, ignore remote hyperlinks -->
        <xsl:variable name="rel" as="xs:string*" select="tokenize(@rel,'\s+')"/>
        <xsl:choose>
            <xsl:when
                test="$rel='stylesheet' and not(@type='text/css' or pf:get-extension(@href)='css')">
                <xsl:message
                    select="concat('[WARNING] Discarding stylesheet ''',@href,''' of non-core type.')"
                />
            </xsl:when>
            <xsl:when
                test="$rel='pronunciation' and not(@type='application/pls+xml' or pf:get-extension(@href)='pls')">
                <xsl:message
                    select="concat('[WARNING] Discarding pronunciation lexicon ''',@href,''' of non-core type.')"
                />
            </xsl:when>
            <xsl:when test="pf:is-relative(@href) and not($rel=('stylesheet','pronunciation'))">
                <xsl:message
                    select="concat('[WARNING] Discarding local link ''',@href,''' of unsupported relation type ''',@rel,'''.')"
                />
            </xsl:when>
            <xsl:otherwise>
                <link href="{f:safe-uri(@href)}" data-original-href="{normalize-space(@href)}">
                    <xsl:copy-of select="@* except @href | node()"/>
                </link>
            </xsl:otherwise>
            <!--FIXME parse CSS-->
        </xsl:choose>
    </xsl:template>

    <!--<xsl:template match="style">
        <!-\-TODO parse refs in inlined CSS-\->
    </xsl:template>-->

    <xsl:template match="script">
        <xsl:choose>
            <xsl:when
                test="@src and not(normalize-space(@type)=('','text/javascript','text/ecmascript',
                'text/javascript1.0','text/javascript1.1','text/javascript1.2','text/javascript1.3',
                'text/javascript1.4','text/javascript1.5','text/jscript','text/livescript',
                'text/x-javascript','text/x-ecmascript','application/x-javascript',
                'application/x-ecmascript','application/javascript','application/ecmascript'))">
                <xsl:message select="'[WARNING] Discarding script of non-core type.'"/>
            </xsl:when>
            <xsl:when test="@src">
                <script src="{f:safe-uri(@src)}" data-original-href="{normalize-space(@src)}" type="text/javascript"><xsl:copy-of select="@* except (@src,@type)"/></script>
            </xsl:when>
            <xsl:otherwise>
                <script type="{if (normalize-space(@type)=('','text/javascript','text/ecmascript',
                    'text/javascript1.0','text/javascript1.1','text/javascript1.2','text/javascript1.3',
                    'text/javascript1.4','text/javascript1.5','text/jscript','text/livescript',
                    'text/x-javascript','text/x-ecmascript','application/x-javascript',
                    'application/x-ecmascript','application/javascript','application/ecmascript')) then 'text/javascript' else @type}">
                    <xsl:copy-of select="@* except @type | node()"/>
                </script>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="a[@href]">
        <xsl:choose>
            <xsl:when
                test="pf:is-relative(@href) and pf:get-path(@href) and not(pf:file-exists(pf:unescape-uri(pf:get-path(@href))))"
                use-when="function-available('pf:file-exists')">
                <xsl:message
                    select="concat('[WARNING] Discarding link to non-existing resource ''',@href,'''.')"/>
                <span>
                    <xsl:copy-of select="@* except (@href|@target|@rel|@media|@targetlang|@type)"/>
                    <xsl:apply-templates select="node()"/>
                </span>
            </xsl:when>
            <xsl:when test="false()"> </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="img[@src]">
        <xsl:choose>
            <xsl:when test="pf:get-scheme(@src)='data'">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="pf:is-absolute(@src)">
                <xsl:message
                    select="concat('[WARNING] Replacing remote image ''',@src,''' by alternative text.')"/>
                <span>
                    <xsl:copy-of
                        select="@* except (@alt|@src|@crossorigin|@usemap|@ismap|@width|@height)"/>
                    <xsl:value-of select="@alt"/>
                </span>
            </xsl:when>
            <xsl:when test="not(pf:get-extension(@src)=('png','jpeg','jpg','gif','svg'))">
                <xsl:message
                    select="concat('[WARNING] The type of image ''',@src,''' is not a core EPUB media type. Replacing by alternative text.')"/>
                <span>
                    <xsl:copy-of
                        select="@* except (@alt|@src|@crossorigin|@usemap|@ismap|@width|@height)"/>
                    <xsl:value-of select="@alt"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <img src="{f:safe-uri(@src)}" data-original-href="{normalize-space(@src)}">
                    <xsl:copy-of select="@* except @src | node()"/>
                </img>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="iframe[@src]">
        <xsl:choose>
            <xsl:when test="pf:is-absolute(@src)">
                <xsl:message select="concat('[WARNING] Discarding remote iframe ''',@src,'''.')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="safe-uri"
                    select="if (pf:get-extension(@src)='xhtml') then f:safe-uri(@src) 
                    else f:safe-uri(pf:replace-path(@src,replace(pf:get-path(@src),'\.[^.]+$','.xhtml')))"/>
                <iframe src="{$safe-uri}" data-original-href="{normalize-space(@src)}">
                    <xsl:copy-of select="@* except @src | node()"/>
                </iframe>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="embed[@src]">
        <xsl:choose>
            <xsl:when test="pf:is-absolute(@src)">
                <xsl:message
                    select="concat('[WARNING] Discarding remote embedded resource ''',@src,'''.')"/>
            </xsl:when>
            <xsl:when test="f:is-core-audio(@src,@type)">
                <audio src="{f:safe-uri(@src)}" data-original-href="{normalize-space(@src)}">
                    <xsl:apply-templates select="@* except (@src,@type,@width,@height)"/>
                </audio>
            </xsl:when>
            <xsl:when test="f:is-core-image(@src,@type)">
                <img src="{f:safe-uri(@src)}" data-original-href="{normalize-space(@src)}" alt="">
                    <xsl:apply-templates select="@* except (@src,@type)"/>
                </img>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message
                    select="concat('[WARNING] Discarding embedded resource of non-core type ''',@src,'''.')"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="object[@data]">
        <xsl:choose>
            <xsl:when test="pf:is-absolute(@data)">
                <xsl:message select="concat('[WARNING] Discarding remote object ''',@data,'''.')"/>
            </xsl:when>
            <xsl:when
                test="f:is-core-audio(@data,@type) or f:is-core-image(@data,@type) or exists(* except param)">
                <object data="{f:safe-uri(@data)}" data-original-href="{normalize-space(@src)}">
                    <xsl:apply-templates select="@* except @data | node()"/>
                </object>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message
                    select="concat('[WARNING] Discarding object ''',@data,''' of non-core type with no fallback.')"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="audio[@src]">
        <xsl:choose>
            <xsl:when
                test="f:is-core-audio(@src,()) or exists(* except track) or normalize-space(.)">
                <audio src="{f:safe-uri(@src)}" data-original-href="{normalize-space(@src)}">
                    <xsl:apply-templates select="@* except @src | node()"/>
                </audio>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message
                    select="concat('[WARNING] Discarding audio resource ''',@src,''' of non-core type with no fallback.')"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="audio[source]">
        <xsl:choose>
            <xsl:when
                test="exists(source[f:is-core-audio(@src,@type)]) or exists(* except (source,track)) or normalize-space(.)">
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'[WARNING] Discarding audio resource with no fallback.'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="video[@src]">
        <xsl:choose>
            <xsl:when test="exists(* except track) or normalize-space(.)">
                <video src="{f:safe-uri(@src)}" data-original-href="{normalize-space(@src)}">
                    <xsl:apply-templates select="@* except @src | node()"/>
                </video>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message
                    select="concat('[WARNING] Discarding video resource ''',@src,''' of non-core type with no fallback.')"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="video[source]">
        <xsl:choose>
            <xsl:when test="exists(* except (source,track)) or normalize-space(.)">
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'[WARNING] Discarding video resource with no fallback.'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="source">
        <source src="{f:safe-uri(@src)}" data-original-href="{normalize-space(@src)}">
            <xsl:apply-templates select="@* except @src"/>
        </source>
    </xsl:template>

    <xsl:template match="track">
        <track src="{f:safe-uri(@src)}" data-original-href="{normalize-space(@src)}">
            <xsl:apply-templates select="@* except @src"/>
        </track>
    </xsl:template>

    <!--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––>
     |  SVG                                                                        |
    <|–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––-->

    <!--See http://www.idpf.org/epub/30/spec/epub30-contentdocs.html#sec-svg-restrictions-->

    <xsl:template match="svg:animate|svg:set|svg:animateMotion|svg:animatecolor">
        <xsl:message select="'[WARNING] Discarding SVG animation element.'"/>
    </xsl:template>

    <xsl:template match="svg:audio">
        <xsl:message select="'[WARNING] Discarding SVG ''audio'' element, not part of SVG 1.1'"/>
    </xsl:template>

    <xsl:template match="svg:foreignObject[@xlink:href]">
        <xsl:message
            select="'[WARNING] Discarding SVG ''foreignObject'' element with external reference, not part of SVG 1.1'"
        />
    </xsl:template>

    <xsl:template match="svg:foreignObject/@requiredExtensions">
        <xsl:attribute name="requiredExtensions" select="'http://www.idpf.org/2007/ops'"/>
    </xsl:template>

    <xsl:template match="svg:font-face-uri">
        <svg:font-face-uri src="{f:safe-uri(@xlink:href)}"
            data-original-href="{normalize-space(@xlink:href)}">
            <xsl:apply-templates select="@* except @xlink:href | node()"/>
        </svg:font-face-uri>
    </xsl:template>

    <xsl:template match="svg:handler">
        <xsl:message select="'[WARNING] Discarding SVG ''handler'' element, not part of SVG 1.1'"/>
    </xsl:template>

    <xsl:template match="svg:image">
        <svg:image src="{f:safe-uri(@xlink:href)}"
            data-original-href="{normalize-space(@xlink:href)}">
            <xsl:apply-templates select="@* except @xlink:href | node()"/>
        </svg:image>
    </xsl:template>

    <xsl:template match="svg:script[@xlink:href]"/>

    <xsl:template match="svg:video">
        <xsl:message select="'[WARNING] Discarding SVG ''video'' element, not part of SVG 1.1'"/>
    </xsl:template>


    <!--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––>
     |  MathML                                                                     |
    <|–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––-->


    <xsl:template match="m:math[@altimg]">
        <m:math altimg="{f:safe-uri(@altimg)}" data-original-href="{normalize-space(@altimg)}">
            <xsl:apply-templates select="@* except @altimg | node()"/>
        </m:math>
    </xsl:template>

    <xsl:template match="m:mglyph[@src]">
        <m:math altimg="{f:safe-uri(@src)}" data-original-href="{normalize-space(@src)}">
            <xsl:apply-templates select="@* except @src | node()"/>
        </m:math>
    </xsl:template>

    <!--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––>
     |  Media Type Utils                                                           |
    <|–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––-->
    <xsl:function name="f:is-core-image" as="xs:boolean">
        <xsl:param name="uri" as="item()?"/>
        <xsl:param name="type" as="item()?"/>
        <xsl:sequence
            select="$type=('image/gif','image/jpeg','image/png','image/svg+xml') 
            or pf:get-extension($uri)=('gif','jpeg','jpg','png','svg')"
        />
    </xsl:function>
    <xsl:function name="f:is-core-audio" as="xs:boolean">
        <xsl:param name="uri" as="item()?"/>
        <xsl:param name="type" as="item()?"/>
        <xsl:sequence
            select="$type=('audio/mpeg','audio/mp4') 
            or pf:get-extension($uri)=('mp3','m4a','aac')"
        />
    </xsl:function>


    <xsl:function name="f:safe-uri" as="xs:string">
        <xsl:param name="uri" as="xs:string?"/>
        <xsl:sequence
            select="pf:replace-path($uri,escape-html-uri(replace(pf:unescape-uri(pf:get-path($uri)),'[^\p{L}\p{N}\-/_.]','_')))"
        />
    </xsl:function>
</xsl:stylesheet>
