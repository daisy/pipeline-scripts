<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:xd="http://www.daisy.org/ns/pipeline/doc" xmlns:c="http://www.w3.org/ns/xproc-step"
    type="px:zedai-to-epub3-store" name="zedai-to-epub3.store" exclude-inline-prefixes="#all" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>zedai-to-epub3</xd:short>
        <xd:detail>Packages and stores an EPUB3 fileset to disk.</xd:detail>
    </p:documentation>

    <p:input port="fileset.in" primary="true">
        <p:documentation>
            <xd:short>A fileset referencing all resources to be stored.</xd:short>
            <xd:detail>Contains references to all the EPUB3 files and any resources they reference (images etc.).</xd:detail>
        </p:documentation>
    </p:input>

    <p:input port="in-memory.in" sequence="true">
        <p:documentation>In-memory documents (XHTML, OPF).</p:documentation>
    </p:input>

    <p:option name="epub-file" required="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>Calabash extension steps.</p:documentation>
    </p:import>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl">
        <p:documentation>For manipulating filesets.</p:documentation>
    </p:import>

    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl">
        <p:documentation>For manipulating files.</p:documentation>
    </p:import>

    <p:import href="http://www.daisy.org/pipeline/modules/epub3-ocf-utils/xproc/epub3-ocf-library.xpl">
        <p:documentation>For packaging and storing the finished EPUB file.</p:documentation>
    </p:import>

    <p:variable name="fileset-base" select="/*/@xml:base"/>

    <cx:message message="Storing EPUB3 fileset."/>
    <p:sink/>

    <p:for-each>
        <p:iteration-source>
            <p:pipe port="in-memory.in" step="zedai-to-epub3.store"/>
        </p:iteration-source>
        <p:add-attribute attribute-name="href" match="/*">
            <p:input port="source">
                <p:inline>
                    <d:file/>
                </p:inline>
            </p:input>
            <p:with-option name="attribute-value" select="p:resolve-uri(/*/@xml:base)"/>
        </p:add-attribute>
    </p:for-each>
    <p:wrap-sequence wrapper="d:fileset"/>
    <px:fileset-join name="fileset.in-memory"/>

    <p:for-each>
        <p:output port="result" sequence="true"/>
        <p:iteration-source select="/*/*">
            <p:pipe port="fileset.in" step="zedai-to-epub3.store"/>
        </p:iteration-source>
        <p:variable name="on-disk" select="(/*/@xml:base, '')[1]"/>
        <p:variable name="target" select="p:resolve-uri(/*/@href, $fileset-base)"/>
        <p:variable name="media-type" select="/*/@media-type"/>
        <p:choose>
            <p:xpath-context>
                <p:pipe port="result" step="fileset.in-memory"/>
            </p:xpath-context>
            <p:when test="//d:file[@href=$target]">
                <p:documentation>File is in memory.</p:documentation>
                <p:split-sequence>
                    <p:with-option name="test" select="concat('/*/@xml:base=&quot;',$target,'&quot;')"/>
                    <p:input port="source">
                        <p:pipe port="in-memory.in" step="zedai-to-epub3.store"/>
                    </p:input>
                </p:split-sequence>
                <p:delete match="/*/@xml:base"/>
                <p:choose>
                    <p:when test="$media-type='application/xhtml+xml'">
                        <p:documentation>In-memory file is a Content Document.</p:documentation>
                        <p:store indent="true" encoding="utf-8" method="xhtml" include-content-type="false" name="store.content-doc">
                            <p:with-option name="href" select="$target"/>
                        </p:store>
                        <p:identity>
                            <p:input port="source">
                                <p:pipe port="result" step="store.content-doc"/>
                            </p:input>
                        </p:identity>
                    </p:when>
                    <p:when test="$media-type='application/oebps-package+xml'">
                        <p:documentation>In-memory file is the Package Document.</p:documentation>
                        <p:store media-type="application/oebps-package+xml" indent="true" encoding="utf-8" omit-xml-declaration="false" name="store.package-doc">
                            <p:with-option name="href" select="$target"/>
                        </p:store>
                        <p:identity>
                            <p:input port="source">
                                <p:pipe port="result" step="store.package-doc"/>
                            </p:input>
                        </p:identity>
                    </p:when>
                    <p:otherwise>
                        <p:documentation>In-memory file stored as-is.</p:documentation>
                        <p:store name="store.as-is">
                            <p:with-option name="href" select="$target"/>
                        </p:store>
                        <p:identity>
                            <p:input port="source">
                                <p:pipe port="result" step="store.as-is"/>
                            </p:input>
                        </p:identity>
                    </p:otherwise>
                </p:choose>
            </p:when>
            <p:when test="not($on-disk)">
                <p:error code="PEZE00">
                    <p:input port="source">
                        <p:inline>
                            <c:message>Found document in fileset that are neither stored on disk nor in memory.</c:message>
                        </p:inline>
                    </p:input>
                </p:error>
            </p:when>
            <p:otherwise>
                <p:documentation>File is already on disk; copy it to the new location.</p:documentation>
                <p:variable name="target-dir" select="replace($target,'[^/]+$','')"/>
                <px:info>
                    <p:with-option name="href" select="$target-dir"/>
                </px:info>
                <p:wrap-sequence wrapper="info"/>
                <p:choose name="mkdir">
                    <p:when test="empty(/info/*)">
                        <px:mkdir>
                            <p:with-option name="href" select="$target-dir"/>
                        </px:mkdir>
                    </p:when>
                    <p:when test="not(/info/c:directory)">
                        <!--TODO rename the error-->
                        <p:error code="err:file">
                            <p:input port="source">
                                <p:inline exclude-inline-prefixes="d">
                                    <c:message>The target is not a directory.</c:message>
                                </p:inline>
                            </p:input>
                        </p:error>
                        <p:sink/>
                    </p:when>
                    <p:otherwise>
                        <p:identity/>
                        <p:sink/>
                    </p:otherwise>
                </p:choose>
                <px:copy cx:depends-on="mkdir" name="store.copy">
                    <p:with-option name="href" select="$on-disk"/>
                    <p:with-option name="target" select="$target"/>
                </px:copy>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="result" step="store.copy"/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <p:wrap-sequence wrapper="wrapper" name="store-complete"/>
    <p:sink/>

    <!--=========================================================================-->
    <!-- BUILD THE EPUB PUBLICATION                                              -->
    <!--=========================================================================-->

    <p:documentation>Build the EPUB 3 Publication</p:documentation>
    <p:group name="epub">
        <p:output port="result"/>
        <!--seems to be required to *not* connect non-primary ports on ocf-finalize-->
        <px:epub3-ocf-finalize>
            <p:input port="source">
                <p:pipe port="fileset.in" step="zedai-to-epub3.store"/>
            </p:input>
        </px:epub3-ocf-finalize>
        <px:epub3-ocf-zip>
            <p:with-option name="target" select="$epub-file">
                <p:pipe step="store-complete" port="result"/>
            </p:with-option>
        </px:epub3-ocf-zip>
    </p:group>
    <p:sink/>

</p:declare-step>
