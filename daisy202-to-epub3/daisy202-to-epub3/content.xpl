<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:mo="http://www.w3.org/ns/SMIL"
    xmlns:epub="http://www.idpf.org/2007/ops"
    type="pxi:daisy202-to-epub3-content" name="content" version="1.0">

    <p:input port="content-flow" primary="true" sequence="true"/>
    <p:input port="daisy-smil" sequence="true"/>
    <p:input port="ncc-navigation" sequence="true"/>
    <p:input port="ncc-navigation-original-base"/>

    <p:output port="content-with-original-base" sequence="true">
        <p:pipe port="content-with-original-base" step="content-flow-iterate"/>
    </p:output>
    <p:output port="content" sequence="true">
        <p:pipe port="content" step="content-flow-iterate"/>
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
    <p:import
        href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import
        href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/join.xpl"/>
    <p:import
        href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/upgrade-smil.xpl"/>
    <p:import
        href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/rearrange.xpl"/>
    <p:import
        href="http://www.daisy.org/pipeline/modules/html-utils/html-library.xpl"/>

    <p:add-xml-base all="true" relative="false"/>
    <p:for-each name="content-flow-iterate">
        <p:output port="content-with-original-base" primary="false"
            sequence="true">
            <p:pipe port="content-with-original-base"
                step="content-flow-iterate.choose"/>
        </p:output>
        <p:output port="content" primary="false" sequence="true">
            <p:pipe port="content" step="content-flow-iterate.choose"/>
        </p:output>
        <p:output port="store-complete" sequence="true">
            <p:pipe port="store-complete" step="content-flow-iterate.choose"/>
        </p:output>
        <p:iteration-source select="/*/*"/>
        <p:variable name="original-uri"
            select="p:resolve-uri(/*/@href,/*/@xml:base)"/>
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
        <p:choose name="content-flow-iterate.choose">
            <p:when
                test="lower-case(substring-after($original-uri,$daisy-dir))='ncc.html'">
                <p:output port="content-with-original-base" sequence="true">
                    <p:pipe port="ncc-navigation-original-base" step="content"/>
                </p:output>
                <p:output port="content" sequence="true">
                    <p:pipe port="result"
                        step="content-flow-iterate.choose.when.content-with-result-base"
                    />
                </p:output>
                <p:output port="store-complete" sequence="true">
                    <p:empty/>
                </p:output>

                <p:add-attribute match="/*" attribute-name="xml:base"
                    name="content-flow-iterate.choose.when.content-with-result-base">
                    <p:input port="source">
                        <p:pipe port="ncc-navigation" step="content"/>
                    </p:input>
                    <p:with-option name="attribute-value"
                        select="concat($publication-dir,'navigation.xhtml')"/>
                </p:add-attribute>
            </p:when>
            <p:otherwise>
                <p:output port="content-with-original-base" sequence="true">
                    <p:pipe port="result"
                        step="content-flow-iterate.choose.otherwise.content-with-original-base"
                    />
                </p:output>
                <p:output port="content" sequence="true">
                    <p:pipe port="result"
                        step="content-flow-iterate.choose.otherwise.content-with-result-base"
                    />
                </p:output>
                <p:output port="store-complete" sequence="true">
                    <p:pipe port="result"
                        step="content-flow-iterate.choose.otherwise.store-content"
                    />
                </p:output>

                <px:html-load>
                    <p:with-option name="href" select="$original-uri"/>
                </px:html-load>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="$original-uri"
                    />
                </p:add-attribute>
                <pxi:daisy202-to-epub3-resolve-links>
                    <p:input port="daisy-smil">
                        <p:pipe port="daisy-smil" step="content"/>
                    </p:input>
                </pxi:daisy202-to-epub3-resolve-links>
                <p:viewport
                    match="html:a[@href and not(matches(@href,'^[^/]+:'))]">
                    <p:add-attribute match="/*" attribute-name="href">
                        <p:with-option name="attribute-value"
                            select="concat(replace(tokenize(/*/@href,'#')[1],'^(.*)\.html$','$1.xhtml#'),if (contains(/*/@href,'#')) then tokenize(/*/@href,'#')[last()] else '')"
                        />
                    </p:add-attribute>
                </p:viewport>

                <p:delete match="/*/@xml:base"/>
                <p:xslt>
                    <p:with-param name="href" select="$result-uri"/>
                    <p:with-param name="pub-id" select="$pub-id"/>
                    <p:input port="stylesheet">
                        <p:document href="daisy202-content-to-epub3-content.xsl"
                        />
                    </p:input>
                </p:xslt>
                <p:insert match="/*" position="first-child">
                    <p:input port="insertion">
                        <p:pipe port="ncc-navigation" step="content"/>
                    </p:input>
                </p:insert>
                <p:xslt>
                    <p:with-param name="doc-href"
                        select="substring-after($result-uri,$publication-dir)"/>
                    <p:input port="stylesheet">
                        <p:document href="content.annotate-pagebreaks.xsl"/>
                    </p:input>
                </p:xslt>
                <p:identity name="content-flow-iterate.choose.otherwise.content"/>
                <!-- TODO: add html-lot-annotator.xsl here when it's done ? -->
                <!-- TODO: add html-loi-annotator.xsl here when it's done ? -->
                <p:store indent="true"
                    name="content-flow-iterate.choose.otherwise.store-content">
                    <p:with-option name="href" select="$result-uri"/>
                </p:store>
                <p:add-attribute match="/*" attribute-name="xml:base"
                    name="content-flow-iterate.choose.otherwise.content-with-result-base">
                    <p:with-option name="attribute-value" select="$result-uri"/>
                    <p:input port="source">
                        <p:pipe port="result"
                            step="content-flow-iterate.choose.otherwise.content"
                        />
                    </p:input>
                </p:add-attribute>
                <p:add-attribute match="/*" attribute-name="xml:base"
                    name="content-flow-iterate.choose.otherwise.content-with-original-base">
                    <p:with-option name="attribute-value" select="$original-uri"
                    />
                </p:add-attribute>
            </p:otherwise>
        </p:choose>
    </p:for-each>

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
            <p:with-option name="attribute-value"
                select="replace($uri,'(.*/)[^/]*$','$1')"/>
        </p:add-attribute>
        <p:add-attribute match="/*/*" attribute-name="href">
            <p:with-option name="attribute-value"
                select="replace($uri,'.*/([^/]*)$','$1')"/>
        </p:add-attribute>
    </p:for-each>
    <px:fileset-join name="manifest"/>
    <p:sink/>

</p:declare-step>
