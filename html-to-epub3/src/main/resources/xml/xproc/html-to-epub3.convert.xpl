<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    type="px:html-to-epub3-convert" name="main" exclude-inline-prefixes="#all" version="1.0">

    <p:documentation>Transforms XHTML into an EPUB 3 publication.</p:documentation>

    <p:input port="input" primary="true" sequence="true"/>
    <p:input port="metadata" sequence="true">
        <p:empty/>
    </p:input>

    <p:output port="fileset.out" primary="true">
        <p:pipe port="result" step="ocf"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe port="result" step="in-memory.result"/>
    </p:output>

    <p:option name="output-dir" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/epub3-nav-utils/epub3-nav-library.xpl"/>
    <p:import
        href="http://www.daisy.org/pipeline/modules/epub3-ocf-utils/xproc/epub3-ocf-library.xpl"/>
    <p:import
        href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/xproc/epub3-pub-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/html-utils/html-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/mediatype.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="html-to-epub3.content.xpl"/>

    <p:variable name="epub-dir" select="concat($output-dir,'epub/')">
        <p:empty/>
    </p:variable>
    <p:variable name="content-dir" select="concat($epub-dir,'EPUB/')">
        <p:empty/>
    </p:variable>

    <!--=========================================================================-->
    <!-- COMPUTE THE RESOURCES FILESET                                           -->
    <!--=========================================================================-->

    <p:group name="html-resources">
        <p:output port="docs" primary="true" sequence="true"/>
        <p:output port="fileset">
            <p:pipe port="result" step="fileset"/>
        </p:output>
        <!--TODO pre-process resource-->
        <p:for-each name="html-cleaned">
            <p:output port="result" sequence="true"/>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="../xslt/html-clean-resources.xsl"/>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
            </p:xslt>
        </p:for-each>
        <p:for-each>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document
                        href="http://www.daisy.org/pipeline/modules/html-utils/html-to-fileset.xsl"
                    />
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
            </p:xslt>
        </p:for-each>
        <px:fileset-join/>
        <px:mediatype-detect name="fileset"/>
        <p:for-each>
            <p:iteration-source>
                <p:pipe port="result" step="html-cleaned"/>
            </p:iteration-source>
            <p:delete match="//@data-original-href"/>
        </p:for-each>
    </p:group>
    <!--TODO filter-out XHTML docs in the spine-->
    <!--TODO clean any out-of-spine XHTML docs-->

    <!--=========================================================================-->
    <!-- CLEAN THE XHTML                                                        -->
    <!--=========================================================================-->

    <p:documentation>Clean the XHTML Documents</p:documentation>
    <pxi:html-to-epub3-content name="html-content">
        <p:with-option name="publication-dir" select="$epub-dir">
            <p:empty/>
        </p:with-option>
        <p:with-option name="content-dir" select="$content-dir">
            <p:empty/>
        </p:with-option>
    </pxi:html-to-epub3-content>

    <!--=========================================================================-->
    <!-- GENERATE THE NAVIGATION DOCUMENT                                        -->
    <!--=========================================================================-->

    <p:documentation>Generate the EPUB 3 navigation document</p:documentation>
    <p:group name="navigation">

        <p:output port="fileset" primary="true">
            <p:pipe port="result" step="navigation.fileset"/>
        </p:output>
        <p:output port="doc">
            <p:pipe port="result" step="navigation.doc"/>
        </p:output>

        <p:variable name="nav-base" select="concat($content-dir,'toc.xhtml')">
            <p:empty/>
        </p:variable>

        <px:epub3-nav-create-toc name="navigation.toc">
            <p:input port="source">
                <p:pipe port="docs" step="html-content"/>
            </p:input>
            <p:with-option name="base-dir" select="$content-dir">
                <p:empty/>
            </p:with-option>
        </px:epub3-nav-create-toc>

        <px:epub3-nav-create-page-list name="navigation.page-list">
            <p:input port="source">
                <p:pipe port="docs" step="html-content"/>
            </p:input>
        </px:epub3-nav-create-page-list>
        <!--TODO create other nav types (configurable ?)-->

        <!--TODO epub3-nav-aggregate should allow setting the base URI-->
        <px:epub3-nav-aggregate>
            <p:input port="source">
                <p:pipe port="result" step="navigation.toc"/>
                <p:pipe port="result" step="navigation.page-list"/>
            </p:input>
        </px:epub3-nav-aggregate>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="$nav-base"/>
        </p:add-attribute>
        <p:delete match="/*/@xml:base" name="navigation.doc"/>


        <p:group name="navigation.fileset">
            <p:output port="result"/>
            <px:fileset-create>
                <p:with-option name="base" select="$content-dir"/>
            </px:fileset-create>
            <px:fileset-add-entry media-type="application/xml+xhtml">
                <p:with-option name="href" select="$nav-base"/>
            </px:fileset-add-entry>
            <cx:message message="Navigation Document Created."/>
        </p:group>
    </p:group>
    <p:sink/>


    <!--=========================================================================-->
    <!-- METADATA                                                                -->
    <!--=========================================================================-->

    <p:documentation>Extract metadata</p:documentation>
    <p:group name="metadata">
        <p:output port="result"/>
        <!--TODO adapt to multiple XHTML input docs-->
        <p:xslt>
            <p:input port="source">
                <p:pipe port="docs" step="html-content"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/html-to-metadata.xsl"/>
            </p:input>
        </p:xslt>
    </p:group>
    <p:sink/>

    <!--=========================================================================-->
    <!-- GENERATE THE PACKAGE DOCUMENT                                           -->
    <!--=========================================================================-->
    <p:documentation>Generate the EPUB 3 package document</p:documentation>
    <p:group name="package-doc">

        <p:output port="fileset" primary="true"/>
        <p:output port="doc">
            <p:pipe port="result" step="package-doc.create"/>
        </p:output>

        <p:variable name="opf-base" select="concat($content-dir,'package.opf')"/>

        <p:group name="resources">
            <p:output port="result"/>
            <p:add-attribute match="/*" attribute-name="xml:base">
                <p:with-option name="attribute-value" select="$content-dir"/>
                <p:input port="source">
                    <p:pipe port="fileset" step="html-resources"/>
                </p:input>
            </p:add-attribute>
        </p:group>
        <p:sink/>
        <px:epub3-pub-create-package-doc name="package-doc.create">
            <p:input port="spine-filesets">
                <p:pipe port="fileset" step="html-content"/>
            </p:input>
            <p:input port="publication-resources">
                <p:pipe port="result" step="resources"/>
            </p:input>
            <p:input port="metadata">
                <p:pipe port="metadata" step="main"/>
                <p:pipe port="result" step="metadata"/>
            </p:input>
            <p:input port="content-docs">
                <p:pipe port="doc" step="navigation"/>
                <p:pipe port="docs" step="html-content"/>
            </p:input>
            <p:with-option name="result-uri" select="$opf-base"/>
            <p:with-option name="compatibility-mode" select="'false'"/>
            <!--TODO configurability for other META-INF files ?-->
        </px:epub3-pub-create-package-doc>

        <px:fileset-join name="package-doc.join-filesets">
            <p:input port="source">
                <p:pipe port="fileset" step="html-content"/>
                <p:pipe port="fileset" step="navigation"/>
                <p:pipe port="result" step="resources"/>
            </p:input>
        </px:fileset-join>

        <px:fileset-add-entry media-type="application/oebps-package+xml">
            <p:input port="source">
                <p:pipe port="result" step="package-doc.join-filesets"/>
            </p:input>
            <p:with-option name="href" select="$opf-base"/>
        </px:fileset-add-entry>

        <cx:message message="Package Document Created."/>
    </p:group>
    <p:sink/>

    <p:group name="fileset.without-ocf">
        <p:output port="result"/>
        <!--TODO clean file set for non-existing files ?-->
        <px:fileset-create name="fileset.with-epub-base">
            <p:with-option name="base" select="$epub-dir"/>
        </px:fileset-create>
        <px:fileset-join>
            <p:input port="source">
                <p:pipe port="result" step="fileset.with-epub-base"/>
                <p:pipe port="fileset" step="package-doc"/>
            </p:input>
        </px:fileset-join>
    </p:group>
    <p:sink/>

    <px:epub3-ocf-finalize name="ocf">
        <p:input port="source">
            <p:pipe port="result" step="fileset.without-ocf"/>
        </p:input>
    </px:epub3-ocf-finalize>


    <p:for-each name="in-memory.result">
        <p:output port="result" sequence="true"/>
        <p:iteration-source>
            <p:pipe step="ocf" port="in-memory.out"/>
            <p:pipe step="package-doc" port="doc"/>
            <p:pipe step="navigation" port="doc"/>
            <p:pipe step="html-content" port="docs"/>
        </p:iteration-source>
        <p:variable name="doc-base" select="base-uri(/*)"/>
        <p:choose>
            <p:xpath-context>
                <p:pipe port="result" step="ocf"/>
            </p:xpath-context>
            <p:when test="//d:file[resolve-uri(@href,base-uri(.)) = $doc-base]">
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
