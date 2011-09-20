<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:mo="http://www.w3.org/ns/SMIL" xmlns:epub="http://www.idpf.org/2007/ops"
    type="pxi:daisy202-to-epub3-content" name="content" version="1.0">

    <p:input port="content-flow" primary="true" sequence="true"/>
    <p:input port="daisy-smil" sequence="true"/>
    <p:input port="ncc-navigation"/>

    <p:output port="content-with-original-base" sequence="true">
        <p:pipe port="content-with-original-base" step="content-flow-iterate"/>
    </p:output>
    <p:output port="content" sequence="true">
        <p:pipe port="content" step="content-flow-iterate"/>
    </p:output>
    <p:output port="daisy-smil-pagefixed" sequence="true">
        <p:pipe port="result" step="fix-smil-pagebreak-references"/>
    </p:output>
    <p:output port="ncc-navigation-pagefixed">
        <p:pipe port="ncc-navigation-pagefixed" step="content-flow-iterate"/>
    </p:output>
    <p:output port="manifest">
        <p:pipe port="result" step="manifest"/>
    </p:output>
    <p:output port="store-complete" sequence="true">
        <p:pipe port="store-complete" step="content-flow-iterate"/>
    </p:output>

    <p:option name="daisy-dir" required="true"/>
    <p:option name="publication-dir" required="true"/>
    <p:option name="content-dir" required="true"/>
    <p:option name="pub-id" required="true"/>

    <p:import href="resolve-links.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/join.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/upgrade-smil.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/rearrange.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/html-utils/html-library.xpl"/>

    <p:add-xml-base all="true" relative="false"/>
    <p:group name="content-flow-iterate">
        <p:output port="content-with-original-base" primary="false" sequence="true">
            <p:pipe port="content-with-original-base" step="content-flow-iterate.result"/>
        </p:output>
        <p:output port="content" primary="false" sequence="true">
            <p:pipe port="content" step="content-flow-iterate.result"/>
        </p:output>
        <p:output port="store-complete" sequence="true">
            <p:pipe port="store-complete" step="content-flow-iterate.store-content"/>
        </p:output>
        <p:output port="moved-pages-mapping" sequence="true">
            <p:pipe port="moved-pages-mapping" step="content-flow-iterate.move-pages"/>
        </p:output>
        <p:output port="ncc-navigation-pagefixed">
            <p:pipe port="ncc-navigation-pagefixed" step="content-flow-iterate.move-pages"/>
        </p:output>

        <p:for-each name="content-flow-iterate.load-and-transform">
            <p:output port="content" primary="true" sequence="true"/>

            <p:iteration-source select="/*/*"/>
            <p:variable name="original-uri" select="p:resolve-uri(/*/@href,/*/@xml:base)"/>
            <p:variable name="result-uri"
                select="concat($content-dir,substring(
                        p:resolve-uri(
                            if (matches(/*/@href,'\.[^\./]*$'))
                                then
                                    replace(/*/@href,'(.*)\.[^\.]*$','$1.xhtml')
                                else
                                    concat(/*/@href,'.xhtml'),
                            /*/@xml:base
                        ),
                        string-length($daisy-dir)+1
                    ))"/>
            <p:choose name="content-flow-iterate.load-and-transform.choose">
                <p:when test="lower-case(substring-after($original-uri,$daisy-dir))='ncc.html'">
                    <p:identity>
                        <p:input port="source">
                            <p:pipe port="ncc-navigation" step="content"/>
                        </p:input>
                    </p:identity>
                </p:when>
                <p:otherwise>
                    <px:html-load>
                        <p:with-option name="href" select="$original-uri"/>
                    </px:html-load>
                    <p:add-attribute match="/*" attribute-name="xml:base">
                        <p:with-option name="attribute-value" select="$original-uri"/>
                    </p:add-attribute>
                    <pxi:daisy202-to-epub3-resolve-links>
                        <p:input port="daisy-smil">
                            <p:pipe port="daisy-smil" step="content"/>
                        </p:input>
                    </pxi:daisy202-to-epub3-resolve-links>
                    <p:viewport match="html:a[@href and not(matches(@href,'^[^/]+:'))]">
                        <p:add-attribute match="/*" attribute-name="href">
                            <p:with-option name="attribute-value"
                                select="concat(replace(tokenize(/*/@href,'#')[1],'^(.*)\.html$','$1.xhtml#'),if (contains(/*/@href,'#')) then tokenize(/*/@href,'#')[last()] else '')"/>
                        </p:add-attribute>
                    </p:viewport>

                    <p:add-attribute match="/*" attribute-name="xml:base">
                        <p:with-option name="attribute-value" select="$result-uri"/>
                    </p:add-attribute>
                    <p:xslt>
                        <p:with-param name="href" select="$result-uri"/>
                        <p:with-param name="pub-id" select="$pub-id"/>
                        <p:input port="stylesheet">
                            <p:document href="daisy202-content-to-epub3-content.xsl"/>
                        </p:input>
                    </p:xslt>
                    <p:insert match="/*" position="first-child">
                        <p:input port="insertion">
                            <p:pipe port="ncc-navigation" step="content"/>
                        </p:input>
                    </p:insert>
                    <p:xslt>
                        <p:with-param name="doc-href" select="substring-after($result-uri,$publication-dir)"/>
                        <p:input port="stylesheet">
                            <p:document href="content.annotate-pagebreaks.xsl"/>
                        </p:input>
                    </p:xslt>
                    <!-- TODO: add html-outline-fixer.xsl here when it's done -->
                    <!-- TODO: add html-outline-cleaner.xsl here when it's done -->
                    <p:add-attribute match="/*" attribute-name="original-base">
                        <p:with-option name="attribute-value" select="$original-uri"/>
                    </p:add-attribute>
                </p:otherwise>
            </p:choose>
        </p:for-each>

        <p:group name="content-flow-iterate.move-pages">
            <p:output port="content" sequence="true" primary="true">
                <p:pipe port="result" step="content-flow-iterate.move-pages.result"/>
            </p:output>
            <p:output port="moved-pages-mapping">
                <p:pipe port="moved-pages-mapping" step="content-flow-iterate.move-pages.content"/>
            </p:output>
            <p:output port="ncc-navigation-pagefixed">
                <p:pipe port="result" step="content-flow-iterate.ncc-fixed-pagerefs"/>
            </p:output>

            <p:split-sequence name="content-flow-iterate.move-pages.ncc-split">
                <p:with-option name="test" select="concat('/*/@original-base=concat(&quot;',$daisy-dir,'&quot;,&quot;ncc.html&quot;)')">
                    <p:empty/>
                </p:with-option>
            </p:split-sequence>
            <p:sink/>

            <p:wrap-sequence wrapper="wrapper">
                <p:input port="source">
                    <p:pipe port="content" step="content-flow-iterate.load-and-transform"/>
                </p:input>
            </p:wrap-sequence>
            <p:delete match="/*/*/*"/>
            <p:delete>
                <p:with-option name="match"
                    select="concat('html:html[not(@original-uri=concat(&quot;',$daisy-dir,'&quot;,&quot;ncc.html&quot;)) and preceding-sibling::*[@original-uri=concat(&quot;',$daisy-dir,'&quot;,&quot;ncc.html&quot;)]]')"
                />
            </p:delete>
            <p:for-each>
                <p:iteration-source select="/*/*"/>
                <p:identity/>
            </p:for-each>
            <p:count name="content-flow-iterate.move-pages.ncc-position"/>
            <p:sink/>

            <p:wrap-sequence wrapper="wrapper">
                <p:input port="source">
                    <p:pipe step="content-flow-iterate.move-pages.ncc-split" port="not-matched"/>
                </p:input>
            </p:wrap-sequence>
            <p:choose name="content-flow-iterate.move-pages.content">
                <p:when test="count(//html:span[@class='page-normal' or @class='page-special' or @class='page-front']) = 0">
                    <p:output port="content" primary="true"/>
                    <p:output port="moved-pages-mapping">
                        <p:inline>
                            <mapping/>
                        </p:inline>
                    </p:output>
                    <!-- no pagebreaks; don't do anything -->
                    <p:identity/>
                </p:when>
                <p:otherwise>
                    <p:output port="content" primary="true"/>
                    <p:output port="moved-pages-mapping">
                        <p:pipe port="result" step="content-flow-iterate.move-pages.content.mapping"/>
                    </p:output>
                    <p:choose>
                        <p:when
                            test="(string-length(normalize-space(string-join((//html:span[@class='page-normal' or @class='page-special' or @class='page-front'])[1]/preceding::text()[ancestor::html:body],''))) &gt; 0) = true()">
                            <!-- there is no page break at the start of the first content document; lets generate one -->
                            <p:xslt>
                                <p:input port="parameters">
                                    <p:empty/>
                                </p:input>
                                <p:input port="stylesheet">
                                    <p:document href="content.generate-first-pagebreak.xsl"/>
                                </p:input>
                            </p:xslt>
                        </p:when>
                        <p:otherwise>
                            <!-- first document starts with a pagebreak; don't do anything -->
                            <p:identity/>
                        </p:otherwise>
                    </p:choose>
                    <p:viewport match="html:html">
                        <p:add-attribute match="html:span[@class='page-normal' or @class='page-special' or @class='page-front']" attribute-name="xml:base">
                            <p:with-option name="attribute-value" select="/*/@xml:base"/>
                        </p:add-attribute>
                        <p:add-attribute match="html:span[@class='page-normal' or @class='page-special' or @class='page-front']" attribute-name="original-base">
                            <p:with-option name="attribute-value" select="/*/@original-base"/>
                        </p:add-attribute>
                    </p:viewport>
                    <p:xslt>
                        <!-- replace all pagebreaks with their preceding pagebreak -->
                        <p:input port="parameters">
                            <p:empty/>
                        </p:input>
                        <p:input port="stylesheet">
                            <p:document href="content.move-pagebreaks-1of3.xsl"/>
                        </p:input>
                    </p:xslt>
                    <p:xslt>
                        <!-- move all linebreaks at the start of a page to the end of the preceding page -->
                        <p:input port="parameters">
                            <p:empty/>
                        </p:input>
                        <p:input port="stylesheet">
                            <p:document href="content.move-pagebreaks-2of3.xsl"/>
                        </p:input>
                    </p:xslt>
                    <p:xslt name="content-flow-iterate.move-pages.content.annotated">
                        <!-- <span/>s should not be the direct children of <body/>. Move to / wrap in <div/>s as appropriate. -->
                        <p:input port="parameters">
                            <p:empty/>
                        </p:input>
                        <p:input port="stylesheet">
                            <p:document href="content.move-pagebreaks-3of3.xsl"/>
                        </p:input>
                    </p:xslt>
                    <p:xslt name="content-flow-iterate.move-pages.content.mapping">
                        <p:input port="parameters">
                            <p:empty/>
                        </p:input>
                        <p:input port="stylesheet">
                            <p:document href="content.make-pagebreak-mapping.xsl"/>
                        </p:input>
                    </p:xslt>
                    <p:delete match="html:span[@class='page-normal' or @class='page-special' or @class='page-front']/@*[name()='original-base' or name() = 'xml:base']">
                        <p:input port="source">
                            <p:pipe step="content-flow-iterate.move-pages.content.annotated" port="result"/>
                        </p:input>
                    </p:delete>
                </p:otherwise>
            </p:choose>
            <p:sink/>
            
            <p:insert match="/*" position="first-child">
                <p:input port="source">
                    <p:pipe step="content" port="ncc-navigation"/>
                </p:input>
                <p:input port="insertion">
                    <p:pipe step="content-flow-iterate.move-pages.content" port="moved-pages-mapping"/>
                </p:input>
            </p:insert>
            <p:viewport match="/*/*[1]/*">
                <p:add-attribute match="/*" attribute-name="from">
                    <p:with-option name="attribute-value" select="substring-after(/*/@from,$publication-dir)"/>
                </p:add-attribute>
                <p:add-attribute match="/*" attribute-name="to">
                    <p:with-option name="attribute-value" select="substring-after(/*/@to,$publication-dir)"/>
                </p:add-attribute>
            </p:viewport>
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="content.fix-ncc-pagerefs.xsl"/>
                </p:input>
            </p:xslt>
            <p:identity name="content-flow-iterate.ncc-fixed-pagerefs"/>
            <p:sink/>

            <p:choose name="content-flow-iterate.move-pages.insert-ncc">
                <p:when test=".=0">
                    <p:xpath-context>
                        <p:pipe step="content-flow-iterate.move-pages.ncc-position" port="result"/>
                    </p:xpath-context>
                    <p:identity>
                        <p:input port="source">
                            <p:pipe step="content-flow-iterate.move-pages.content" port="content"/>
                        </p:input>
                    </p:identity>
                </p:when>
                <p:otherwise>
                    <p:choose>
                        <p:when test=".=1">
                            <p:xpath-context>
                                <p:pipe step="content-flow-iterate.move-pages.ncc-position" port="result"/>
                            </p:xpath-context>
                            <p:insert match="/*/*[1]" position="before">
                                <p:input port="insertion">
                                    <p:pipe step="content-flow-iterate.ncc-fixed-pagerefs" port="result"/>
                                </p:input>
                                <p:input port="source">
                                    <p:pipe step="content-flow-iterate.move-pages.content" port="content"/>
                                </p:input>
                            </p:insert>
                        </p:when>
                        <p:otherwise>
                            <p:insert position="after">
                                <p:with-option name="match" select="concat('/*/*[position() = (',(.-1),',last())]')">
                                    <p:pipe step="content-flow-iterate.move-pages.ncc-position" port="result"/>
                                </p:with-option>
                                <p:input port="insertion">
                                    <p:pipe step="content-flow-iterate.ncc-fixed-pagerefs" port="result"/>
                                </p:input>
                                <p:input port="source">
                                    <p:pipe step="content-flow-iterate.move-pages.content" port="content"/>
                                </p:input>
                            </p:insert>
                        </p:otherwise>
                    </p:choose>
                </p:otherwise>
            </p:choose>
            <p:for-each name="content-flow-iterate.move-pages.result">
                <p:output port="result" primary="true" sequence="true"/>
                <p:iteration-source select="/*/*"/>
                <p:identity/>
            </p:for-each>
        </p:group>

        <p:for-each name="content-flow-iterate.result">
            <p:output port="content" primary="true" sequence="true">
                <p:pipe step="content-flow-iterate.result.content" port="result"/>
            </p:output>
            <p:output port="content-with-original-base" sequence="true">
                <p:pipe step="content-flow-iterate.result.content-with-original-base" port="result"/>
            </p:output>
            <p:variable name="original-base" select="/*/@original-base"/>
            <p:identity name="content-flow-iterate.result.this"/>
            <p:delete match="/*/@original-base" name="content-flow-iterate.result.content"/>
            <p:add-attribute attribute-name="xml:base" match="/*" name="content-flow-iterate.result.content-with-original-base">
                <p:with-option name="attribute-value" select="$original-base"/>
                <p:input port="source">
                    <p:pipe step="content-flow-iterate.result.this" port="result"/>
                </p:input>
            </p:add-attribute>
            <p:sink/>
        </p:for-each>

        <p:for-each name="content-flow-iterate.store-content">
            <p:output port="store-complete" sequence="true">
                <p:pipe step="content-flow-iterate.store-content.store-complete" port="result"/>
            </p:output>
            <p:variable name="result-base" select="/*/@xml:base"/>
            <p:delete match="/*/@xml:base"/>
            <p:store indent="true" name="content-flow-iterate.store-content.store-complete">
                <p:with-option name="href" select="$result-base"/>
            </p:store>
        </p:for-each>
    </p:group>

    <p:for-each>
        <p:output port="result" sequence="true"/>
        <p:iteration-source>
            <p:pipe port="content" step="content-flow-iterate"/>
        </p:iteration-source>
        <p:variable name="uri" select="/*/@xml:base"/>
        <p:identity>
            <p:input port="source">
                <p:inline>
                    <d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data">
                        <d:file media-type="application/xhtml+xml"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </p:identity>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="replace($uri,'(.*/)[^/]*$','$1')"/>
        </p:add-attribute>
        <p:add-attribute match="/*/*" attribute-name="href">
            <p:with-option name="attribute-value" select="replace($uri,'.*/([^/]*)$','$1')"/>
        </p:add-attribute>
    </p:for-each>
    <px:fileset-join name="manifest"/>
    <p:sink/>

    <p:group name="fix-smil-pagebreak-references">
        <p:output port="result" primary="true" sequence="true"/>
        <p:wrap-sequence wrapper="wrapper">
            <p:input port="source">
                <p:pipe port="daisy-smil" step="content"/>
            </p:input>
        </p:wrap-sequence>
        <p:insert match="/*" position="first-child">
            <p:input port="insertion">
                <p:pipe port="moved-pages-mapping" step="content-flow-iterate"/>
            </p:input>
        </p:insert>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="content.fix-smil-pagebreak-references.xsl"/>
            </p:input>
        </p:xslt>
        <p:for-each>
            <p:iteration-source select="/*/*"/>
            <p:identity/>
        </p:for-each>
    </p:group>
    <p:sink/>

</p:declare-step>
