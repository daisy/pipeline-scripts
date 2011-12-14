<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:xd="http://www.daisy.org/ns/pipeline/doc" type="px:zedai-to-epub3-convert"
    name="zedai-to-epub3.convert" exclude-inline-prefixes="#all" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>zedai-to-epub3</xd:short>
        <xd:detail>Transforms a ZedAI (DAISY 4 XML) document into an EPUB 3 publication.</xd:detail>
    </p:documentation>

    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true"/>

    <p:output port="fileset.out" primary="true">
        <p:pipe port="result" step="fileset.result"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe port="result" step="in-memory.result"/>
    </p:output>

    <p:option name="output-dir" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/epub3-nav-utils/epub3-nav-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-ocf-utils/xproc/epub3-ocf-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/xproc/epub3-pub-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <!--<p:variable name="zedai-base" select="p:base-uri()"/>-->
    <!--<p:variable name="zedai-basedir" select="replace($zedai-base,'^(.+/)[^/]*','$1')"/>-->
    <!--<p:variable name="zedai-basename" select="replace($zedai-base,'.*/([^/]+)(\.[^.]+)','$1')"/>-->
    <!--<p:variable name="output-dir-absolute" select="p:resolve-uri(if (ends-with($output-dir,'/')) then $output-dir else concat($output-dir,'/'))"/>-->
    <p:variable name="epub-dir" select="concat($output-dir,'epub/')"/>
    <!--<p:variable name="epub-file" select="concat($output-dir-absolute,$zedai-basename,'.epub')"/>-->
    <p:variable name="content-dir" select="concat($epub-dir,'Content/')"/>

    <!--=========================================================================-->
    <!-- GET ZEDAI FROM FILESET                                                  -->
    <!--=========================================================================-->

    <p:documentation>Retreive the ZedAI docuent from the input fileset.</p:documentation>
    <p:group name="zedai-input">
        <p:output port="result" primary="true">
            <p:pipe port="result" step="zedai-input.for-each"/>
        </p:output>
        <p:variable name="fileset-base" select="/*/@xml:base"/>
        <p:for-each name="zedai-input.for-each">
            <p:iteration-source select="/*/*"/>
            <p:output port="result" sequence="true"/>
            <p:choose>
                <p:when test="/*/@media-type = 'application/x-Z39.86-AI+xml'">
                    <p:variable name="zedai-base" select="p:resolve-uri(/*/@href,$fileset-base)"/>
                    <p:split-sequence name="zedai-input.for-each.split">
                        <p:input port="source">
                            <p:pipe port="in-memory.in" step="zedai-to-epub3.convert"/>
                        </p:input>
                        <p:with-option name="test" select="concat('/*/@xml:base = &quot;',$zedai-base,'&quot;')"/>
                    </p:split-sequence>
                    <p:count/>
                    <p:choose>
                        <p:when test=". &gt; 0">
                            <p:identity>
                                <p:input port="source">
                                    <p:pipe port="matched" step="zedai-input.for-each.split"/>
                                </p:input>
                            </p:identity>
                        </p:when>
                        <p:otherwise>
                            <cx:message>
                                <p:with-option name="message" select="concat('Input ZedAI not in memory, loading from disk: ', $zedai-base)"/>
                            </cx:message>
                            <p:load>
                                <p:with-option name="href" select="$zedai-base"/>
                            </p:load>
                        </p:otherwise>
                    </p:choose>
                    <p:delete match="/*/@xml:base"/>
                </p:when>
                <p:otherwise>
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                </p:otherwise>
            </p:choose>
        </p:for-each>
        <p:count/>
        <p:choose>
            <p:when test=". = 0">
                <p:error xmlns:err="http://www.w3.org/ns/xproc-error" code="PEZE00">
                    <!-- TODO: describe the error on the wiki and insert correct error code -->
                    <p:input port="source">
                        <p:inline>
                            <message>No XML documents with the ZedAI media type ('application/x-Z39.86-AI+xml') found in the fileset.</message>
                        </p:inline>
                    </p:input>
                </p:error>
                <p:sink/>
            </p:when>
            <p:when test=". &gt; 1">
                <p:error xmlns:err="http://www.w3.org/ns/xproc-error" code="PEZE00">
                    <!-- TODO: describe the error on the wiki and insert correct error code -->
                    <p:input port="source">
                        <p:inline>
                            <message>More than one XML document with the ZedAI media type ('application/x-Z39.86-AI+xml') found in the fileset; there can only
                                be one ZedAI document.</message>
                        </p:inline>
                    </p:input>
                </p:error>
                <p:sink/>
            </p:when>
            <p:otherwise>
                <p:sink/>
            </p:otherwise>
        </p:choose>
    </p:group>

    <!--=========================================================================-->
    <!-- METADATA                                                                -->
    <!--=========================================================================-->

    <p:documentation>Extract metadata from ZedAI</p:documentation>
    <p:group name="metadata">
        <p:output port="result"/>
        <p:xslt>
            <p:input port="source">
                <p:pipe port="result" step="zedai-input"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/zedai-to-metadata.xsl"/>
            </p:input>
        </p:xslt>
    </p:group>

    <!--=========================================================================-->
    <!-- CONVERT TO XHTML                                                        -->
    <!--=========================================================================-->

    <p:documentation>Convert the ZedAI Document into several XHTML Documents</p:documentation>
    <p:group name="zedai-to-html">
        <p:output port="result" primary="true" sequence="true"/>
        <p:output port="html-files" sequence="true">
            <p:pipe port="html-files" step="zedai-to-html.iterate"/>
        </p:output>
        <p:variable name="zedai-basename"
            select="replace(replace(//*[@media-type='application/x-Z39.86-AI+xml']/@href,'^.+/([^/]+)$','$1'),'^(.+)\.[^\.]+$','$1')">
            <p:pipe port="fileset.in" step="zedai-to-epub3.convert"/>
        </p:variable>
        <p:variable name="result-basename" select="concat($content-dir,$zedai-basename,'.xhtml')"/>
        <p:xslt name="zedai-to-html.html-single">
            <p:input port="source">
                <p:pipe port="result" step="zedai-input"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="http://www.daisy.org/pipeline/modules/zedai-to-html/xslt/zedai-to-html.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:add-attribute attribute-name="xml:base" match="/*">
            <p:with-option name="attribute-value" select="$result-basename"/>
        </p:add-attribute>
        <p:xslt name="zedai-to-html.html-with-ids">
            <p:input port="stylesheet">
                <p:document href="../xslt/html-id-fixer.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:xslt name="zedai-to-html.html-chunks">
            <!--<p:log port="secondary" href="file:/tmp/xproc/html-files.xml"/>-->
            <!--TODO fix links while chunking (see links-to-chunks) -->
            <p:input port="stylesheet">
                <p:document href="../xslt/html-chunker.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:sink/>
        <p:for-each name="zedai-to-html.iterate">
            <p:output port="fileset" primary="true"/>
            <p:output port="html-files" sequence="true">
                <p:pipe port="result" step="zedai-to-html.iterate.html"/>
            </p:output>
            <p:iteration-source>
                <p:pipe port="secondary" step="zedai-to-html.html-chunks"/>
            </p:iteration-source>
            <p:variable name="result-uri" select="base-uri(/*)"/>
            <p:add-xml-base name="zedai-to-html.iterate.html"/>
            <px:fileset-create>
                <p:with-option name="base" select="$content-dir"/>
            </px:fileset-create>
            <px:fileset-add-entry media-type="application/xhtml+xml">
                <p:with-option name="href" select="$result-uri"/>
            </px:fileset-add-entry>
        </p:for-each>
        <!--TODO epub3-pub-create-package-doc requires a sequence of filesets-->
        <px:fileset-join/>
    </p:group>

    <!--=========================================================================-->
    <!-- GENERATE THE NAVIGATION DOCUMENT                                        -->
    <!--=========================================================================-->

    <p:documentation>Generate the EPUB 3 navigation document</p:documentation>
    <p:group name="navigation-doc">
        <!--<p:log port="html-file" href="file:/tmp/xproc/nav-doc.xml"/>-->
        <p:output port="result" primary="true">
            <p:pipe port="fileset" step="navigation-doc.result"/>
        </p:output>
        <p:output port="html-file">
            <p:pipe port="html-file" step="navigation-doc.result"/>
        </p:output>
        <px:epub3-nav-create-toc name="navigation-doc.toc">
            <p:input port="source">
                <p:pipe port="html-files" step="zedai-to-html"/>
            </p:input>
            <p:with-option name="base-dir" select="$content-dir">
                <p:empty/>
            </p:with-option>
        </px:epub3-nav-create-toc>
        <px:epub3-nav-create-page-list name="navigation-doc.page-list">
            <p:input port="source">
                <p:pipe port="html-files" step="zedai-to-html"/>
            </p:input>
        </px:epub3-nav-create-page-list>
        <px:epub3-nav-aggregate name="navigation-doc.html-file">
            <p:input port="source">
                <p:pipe port="result" step="navigation-doc.toc"/>
                <p:pipe port="result" step="navigation-doc.page-list"/>
            </p:input>
        </px:epub3-nav-aggregate>
        <!--TODO create other nav types (configurable ?)-->
        <p:group name="navigation-doc.result">
            <p:output port="fileset">
                <p:pipe port="result" step="navigation-doc.result.fileset"/>
            </p:output>
            <p:output port="html-file">
                <p:pipe port="result" step="navigation-doc.result.html-file"/>
            </p:output>
            <p:variable name="nav-base" select="concat($content-dir,'toc.xhtml')"/>
            <px:fileset-create>
                <p:with-option name="base" select="$content-dir"/>
            </px:fileset-create>
            <px:fileset-add-entry media-type="application/xml+xhtml" name="navigation-doc.result.fileset">
                <p:with-option name="href" select="$nav-base"/>
            </px:fileset-add-entry>
            <p:add-attribute match="/*" attribute-name="xml:base" name="navigation-doc.result.html-file">
                <p:input port="source">
                    <p:pipe port="result" step="navigation-doc.html-file"/>
                </p:input>
                <p:with-option name="attribute-value" select="$nav-base"/>
            </p:add-attribute>
            <p:sink/>
        </p:group>
    </p:group>

    <!--=========================================================================-->
    <!-- GENERATE THE PACKAGE DOCUMENT                                           -->
    <!--=========================================================================-->
    <p:documentation>Generate the EPUB 3 navigation document</p:documentation>
    <p:group name="package-doc">
        <p:output port="result" primary="true"/>
        <p:output port="opf">
            <p:pipe port="result" step="package-doc.with-base"/>
        </p:output>

        <p:variable name="opf-base" select="concat($content-dir,'package.opf')"/>

        <p:identity>
            <p:input port="source">
                <p:pipe port="fileset.in" step="zedai-to-epub3.convert"/>
            </p:input>
        </p:identity>
        <p:group name="resources">
            <p:output port="result"/>
            <p:variable name="fileset-base" select="/*/@xml:base"/>
            <p:variable name="zedai-uri" select="p:resolve-uri(//d:file[@media-type='application/x-Z39.86-AI+xml']/@href,$fileset-base)"/>
            <p:delete match="d:file[@media-type='application/x-Z39.86-AI+xml']"/>
            <p:viewport match="/*/*">
                <p:documentation>Make sure that the files in the fileset is relative to the ZedAI file.</p:documentation>
                <p:variable name="original-uri" select="(/*/@xml:base, p:resolve-uri(/*/@href,$fileset-base))[1]"/>
                <p:xslt>
                    <p:with-param name="to" select="p:resolve-uri(/*/@href,$fileset-base)"/>
                    <p:with-param name="from" select="$zedai-uri"/>
                    <p:input port="stylesheet">
                        <p:inline>
                            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pf="http://www.daisy.org/ns/pipeline/functions" version="2.0">
                                <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
                                <xsl:param name="to" required="yes"/>
                                <xsl:param name="from" required="yes"/>
                                <xsl:template match="/*">
                                    <xsl:copy>
                                        <xsl:copy-of select="@*"/>
                                        <xsl:attribute name="href" select="pf:file-resolve-relative-uri($to,$from)"/>
                                    </xsl:copy>
                                </xsl:template>
                            </xsl:stylesheet>
                        </p:inline>
                    </p:input>
                </p:xslt>
                <p:identity/>
            </p:viewport>
            <p:add-attribute match="/*" attribute-name="xml:base">
                <p:with-option name="attribute-value" select="$content-dir"/>
            </p:add-attribute>
            <!-- TODO: remove resources from fileset that are not referenced from any of the in-memory files -->
        </p:group>

        <px:fileset-join name="package-doc.join-filesets">
            <p:input port="source">
                <p:pipe port="result" step="zedai-to-html"/>
                <p:pipe port="result" step="navigation-doc"/>
                <p:pipe port="result" step="resources"/>
            </p:input>
        </px:fileset-join>
        <p:sink/>

        <px:epub3-pub-create-package-doc name="package-doc.create">
            <!--<p:log port="result" href="file:/tmp/xproc/opf.xml"/>-->
            <p:input port="spine-filesets">
                <!--TODO include nav doc in the spine ?-->
                <p:pipe port="result" step="zedai-to-html"/>
            </p:input>
            <p:input port="publication-resources">
                <p:pipe port="result" step="resources"/>
            </p:input>
            <p:input port="metadata">
                <p:pipe port="result" step="metadata"/>
            </p:input>
            <p:input port="content-docs">
                <p:pipe port="html-file" step="navigation-doc"/>
                <p:pipe port="html-files" step="zedai-to-html"/>
            </p:input>
            <p:with-option name="result-uri" select="$opf-base"/>
            <p:with-option name="compatibility-mode" select="'false'"/>
            <!--TODO configurability for other META-INF files ?-->
        </px:epub3-pub-create-package-doc>
        <p:add-attribute match="/*" attribute-name="xml:base" name="package-doc.with-base">
            <p:with-option name="attribute-value" select="$opf-base"/>
        </p:add-attribute>

        <px:fileset-add-entry media-type="application/oebps-package+xml">
            <p:input port="source">
                <p:pipe port="result" step="package-doc.join-filesets"/>
            </p:input>
            <p:with-option name="href" select="$opf-base"/>
        </px:fileset-add-entry>
    </p:group>

    <p:group name="fileset.result">
        <p:output port="result"/>
        <p:variable name="fileset-base" select="/*/@xml:base"/>
        <p:identity name="fileset.dirty"/>
        <p:wrap-sequence wrapper="wrapper">
            <p:input port="source">
                <p:pipe step="package-doc" port="opf"/>
                <p:pipe step="navigation-doc" port="html-file"/>
                <p:pipe step="zedai-to-html" port="html-files"/>
            </p:input>
        </p:wrap-sequence>
        <p:delete match="/*/*/*" name="wrapped-in-memory"/>
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="fileset.dirty"/>
            </p:input>
        </p:identity>
        <p:viewport match="//d:file">
            <p:variable name="file-href" select="p:resolve-uri(/*/@href,$fileset-base)"/>
            <p:variable name="file-original" select="if (/*/@xml:base) then p:resolve-uri(/*/@xml:base,$fileset-base) else ''"/>
            <p:choose>
                <p:xpath-context>
                    <p:pipe port="result" step="wrapped-in-memory"/>
                </p:xpath-context>
                <p:when test="not($file-original) and not(/*/*[resolve-uri(@xml:base) = $file-href])">
                    <!-- Fileset contains file reference to a file that is neither stored on disk nor in memory; discard it -->
                    <p:sink/>
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                </p:when>
                <p:otherwise>
                    <!-- File refers to a document on disk or in memory; keep it -->
                    <p:identity/>
                </p:otherwise>
            </p:choose>
        </p:viewport>
    </p:group>

    <p:for-each name="in-memory.result">
        <p:output port="result" sequence="true"/>
        <p:iteration-source>
            <p:pipe step="package-doc" port="opf"/>
            <p:pipe step="navigation-doc" port="html-file"/>
            <p:pipe step="zedai-to-html" port="html-files"/>
        </p:iteration-source>
        <p:variable name="doc-base" select="/*/@xml:base"/>
        <p:variable name="fileset-base" select="/*/@xml:base">
            <p:pipe port="result" step="fileset.result"/>
        </p:variable>
        <p:choose>
            <p:xpath-context>
                <p:pipe port="result" step="fileset.result"/>
            </p:xpath-context>
            <p:when test="//d:file[resolve-uri(@href,$fileset-base) = resolve-uri($doc-base)]">
                <!-- document is in fileset; keep it -->
                <p:identity/>
            </p:when>
            <p:otherwise>
                <!-- document is not in fileset; discard it -->
                <p:sink/>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
    </p:for-each>

</p:declare-step>
