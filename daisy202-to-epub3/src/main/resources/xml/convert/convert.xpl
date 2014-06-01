<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:html="http://www.w3.org/1999/xhtml" type="px:daisy202-to-epub3-convert" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml"> Transforms DAISY 2.02 into EPUB3. </p:documentation>

    <p:input port="fileset.in" primary="true">
        <!-- TODO: This fileset is assumed to reference SMIL files and HTML files in reading order. px:daisy202-load provides this, but we could provide a step that rearranges the fileset according to the reading order for use by other scripts. -->
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">A fileset containing references to all the DAISY 2.02 files and any resources they reference (audio, images etc.). SMIL files and HTML files occur in reading order.</p:documentation>
    </p:input>

    <p:input port="in-memory.in" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">The part of the DAISY 2.02 fileset that is loaded into memory.</p:documentation>
    </p:input>

    <p:output port="fileset.out" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">A fileset containing references to the EPUB3 files.</p:documentation>
        <p:pipe port="result" step="result.fileset"/>
    </p:output>

    <p:output port="in-memory.out" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">The part of the resulting EPUB3 fileset that is stored in memory.</p:documentation>
        <p:pipe port="result" step="result.in-memory"/>
    </p:output>

    <p:option name="output-dir" required="true" px:dir="output" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">The directory that the EPUB3 fileset is intended to be stored in.</p:documentation>
    </p:option>

    <p:option name="mediaoverlay" required="false" select="'true'" px:type="boolean"/>
    <p:option name="compatibility-mode" required="false" select="'true'" px:type="boolean"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl"/>

    <p:import href="resolve-links.create-mapping.xpl"/>
    <p:import href="ncc-navigation.xpl"/>
    <p:import href="navigation.xpl"/>
    <p:import href="content.xpl"/>
    <p:import href="media-overlay.xpl"/>
    <p:import href="resources.xpl"/>
    <p:import href="package.xpl"/>

    <p:variable name="epub-dir" select="concat($output-dir,'epub/')"/>
    <p:variable name="publication-dir" select="concat($epub-dir,'EPUB/')"/>
    <p:variable name="content-dir" select="concat($publication-dir,'Content/')"/>
    <p:variable name="daisy-dir" select="base-uri(/*)">
        <p:pipe port="fileset.in" step="main"/>
    </p:variable>

    <!-- Make a fileset and a document sequence of all the SMIL files in reading order -->
    <px:fileset-load media-types="application/smil+xml" name="smil-flow.in-memory">
        <p:input port="fileset">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>

    <!-- Make a map of all links from the SMIL files to the HTML files -->
    <pxi:daisy202-to-epub3-resolve-links-create-mapping name="resolve-links-mapping">
        <p:input port="daisy-smil">
            <p:pipe port="result" step="smil-flow.in-memory"/>
        </p:input>
    </pxi:daisy202-to-epub3-resolve-links-create-mapping>
    <p:sink/>

    <!-- Make a Navigation Document based on the DAISY 2.02 NCC. -->

    <px:fileset-load media-types="application/xhtml+xml text/html" href="*/ncc.html">
        <p:input port="fileset">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>
    <p:split-sequence initial-only="true" test="position()=1"/>
    <p:group name="ncc">
        <p:output port="result" primary="true">
            <p:pipe port="result" step="ncc.ncc"/>
        </p:output>
        <p:output port="pub-id">
            <p:pipe port="result" step="ncc.pub-id"/>
        </p:output>
        <p:identity name="ncc.ncc"/>
        <p:count/>
        <p:choose>
            <p:when test="/*='0'">
                <p:in-scope-names name="vars"/>
                <p:template name="error-message">
                    <p:input port="source">
                        <p:pipe port="result" step="ncc.ncc"/>
                    </p:input>
                    <p:input port="template">
                        <p:inline exclude-inline-prefixes="#all">
                            <message>There is no "ncc.html" file in the fileset.</message>
                        </p:inline>
                    </p:input>
                    <p:input port="parameters">
                        <p:pipe step="vars" port="result"/>
                    </p:input>
                </p:template>
                <p:error code="PDE06">
                    <p:input port="source">
                        <p:pipe port="result" step="error-message"/>
                    </p:input>
                </p:error>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="result" step="ncc.ncc"/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:add-attribute name="pub-id" match="/*" attribute-name="value">
            <p:with-option name="attribute-value" select="/html:html/html:head/html:meta[@name='dc:identifier']/@content"/>
            <p:input port="source">
                <p:inline>
                    <d:meta name="pub-id"/>
                </p:inline>
            </p:input>
        </p:add-attribute>
        <p:identity name="ncc.pub-id"/>
    </p:group>
    <pxi:daisy202-to-epub3-ncc-navigation name="ncc-navigation">
        <p:with-option name="publication-dir" select="$publication-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:input port="resolve-links-mapping">
            <p:pipe port="result" step="resolve-links-mapping"/>
        </p:input>
    </pxi:daisy202-to-epub3-ncc-navigation>
    <p:sink/>

    <!-- Convert the content files. -->
    <px:fileset-load media-types="application/xhtml+xml text/html">
        <p:input port="fileset">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>
    <p:for-each>
        <p:choose>
            <p:when test="matches(lower-case(base-uri(/*)),'/ncc.html$')">
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <pxi:daisy202-to-epub3-content name="content-without-navigation">
        <p:with-option name="publication-dir" select="$publication-dir">
            <p:empty/>
        </p:with-option>
        <p:with-option name="content-dir" select="$content-dir">
            <p:empty/>
        </p:with-option>
        <p:with-option name="daisy-dir" select="$daisy-dir">
            <p:empty/>
        </p:with-option>
        <p:input port="resolve-links-mapping">
            <p:pipe port="result" step="resolve-links-mapping"/>
        </p:input>
        <p:input port="ncc-navigation">
            <p:pipe port="result" step="ncc-navigation"/>
        </p:input>
    </pxi:daisy202-to-epub3-content>

    <!-- Improve the EPUB 3 Navigation Document based on all the Content Documents. -->
    <pxi:daisy202-to-epub3-navigation name="navigation">
        <p:with-option name="publication-dir" select="$publication-dir">
            <p:empty/>
        </p:with-option>
        <p:with-option name="content-dir" select="$content-dir">
            <p:empty/>
        </p:with-option>
        <p:with-option name="compatibility-mode" select="$compatibility-mode">
            <p:empty/>
        </p:with-option>
        <p:input port="ncc-navigation">
            <p:pipe port="result" step="ncc-navigation"/>
        </p:input>
        <p:input port="content">
            <p:pipe port="content" step="content-without-navigation"/>
        </p:input>
    </pxi:daisy202-to-epub3-navigation>

    <!-- Content Documents -->
    <!-- Nav Doc if it's the only content, or other XHTML otherwise -->
    <p:count limit="1">
        <p:input port="source">
            <p:pipe port="content" step="content-without-navigation"/>
        </p:input>
    </p:count>
    <p:choose name="content-docs">
        <p:when test="number(/*)=0">
            <p:output port="content" sequence="true" primary="true"/>
            <p:output port="fileset">
                <p:pipe port="result" step="fileset"/>
            </p:output>
            <p:identity name="fileset">
                <p:input port="source">
                    <p:pipe port="fileset" step="navigation"/>
                </p:input>
            </p:identity>
            <p:identity name="content">
                <p:input port="source">
                    <p:pipe port="navigation" step="navigation"/>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:output port="content" sequence="true" primary="true"/>
            <p:output port="fileset">
                <p:pipe port="result" step="fileset"/>
            </p:output>
            <p:identity name="fileset">
                <p:input port="source">
                    <p:pipe port="fileset" step="content-without-navigation"/>
                </p:input>
            </p:identity>
            <p:identity name="content">
                <p:input port="source">
                    <p:pipe port="content" step="content-without-navigation"/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    <p:sink/>

    <pxi:daisy202-to-epub3-mediaoverlay name="mediaoverlay">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml"><p px:role="desc">Convert and copy the content files and SMIL-files.</p></p:documentation>
        <p:with-option name="include-mediaoverlay" select="$mediaoverlay"/>
        <p:with-option name="daisy-dir" select="$daisy-dir"/>
        <p:with-option name="publication-dir" select="$publication-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:input port="daisy-smil">
            <p:pipe port="result" step="smil-flow.in-memory"/>
        </p:input>
        <p:input port="content">
            <p:pipe port="content" step="content-docs"/>
        </p:input>
    </pxi:daisy202-to-epub3-mediaoverlay>

    <pxi:daisy202-to-epub3-resources name="resources">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">List all referenced auxilliary resources (audio, stylesheets, images, etc.).</p:documentation>
        <p:input port="daisy-smil">
            <p:pipe port="result" step="smil-flow.in-memory"/>
        </p:input>
        <p:input port="daisy-content">
            <p:pipe port="content" step="content-docs"/>
        </p:input>
        <p:with-option name="include-mediaoverlay-resources" select="$mediaoverlay">
            <p:empty/>
        </p:with-option>
        <p:with-option name="content-dir" select="$content-dir">
            <p:empty/>
        </p:with-option>
    </pxi:daisy202-to-epub3-resources>

    <pxi:daisy202-to-epub3-package name="package">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">Make and store the OPF.</p:documentation>
        <p:input port="spine">
            <p:pipe port="fileset" step="content-docs"/>
        </p:input>
        <p:input port="resources">
            <p:pipe port="fileset" step="resources"/>
            <p:pipe port="fileset" step="navigation"/>
        </p:input>
        <p:input port="ncc">
            <p:pipe port="result" step="ncc"/>
        </p:input>
        <p:input port="navigation">
            <p:pipe port="navigation" step="navigation"/>
        </p:input>
        <p:input port="content-docs">
            <p:pipe port="content-navfix" step="navigation"/>
        </p:input>
        <p:input port="mediaoverlay">
            <p:pipe port="mediaoverlay" step="mediaoverlay"/>
        </p:input>
        <p:with-option name="pub-id" select="/*/@value">
            <p:pipe port="pub-id" step="ncc"/>
        </p:with-option>
        <p:with-option name="publication-dir" select="$publication-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
        <p:with-option name="compatibility-mode" select="$compatibility-mode"/>
    </pxi:daisy202-to-epub3-package>
    <p:sink/>

    <px:epub3-ocf-finalize name="finalize">
        <p:input port="source">
            <p:pipe port="result" step="result.fileset-without-ocf-files"/>
        </p:input>
    </px:epub3-ocf-finalize>
    <px:fileset-join>
        <p:input port="source">
            <p:pipe port="result" step="finalize"/>
            <p:pipe port="result" step="result.fileset-without-ocf-files"/>
        </p:input>
    </px:fileset-join>
    <p:identity name="result.fileset"/>
    <p:sink/>

    <p:for-each name="result.for-each">
        <p:output port="in-memory">
            <p:pipe port="result" step="result.for-each.in-memory"/>
        </p:output>
        <p:output port="fileset">
            <p:pipe port="result" step="result.for-each.fileset"/>
        </p:output>
        <p:iteration-source>
            <p:pipe port="navigation" step="navigation"/>
            <p:pipe port="ncx" step="navigation"/>
            <p:pipe port="content-navfix" step="navigation"/>
            <p:pipe port="mediaoverlay" step="mediaoverlay"/>
            <p:pipe port="opf-package" step="package"/>
        </p:iteration-source>
        <p:delete match="/*/@original-href | /*/@xml:base"/>
        <p:identity name="result.for-each.in-memory"/>
        <p:add-attribute match="/*" attribute-name="href">
            <p:with-option name="attribute-value" select="base-uri(/*)">
                <p:pipe port="current" step="result.for-each"/>
            </p:with-option>
            <p:input port="source">
                <p:inline exclude-inline-prefixes="#all">
                    <d:file/>
                </p:inline>
            </p:input>
        </p:add-attribute>
        <p:choose>
            <p:when test="/*/@original-href">
                <p:xpath-context>
                    <p:pipe port="current" step="result.for-each"/>
                </p:xpath-context>
                <p:add-attribute match="/*" attribute-name="original-href">
                    <p:with-option name="attribute-value" select="/*/@original-href">
                        <p:pipe port="current" step="result.for-each"/>
                    </p:with-option>
                </p:add-attribute>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>

        <p:wrap-sequence wrapper="d:fileset"/>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="$epub-dir"/>
        </p:add-attribute>
        <p:identity name="result.for-each.fileset"/>
    </p:for-each>

    <px:fileset-join>
        <p:input port="source">
            <p:pipe port="fileset" step="result.for-each"/>
            <p:pipe port="fileset" step="resources"/>
        </p:input>
    </px:fileset-join>
    <px:mediatype-detect>
        <p:input port="in-memory">
            <p:pipe port="in-memory" step="result.for-each"/>
        </p:input>
    </px:mediatype-detect>
    <p:identity name="result.fileset-without-ocf-files"/>
    <p:sink/>

    <p:identity name="result.in-memory">
        <p:input port="source">
            <p:pipe port="in-memory" step="result.for-each"/>
            <p:pipe port="in-memory.out" step="finalize"/>
        </p:input>
    </p:identity>
    <p:sink/>

</p:declare-step>
