<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" version="1.0">
    <p:pipeinfo>
        <!--cd:converter name="zedai-to-epub3" version="1.0"
            xmlns:cd="http://www.daisy.org/ns/pipeline/converter">
            <cd:description>Transforms a ZedAI (DAISY 4 XML) document into an EPUB 3
                publication.</cd:description>
            <cd:arg name="source" type="input" port="source" desc="Path to input ZedAI."/>
            <cd:arg name="output" type="option" bind="output-dir" desc="Path to output directory for the EPUB."/>
        </cd:converter-->
    </p:pipeinfo>
    <p:documentation xd:target="parent">
        <xd:short>zedai-to-epub3</xd:short>
        <xd:detail>Transforms a ZedAI (DAISY 4 XML) document into an EPUB 3
                publication.</xd:detail>
    </p:documentation>
    <p:input port="source" primary="true" px:name="source"
        px:media-type="application/x-Z39.86-AI+xml">
        <p:documentation>
            <xd:short>source</xd:short>
            <xd:detail>Path to input ZedAI.</xd:detail>
        </p:documentation>
    </p:input>
    <p:input port="parameters" kind="parameter"/>

    <p:option name="output-dir" required="true" px:dir="output"
        px:type="anyDirURI">
        <p:documentation>
            <xd:short>output-dir</xd:short>
            <xd:detail>Path to output directory for the EPUB.</xd:detail>
        </p:documentation>
    </p:option>

    <p:import
        href="http://www.daisy.org/pipeline/modules/epub3-nav-utils/epub3-nav-library.xpl"/>
    <p:import
        href="http://www.daisy.org/pipeline/modules/epub3-ocf-utils/xproc/epub3-ocf-library.xpl"/>
    <p:import
        href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/xproc/epub3-pub-library.xpl"/>
    <p:import
        href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <!--<p:variable name="epub-file"
        select="p:resolve-uri(
        if ($output='') then concat(
        if (matches($href,'[^/]+\..+$'))
        then replace(tokenize($href,'/')[last()],'\..+$','')
        else tokenize($href,'/')[last()],'.epub')
        else if (ends-with($output,'.epub')) then $output 
        else concat($output,'.epub'))"/>-->
    <p:variable name="zedai-base" select="p:base-uri()"/>
    <p:variable name="zedai-basedir"
        select="replace($zedai-base,'^(.+/)[^/]*','$1')"/>
    <p:variable name="zedai-basename"
        select="replace($zedai-base,'.*/([^/]+)(\.[^.]+)','$1')"/>
    <p:variable name="output-dir-absolute"
        select="p:resolve-uri(if (ends-with($output-dir,'/')) then $output-dir else concat($output-dir,'/'))"/>
    <p:variable name="epub-dir" select="concat($output-dir-absolute,'epub/')"/>
    <p:variable name="epub-file"
        select="concat($output-dir-absolute,$zedai-basename,'.epub')"/>
    <p:variable name="content-dir" select="concat($epub-dir,'Content/')"/>

    <!--=========================================================================-->
    <!-- INITIALIZATION                                                          -->
    <!--=========================================================================-->

    <p:documentation>Prepare the ZedAI Document</p:documentation>
    <p:group name="initialization">
        <p:output port="result"/>
        <p:identity/>
        <p:add-xml-base/>
        <!--TODO process xincludes-->
    </p:group>
    <p:sink/>

    <px:fileset-create name="fileset-content-base">
        <p:with-option name="base" select="$content-dir"/>
    </px:fileset-create>
    <px:fileset-create name="fileset-epub-base">
        <p:with-option name="base" select="$epub-dir"/>
    </px:fileset-create>

    <!--=========================================================================-->
    <!-- METADATA                                                                -->
    <!--=========================================================================-->

    <p:documentation>Extract metadata from ZedAI</p:documentation>
    <p:group name="metadata">
        <p:output port="result"/>
        <p:identity>
            <!--TODO handle metadata-->
            <p:input port="source">
                <p:inline>
                    <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
                        <dc:identifier id="pub-id">TODO</dc:identifier>
                        <dc:title>TODO</dc:title>
                        <dc:language>en</dc:language>
                        <meta property="dcterms:modified"
                            >2011-09-05T11:30:00Z</meta>
                    </metadata>
                </p:inline>
            </p:input>
        </p:identity>
    </p:group>

    <!--=========================================================================-->
    <!-- CONVERT TO XHTML                                                        -->
    <!--=========================================================================-->

    <p:documentation>Convert the ZedAI Document into several XHTML Documents</p:documentation>
    <p:group name="zedai-to-html">
        <p:output port="result" primary="true"/>
        <p:output port="html-files" sequence="true">
            <p:pipe port="secondary" step="zedai-to-html.html-chunks"/>
        </p:output>
        <p:xslt name="zedai-to-html.html-single">
            <p:input port="source">
                <p:pipe port="result" step="initialization"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document
                    href="http://www.daisy.org/pipeline/modules/zedai-to-html/xslt/zedai-to-html.xsl"
                />
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:add-attribute attribute-name="xml:base" match="/*">
            <p:with-option name="attribute-value"
                select="concat($content-dir,$zedai-basename,'.xhtml')"/>
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
            <p:iteration-source>
                <p:pipe port="secondary" step="zedai-to-html.html-chunks"/>
            </p:iteration-source>
            <p:store indent="true" encoding="utf-8" method="xhtml">
                <p:with-option name="href" select="base-uri(/*)"/>
            </p:store>
            <px:fileset-add-entry media-type="application/xhtml+xml">
                <p:input port="source">
                    <p:pipe port="result" step="fileset-content-base"/>
                </p:input>
                <p:with-option name="href" select="base-uri(/*)">
                    <p:pipe port="current" step="zedai-to-html.iterate"/>
                </p:with-option>
            </px:fileset-add-entry>
        </p:for-each>
        <px:fileset-join/>
    </p:group>

    <!--=========================================================================-->
    <!-- GENERATE THE NAVIGATION DOCUMENT                                        -->
    <!--=========================================================================-->

    <p:documentation>Generate the EPUB 3 navigation document</p:documentation>
    <p:group name="navigation-doc">
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
            <p:variable name="nav-base"
                select="concat($content-dir,'toc.xhtml')"/>
            <p:store indent="true" encoding="utf-8" method="xhtml">
                <p:with-option name="href" select="$nav-base"/>
            </p:store>
            <px:fileset-add-entry media-type="application/xml+xhtml"
                name="navigation-doc.result.fileset">
                <p:input port="source">
                    <p:pipe port="result" step="fileset-content-base"/>
                </p:input>
                <p:with-option name="href" select="$nav-base"/>
            </px:fileset-add-entry>
            <p:add-attribute match="/*" attribute-name="xml:base"
                name="navigation-doc.result.html-file">
                <p:input port="source">
                    <p:pipe port="result" step="navigation-doc.html-file"/>
                </p:input>
                <p:with-option name="attribute-value" select="$nav-base"/>
            </p:add-attribute>
        </p:group>
    </p:group>

    <!--=========================================================================-->
    <!-- EXTRACT RESOURCES                                                       -->
    <!--=========================================================================-->

    <p:documentation>Extract local resources referenced from the XHTML</p:documentation>
    <p:group name="resources">
        <p:output port="result"/>
        <!--TODO call html-utils to get a file set of resource from the XHTML docs-->
        <!--TODO local only or all resources ?-->
        <!--TODO copy resources to the epub dir-->
        <p:for-each>
            <p:iteration-source>
                <p:pipe port="html-files" step="zedai-to-html"/>
            </p:iteration-source>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="../xslt/html-get-resources.xsl"/>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
            </p:xslt>
        </p:for-each>
        <px:fileset-join/>
        <p:string-replace match="/*/@xml:base">
            <p:with-option name="replace"
                select="concat('&quot;',$zedai-basedir,'&quot;')"/>
        </p:string-replace>
        <!--TODO detect unknown media types-->
        <!--<px:mediatype-detect/>-->
        <px:fileset-copy>
            <p:with-option name="target" select="$content-dir"/>
        </px:fileset-copy>
    </p:group>

    <!--=========================================================================-->
    <!-- GENERATE THE PACKAGE DOCUMENT                                           -->
    <!--=========================================================================-->
    <p:documentation>Generate the EPUB 3 navigation document</p:documentation>
    <p:group name="package-doc">
        <p:output port="result">
            <!--            <p:pipe port="result" step="package-doc.create"/>-->
        </p:output>
        
        <px:fileset-join name="package-doc.join-filesets">
            <p:input port="source">
                <p:pipe port="result" step="zedai-to-html"/>
                <p:pipe port="result" step="navigation-doc"/>
                <p:pipe port="result" step="resources"/>
            </p:input>
        </px:fileset-join>
        <p:sink/>
        
        <px:epub3-pub-create-package-doc name="package-doc.create">
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
                <p:pipe port="result" step="navigation-doc"/>
                <p:pipe port="html-files" step="zedai-to-html"/>
            </p:input>
            <p:with-option name="result-uri"
                select="concat($content-dir,'package.opf')"/>
            <!--TODO configurability for other META-INF files ?-->
        </px:epub3-pub-create-package-doc>

        <p:group>
            <p:variable name="opf-base"
                select="concat($content-dir,'package.opf')"/>
            <p:store media-type="application/oebps-package+xml" indent="true"
                encoding="utf-8" omit-xml-declaration="false">
                <p:with-option name="href" select="$opf-base"/>
            </p:store>
            <px:fileset-add-entry media-type="application/oebps-package+xml">
                <p:input port="source">
                    <p:pipe port="result" step="package-doc.join-filesets"/>
                </p:input>
                <p:with-option name="href" select="$opf-base"/>
            </px:fileset-add-entry>
        </p:group>
    </p:group>
    <!--=========================================================================-->
    <!-- BUILD THE EPUB PUBLICATION                                              -->
    <!--=========================================================================-->

    <p:documentation>Build the EPUB 3 Publication</p:documentation>
    <p:group name="epub">
        <p:output port="result"/>
        <px:fileset-join name="epub.fileset">
            <p:input port="source">
                <p:pipe port="result" step="package-doc"/>
                <p:pipe port="result" step="fileset-epub-base"/>
            </p:input>
        </px:fileset-join>
        <p:sink/>
        <!--seems to be required to *not* connect non-primary ports on ocf-finalize-->
        <px:epub3-ocf-finalize>
            <p:input port="source">
                <p:pipe port="result" step="epub.fileset"/>
            </p:input>
        </px:epub3-ocf-finalize>
        <px:epub3-ocf-zip>
            <p:with-option name="target" select="$epub-file"/>
        </px:epub3-ocf-zip>
    </p:group>
    <p:sink/>


</p:declare-step>
