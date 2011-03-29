<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:px="http://pipeline.daisy.org/ns/"
    version="1.0" exclude-inline-prefixes="c cx px">

    <p:option name="href" required="true"/>
    <p:option name="output" select="''"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <!--FIXME import utils from absolute URIs-->
    <p:import href="../../../../utilities/files/fileset-library.xpl"/>
    <p:import href="../../../../utilities/zip/zip-library.xpl"/>
    <p:import href="handle-zedai-refs.xpl"/>

    <p:variable name="epub-file"
        select="resolve-uri(
                    if ($output='') then concat(
                        if (matches($href,'[^/]+\..+$'))
                        then replace(tokenize($href,'/')[last()],'\..+$','')
                        else tokenize($href,'/')[last()],'.epub')
                    else if (ends-with($output,'.epub')) then $output 
                    else concat($output,'.epub'))">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>
    <p:variable name="epub-dir" select="resolve-uri('epub/',$epub-file)"/>
    <p:variable name="content-dir" select="concat($epub-dir,'Content/')"/>

    <!--=========================================================================-->

    <!-- Get the input document from the href option-->
    <p:group name="initialization">
        <p:output port="result"/>
        <p:load name="load">
            <p:with-option name="href" select="resolve-uri($href)"/>
        </p:load>
        <p:add-xml-base/>
    </p:group>

    <!--=========================================================================-->

    <p:group name="files-collection">
        <p:output port="result" primary="false">
            <p:pipe port="result" step="handle-refs"/>
        </p:output>

        <!-- Get the list of satelite files -->
        <p:xslt name="get-refs" version="2.0">
            <p:input port="stylesheet">
                <p:document href="../xslt/get-zedai-refs.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <!-- Move the satellite files -->
        <!-- FIXME we need a procesor specific step for remote downloads -->
        <px:handle-refs name="handle-refs">
            <p:with-option name="output" select="$content-dir"/>
        </px:handle-refs>

    </p:group>


    <!--=========================================================================-->

    <!-- Normalize the source document -->
    <p:identity name="normalization">
        <p:input port="source">
            <p:pipe port="result" step="initialization"/>
        </p:input>
    </p:identity>

    <!--=========================================================================-->

    <p:group name="chunks-preparation">
        <p:output port="result"/>

        <!-- Identify Chunks -->
        <p:xslt name="chunk-marker">
            <p:input port="stylesheet">
                <p:document href="../xslt/chunk-marker.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <!-- Generate paths of chunks -->
        <p:xslt name="chunk-path-creator">
            <p:input port="stylesheet">
                <p:document href="../xslt/chunk-path-creator.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <!-- Replace document links to local paths -->
        <p:xslt name="links-to-chunks">
            <p:input port="stylesheet">
                <p:document href="../xslt/links-to-chunks.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

    </p:group>

    <!--=========================================================================-->

    <p:group name="ncx-creation">
        <p:output port="result">
            <p:pipe port="result" step="ncx-items-marker"/>
        </p:output>

        <!-- Identify NCX items -->
        <p:xslt name="ncx-items-marker">
            <p:input port="stylesheet">
                <p:document href="../xslt/ncx-items-marker.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <!-- Create NCX -->
        <p:xslt name="ncx-builder">
            <p:input port="stylesheet">
                <p:document href="../xslt/ncx-builder.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <!-- Store the result NCX -->
        <p:store media-type="application/x-dtbncx+xml" doctype-public="-//NISO//DTD ncx 2005-1//EN"
            doctype-system="http://www.daisy.org/z3986/2005/ncx-2005-1.dtd" indent="true"
            encoding="utf-8" omit-xml-declaration="false">
            <p:with-option name="href" select="concat($content-dir,'toc.ncx')"/>
        </p:store>

    </p:group>

    <!--=========================================================================-->

    <p:group name="opf-creation">
        <p:output port="result">
            <p:pipe port="result" step="opf-creation.collection"/>
            <!--            <p:pipe port="result" step="opf-creation.identity"/>-->
        </p:output>

        <p:identity name="opf-creation.identity"/>

        <p:wrap-sequence name="opf-creation.collection" wrapper="c:collection">
            <p:input port="source">
                <p:pipe step="files-collection" port="result"/>
                <p:pipe step="opf-creation.identity" port="result"/>
            </p:input>
        </p:wrap-sequence>

        <!-- Create OPF -->
        <p:xslt name="opf-builder" version="2.0" initial-mode="split">
            <p:input port="stylesheet">
                <p:document href="../xslt/opf-builder.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <!-- Store the result OPF -->
        <p:store media-type="application/oebps-package+xml" indent="true" encoding="utf-8"
            omit-xml-declaration="false">
            <p:with-option name="href" select="concat($content-dir,'package.opf')"/>
        </p:store>

    </p:group>

    <!--=========================================================================-->

    <!-- Transform into HTML -->
    <p:group name="zedai2html">
        <p:output port="result" primary="false">
            <p:pipe port="result" step="zedai2html.manifest"/>
        </p:output>

        <p:xslt name="zedai2html.xslt">
            <p:input port="stylesheet">
                <p:document href="../xslt/zedai2xhtml.xsl"/>
            </p:input>
            <p:with-param name="base" select="$content-dir"/>
        </p:xslt>
        <p:sink/>

        <p:for-each name="zedai2html.store">
            <p:iteration-source>
                <p:pipe step="zedai2html.xslt" port="secondary"/>
            </p:iteration-source>
            <p:store method="xhtml" indent="false">
                <p:with-option name="href" select="base-uri(/)"/>
            </p:store>
            <p:add-attribute attribute-name="href" match="*">
                <p:input port="source">
                    <p:inline>
                        <c:entry/>
                    </p:inline>
                </p:input>
                <p:with-option name="attribute-value" select="base-uri(/)">
                    <p:pipe port="current" step="zedai2html.store"/>
                </p:with-option>
            </p:add-attribute>
        </p:for-each>
        <p:wrap-sequence name="zedai2html.manifest" wrapper="c:manifest"/>

    </p:group>

    <!--=========================================================================-->

    <!-- OCF finalization -->
    <p:group name="ocf-finalization">

        <!-- Create container descriptor -->
        <p:add-attribute match="c:container/c:rootfiles/c:rootfile"
            xmlns:c="urn:oasis:names:tc:opendocument:xmlns:container" attribute-name="full-path">
            <p:input port="source">
                <p:inline exclude-inline-prefixes="c">
                    <container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
                        <rootfiles>
                            <rootfile media-type="application/oebps-package+xml"/>
                        </rootfiles>
                    </container>
                </p:inline>
            </p:input>
            <p:with-option name="attribute-value"
                select="concat(substring-after($content-dir,$epub-dir),'package.opf')"/>
        </p:add-attribute>
        <!-- Store container descriptor -->
        <p:store indent="true" encoding="utf-8" omit-xml-declaration="false">
            <p:with-option name="href" select="concat($epub-dir,'META-INF/container.xml')"/>
        </p:store>

        <!-- Create mimetype -->
        <p:string-replace match="doc/text()" replace="'application/epub+zip'">
            <p:input port="source">
                <p:inline>
                    <doc>@@</doc>
                </p:inline>
            </p:input>
        </p:string-replace>
        <p:string-replace match="/text()" replace="''"/>
        <p:store method="text">
            <p:with-option name="href" select="concat($epub-dir,'mimetype')"/>
        </p:store>

    </p:group>

    <!--=========================================================================-->

    <p:group name="fileset">
        <p:output port="result"/>
        <p:group name="fileset.core">
            <p:output port="result"/>
            <px:create-manifest>
                <p:with-option name="base" select="$epub-dir"/>
            </px:create-manifest>
            <px:add-manifest-entry href="mimetype"/>
            <px:add-manifest-entry href="META-INF/container.xml"/>
            <px:add-manifest-entry href="Content/package.opf"
                media-type="application/oebps-package+xml"/>
            <px:add-manifest-entry href="Content/toc.ncx" media-type="application/x-dtbncx+xml"/>
        </p:group>
        <px:join-manifests>
            <p:input port="source">
                <p:pipe port="result" step="fileset.core"/>
                <p:pipe port="result" step="zedai2html"/>
                <p:pipe port="result" step="files-collection"/>
            </p:input>
        </px:join-manifests>
    </p:group>

    <!--=========================================================================-->

    <!-- Create ZIP -->
    <p:group name="zip">
        <px:to-zip-manifest>
            <p:input port="source">
                <p:pipe port="result" step="fileset"/>
            </p:input>
        </px:to-zip-manifest>
        <p:add-attribute name="zip.manifest" match="c:entry[@name='mimetype']"
            attribute-name="compression-method" attribute-value="stored"/>
        <cx:zip>
            <p:input port="source">
                <p:empty/>
            </p:input>
            <p:input port="manifest">
                <p:pipe port="result" step="zip.manifest"/>
            </p:input>
            <p:with-option name="href" select="$epub-file"/>
        </cx:zip>
        <p:sink/>
    </p:group>

</p:declare-step>
