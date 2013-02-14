<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
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
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/mediatype.xpl"/>

    <p:import href="resolve-links.create-mapping.xpl"/>
    <p:import href="ncc-navigation.xpl"/>
    <p:import href="navigation.xpl"/>
    <p:import href="content.xpl"/>
    <p:import href="media-overlay.xpl"/>
    <p:import href="resources.xpl"/>
    <p:import href="package.xpl"/>

    <p:variable name="epub-dir" select="concat($output-dir,'epub/')"/>
    <p:variable name="publication-dir" select="concat($epub-dir,'OEBPS/')"/>
    <p:variable name="content-dir" select="concat($publication-dir,'Content/')"/>
    <p:variable name="daisy-dir" select="base-uri(/*)">
        <p:pipe port="fileset.in" step="main"/>
    </p:variable>

    <!-- Make a fileset and a document sequence of all the SMIL files in reading order -->
    <px:fileset-filter media-types="application/smil+xml" name="smil-flow.fileset">
        <p:input port="source">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
    </px:fileset-filter>
    <px:fileset-load name="smil-flow.in-memory">
        <p:input port="in-memory">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>

    <!-- Make a fileset and a document sequence of all the content documents in reading order -->
    <p:for-each>
        <p:iteration-source select="//*[local-name()='text' and @src]"/>
        <p:add-attribute match="/*" attribute-name="src">
            <p:with-option name="attribute-value" select="tokenize(resolve-uri(/*/@src,base-uri(/*)),'[\?#]')[1]"/>
        </p:add-attribute>
    </p:for-each>
    <p:wrap-sequence wrapper="wrapper"/>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <xsl:template match="/*">
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:for-each select="distinct-values(//@src)">
                                <file src="{.}"/>
                            </xsl:for-each>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:for-each>
        <p:iteration-source select="/*/*"/>
        <cx:message>
            <p:with-option name="message" select="concat('looking for ',/*/@src,' in fileset')"/>
        </cx:message>
        <px:fileset-load>
            <p:with-option name="href" select="/*/@src"/>
            <p:input port="fileset">
                <p:pipe port="fileset.in" step="main"/>
            </p:input>
            <p:input port="in-memory">
                <p:pipe port="in-memory.in" step="main"/>
            </p:input>
        </px:fileset-load>
    </p:for-each>
    <p:identity name="content-flow.in-memory"/>
    <p:sink/>

    <p:for-each>
        <p:variable name="base" select="base-uri()"/>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:input port="source">
                <p:inline exclude-inline-prefixes="#all">
                    <d:fileset>
                        <d:file/>
                    </d:fileset>
                </p:inline>
            </p:input>
            <p:with-option name="attribute-value" select="replace($base,'[^/]+$','')"/>
        </p:add-attribute>
        <p:add-attribute match="/*/*" attribute-name="href">
            <p:with-option name="attribute-value" select="$base"/>
        </p:add-attribute>
    </p:for-each>
    <px:fileset-join name="content-flow.fileset"/>
    <p:sink/>

    <!-- Make a map of all links from the SMIL files to the HTML files -->
    <pxi:daisy202-to-epub3-resolve-links-create-mapping name="resolve-links-mapping">
        <p:input port="daisy-smil">
            <p:pipe port="result" step="smil-flow.in-memory"/>
        </p:input>
    </pxi:daisy202-to-epub3-resolve-links-create-mapping>
    <p:sink/>

    <!-- Make a Navigation Document based on the DAISY 2.02 NCC. -->

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
                <p:identity/>
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
    <p:split-sequence initial-only="true" test="position()=1"/>
    <!-- TODO: should throw an error message here if there's no NCC (p:count=0) -->
    <p:group name="ncc">
        <p:output port="result" primary="true">
            <p:pipe port="result" step="ncc.ncc"/>
        </p:output>
        <p:output port="pub-id">
            <p:pipe port="result" step="ncc.pub-id"/>
        </p:output>
        <p:identity name="ncc.ncc"/>
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
    <pxi:daisy202-to-epub3-content name="content-without-full-navigation">
        <p:with-option name="publication-dir" select="$publication-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="daisy-dir" select="$daisy-dir"/>
        <p:input port="resolve-links-mapping">
            <p:pipe port="result" step="resolve-links-mapping"/>
        </p:input>
        <p:input port="ncc-navigation">
            <p:pipe port="result" step="ncc-navigation"/>
        </p:input>
    </pxi:daisy202-to-epub3-content>

    <!-- Improve the EPUB 3 Navigation Document based on all the Content Documents. -->
    <pxi:daisy202-to-epub3-navigation name="navigation">
        <p:with-option name="publication-dir" select="$publication-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="compatibility-mode" select="$compatibility-mode"/>
        <p:input port="ncc-navigation">
            <p:pipe port="result" step="ncc-navigation"/>
        </p:input>
        <p:input port="content">
            <p:pipe port="content" step="content-without-full-navigation"/>
        </p:input>
    </pxi:daisy202-to-epub3-navigation>

    <pxi:daisy202-to-epub3-mediaoverlay name="mediaoverlay">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml"><p px:role="desc">Convert and copy the content files and SMIL-files.</p></p:documentation>
        <p:with-option name="include-mediaoverlay" select="$mediaoverlay"/>
        <p:with-option name="daisy-dir" select="$daisy-dir"/>
        <p:with-option name="publication-dir" select="$publication-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="navigation-uri" select="base-uri(/*)">
            <p:pipe port="result" step="ncc-navigation"/>
        </p:with-option>
        <p:input port="daisy-smil">
            <p:pipe port="result" step="smil-flow.in-memory"/>
        </p:input>
        <p:input port="content">
            <p:pipe port="content" step="content-without-full-navigation"/>
        </p:input>
    </pxi:daisy202-to-epub3-mediaoverlay>

    <pxi:daisy202-to-epub3-resources name="resources">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">List all referenced auxilliary resources (audio, stylesheets, images, etc.).</p:documentation>
        <p:input port="daisy-smil">
            <p:pipe port="result" step="smil-flow.in-memory"/>
        </p:input>
        <p:input port="daisy-content">
            <p:pipe port="content" step="content-without-full-navigation"/>
        </p:input>
        <p:with-option name="include-mediaoverlay-resources" select="$mediaoverlay"/>
        <p:with-option name="content-dir" select="$content-dir"/>
    </pxi:daisy202-to-epub3-resources>

    <pxi:daisy202-to-epub3-package name="package">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">Make and store the OPF.</p:documentation>
        <p:input port="spine">
            <p:pipe port="fileset" step="content-without-full-navigation"/>
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
