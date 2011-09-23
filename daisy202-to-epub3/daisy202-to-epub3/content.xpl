<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:mo="http://www.w3.org/ns/SMIL"
    xmlns:epub="http://www.idpf.org/2007/ops" xmlns:xd="http://www.daisy.org/ns/pipeline/doc" type="pxi:daisy202-to-epub3-content" name="content" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>For processing the content.</xd:short>
    </p:documentation>

    <p:input port="content-flow" primary="true" sequence="true">
        <p:documentation>
            <xd:short>A fileset with references to the DAISY 2.02 content files, ordered by occurence in the DAISY 2.02 flow.</xd:short>
            <xd:example>
                <d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/home/user/daisy202/">
                    <d:file href="a.html" media-type="application/xhtml+xml"/>
                    <d:file href="b.html" media-type="application/xhtml+xml"/>
                    <d:file href="c.html" media-type="application/xhtml+xml"/>
                </d:fileset>
            </xd:example>
        </p:documentation>
    </p:input>
    <p:input port="daisy-smil" sequence="true">
        <p:documentation>
            <xd:short>The DAISY 2.02 SMIL-files.</xd:short>
            <xd:example xmlns="">
                <smil xml:base="file:/home/user/daisy202/a.smil">...</smil>
                <smil xml:base="file:/home/user/daisy202/b.smil">...</smil>
                <smil xml:base="file:/home/user/daisy202/c.smil">...</smil>
            </xd:example>
        </p:documentation>
    </p:input>
    <p:input port="ncc-navigation">
        <p:documentation>
            <xd:short>An EPUB3 Navigation Document, which if it contains a page-list will be used to annotate page-breaks in the content documents.</xd:short>
            <xd:example>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/navigation.xhtml" original-base="file:/home/user/daisy202/ncc.html">...</html>
            </xd:example>
        </p:documentation>
    </p:input>

    <p:output port="content" sequence="true">
        <p:documentation>
            <xd:short>The EPUB3 Content Documents.</xd:short>
            <xd:example>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/a.xhtml" original-base="file:/home/user/daisy202/a.html">...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/b.xhtml" original-base="file:/home/user/daisy202/b.html">...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/c.xhtml" original-base="file:/home/user/daisy202/c.html">...</html>
            </xd:example>
        </p:documentation>
        <p:pipe port="content" step="content-flow-iterate"/>
    </p:output>
    <p:output port="manifest">
        <p:documentation>
            <xd:short>A fileset with references to all the EPUB3 Content Documents.</xd:short>
            <xd:example>
                <d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/home/user/epub3/epub/Publication/Content/">
                    <d:file xml:base="a.xhtml" media-type="application/xhtml+xml"/>
                    <d:file xml:base="b.xhtml" media-type="application/xhtml+xml"/>
                    <d:file xml:base="c.xhtml" media-type="application/xhtml+xml"/>
                </d:fileset>
            </xd:example>
        </p:documentation>
        <p:pipe port="result" step="manifest"/>
    </p:output>
    <p:output port="store-complete" sequence="true">
        <p:documentation>
            <xd:short>The results from storing the EPUB3 Content Documents to disk.</xd:short>
            <xd:example>
                <c:result>file:/home/user/epub3/epub/Publication/Content/a.xhtml</c:result>
                <c:result>file:/home/user/epub3/epub/Publication/Content/b.xhtml</c:result>
                <c:result>file:/home/user/epub3/epub/Publication/Content/c.xhtml</c:result>
            </xd:example>
        </p:documentation>
        <p:pipe port="store-complete" step="content-flow-iterate"/>
    </p:output>

    <p:option name="daisy-dir" required="true">
        <p:documentation>
            <xd:short>URI to the DAISY 2.02 files.</xd:short>
            <xd:example>file:/home/user/daisy202/</xd:example>
        </p:documentation>
    </p:option>
    <p:option name="publication-dir" required="true">
        <p:documentation>
            <xd:short>URI to the EPUB3 Publication directory.</xd:short>
            <xd:example>file:/home/user/epub3/epub/Publication/</xd:example>
        </p:documentation>
    </p:option>
    <p:option name="content-dir" required="true">
        <p:documentation>
            <xd:short>URI to the EPUB3 Content directory.</xd:short>
            <xd:example>file:/home/user/epub3/epub/Publication/Content/</xd:example>
        </p:documentation>
    </p:option>

    <p:import href="resolve-links.xpl">
        <p:documentation>De-references links to SMIL-files.</p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl">
        <p:documentation>For manipulating filesets.</p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/html-utils/html-library.xpl">
        <p:documentation>For loading HTML-files.</p:documentation>
    </p:import>

    <p:add-xml-base all="true" relative="false"/>
    <p:group name="content-flow-iterate">
        <p:output port="content" primary="false" sequence="true">
            <p:pipe port="content" step="content-flow-iterate.result"/>
        </p:output>
        <p:output port="store-complete" sequence="true">
            <p:pipe port="store-complete" step="content-flow-iterate.store-content"/>
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

        <p:for-each name="content-flow-iterate.result">
            <p:output port="content" primary="true" sequence="true">
                <p:pipe step="content-flow-iterate.result.this" port="result"/>
            </p:output>
            <!--<p:output port="content-with-original-base" sequence="true">
                <p:pipe step="content-flow-iterate.result.content-with-original-base" port="result"/>
            </p:output>-->
            <p:variable name="original-base" select="/*/@original-base"/>
            <p:identity name="content-flow-iterate.result.this"/>
            <!--<p:delete match="/*/@original-base" name="content-flow-iterate.result.content"/>-->
            <!--<p:add-attribute attribute-name="xml:base" match="/*" name="content-flow-iterate.result.content-with-original-base">
                <p:with-option name="attribute-value" select="$original-base"/>
                <p:input port="source">
                    <p:pipe step="content-flow-iterate.result.this" port="result"/>
                </p:input>
            </p:add-attribute>-->
            <p:sink/>
        </p:for-each>

        <p:for-each name="content-flow-iterate.store-content">
            <p:output port="store-complete" sequence="true">
                <p:pipe step="content-flow-iterate.store-content.store-complete" port="result"/>
            </p:output>
            <p:variable name="result-base" select="/*/@xml:base"/>
            <p:delete match="/*/@xml:base|/*/@original-base"/>
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

</p:declare-step>
