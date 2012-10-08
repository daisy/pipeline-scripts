<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:cx="http://xmlcalabash.com/ns/extensions" type="pxi:daisy202-to-epub3-package"
    name="package" exclude-inline-prefixes="#all" version="1.0">

    <p:documentation>
        <p px:role="desc">Compile and store the OPF.</p>
    </p:documentation>

    <p:input port="spine" primary="false" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">A ordered fileset of Content Documents sorted in reading order.</p>
            <pre><code class="example">
                <d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/home/user/epub3/epub/Publication/Content/">
                    <d:file xml:base="a.xhtml" media-type="application/xhtml+xml"/>
                    <d:file xml:base="b.xhtml" media-type="application/xhtml+xml"/>
                    <d:file xml:base="c.xhtml" media-type="application/xhtml+xml"/>
                </d:fileset>
            </code></pre>
            <p>See also: <a class="see" href="http://idpf.org/epub/30/spec/epub30-overview.html#sec-nav-order">http://idpf.org/epub/30/spec/epub30-overview.html#sec-nav-order</a></p>
        </p:documentation>
    </p:input>
    <p:input port="ncc" primary="false">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">The DAISY 2.02 NCC</p>
            <pre><code class="example">
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/daisy202/ncc.html">...</html>
            </code></pre>
        </p:documentation>
    </p:input>
    <p:input port="navigation" primary="false">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">The EPUB3 Navigation Document.</p>
            <pre><code class="example">
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/navigation.xhtml" original-base="file:/home/user/daisy202/ncc.html">...</html>
            </code></pre>
        </p:documentation>
    </p:input>
    <p:input port="content-docs" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">The EPUB3 Content Documents.</p>
            <pre><code class="example">
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/a.xhtml" original-base="file:/home/user/daisy202/a.html">...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/b.xhtml" original-base="file:/home/user/daisy202/b.html">...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/c.xhtml" original-base="file:/home/user/daisy202/c.html">...</html>
            </code></pre>
        </p:documentation>
    </p:input>
    <p:input port="mediaoverlay" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">The EPUB3 Media Overlays.</p>
            <pre><code class="example">
                <smil xmlns="http://www.w3.org/ns/SMIL" version="3.0" xml:base="file:/home/user/epub3/epub/Publication/Content/a.smil">...</smil>
                <smil xmlns="http://www.w3.org/ns/SMIL" version="3.0" xml:base="file:/home/user/epub3/epub/Publication/Content/b.smil">...</smil>
                <smil xmlns="http://www.w3.org/ns/SMIL" version="3.0" xml:base="file:/home/user/epub3/epub/Publication/Content/c.smil">...</smil>
            </code></pre>
        </p:documentation>
    </p:input>
    <p:input port="resources" primary="false">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">Files other than the Content Documents in the spine and the Media Overlays.</p>
            <pre><code class="example">
                <d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/home/user/epub3/epub/Publication/">
                    <d:file xml:base="navigation.xhtml" media-type="application/xhtml+xml"/>
                    <d:file xml:base="ncx.xml" media-type="application/x-dtbncx+xml"/>
                    <d:file xml:base="Content/audio.mp3" media-type="audio/mpeg"/>
                    <d:file xml:base="Content/image.jpg" media-type="image/jpeg"/>
                    <d:file xml:base="Content/stylesheet.css" media-type="text/css"/>
                </d:fileset>
            </code></pre>
        </p:documentation>
    </p:input>

    <p:output port="opf-package" sequence="true" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">The package document.</p>
            <pre><code class="example">
                <opf:package>...</opf:package>
            </code></pre>
        </p:documentation>
        <p:pipe port="result" step="opf-package"/>
    </p:output>
    <p:output port="fileset" primary="false">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">A fileset of all the files in the EPUB3 publication, including the package file itself</p>
            <pre><code class="example">
                <d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/home/user/epub3/epub/Publication/">...</d:fileset>
            </code></pre>
        </p:documentation>
        <p:pipe port="result" step="result-fileset"/>
    </p:output>
    <p:output port="store-complete" primary="false">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">The result from storing the package document.</p>
            <pre><code class="example">
                <c:result>file:/home/user/epub3/epub/Publication/package.opf</c:result>
            </code></pre>
        </p:documentation>
        <p:pipe port="result" step="store"/>
    </p:output>

    <p:option name="pub-id" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">The publication identifier.</p>
            <pre><code class="example">file:/home/user/epub3/epub/Publication/</code></pre>
            <p>See also: <a class="see" href="http://idpf.org/epub/30/spec/epub30-publications.html#sec-opf-dcidentifier">http://idpf.org/epub/30/spec/epub30-publications.html#sec-opf-dcidentifier</a></p>
        </p:documentation>
    </p:option>
    <p:option name="compatibility-mode" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">Whether or not to make the package document backwards-compatible. Can be either 'true' (default) or 'false'.</p>
        </p:documentation>
    </p:option>
    <p:option name="publication-dir" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">URI to the EPUB3 Publication directory.</p>
            <pre><code class="example">file:/home/user/epub3/epub/Publication/</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="epub-dir" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">URI to the directory where the EPUB3-file should be stored.</p>
            <pre><code class="example">file:/home/user/epub3/epub/Publication/</code></pre>
        </p:documentation>
    </p:option>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">Calabash extension steps.</p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">For manipulating filesets.</p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/xproc/epub3-pub-library.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">For making the package document.</p:documentation>
    </p:import>

    <p:variable name="result-uri" select="concat($publication-dir,'package.opf')"/>

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">Compile OPF metadata.</p:documentation>
    <p:xslt name="opf-metadata">
        <p:with-param name="pub-id" select="$pub-id"/>
        <p:input port="source">
            <p:pipe port="ncc" step="package"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc-metadata-to-opf-metadata.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>

    <p:group name="spine">
        <p:output port="result" sequence="true"/>
        <p:variable name="base" select="base-uri(/*)">
            <p:pipe port="spine" step="package"/>
        </p:variable>
        <p:for-each>
            <p:output port="result" sequence="true"/>
            <p:iteration-source select="/*/d:file">
                <p:pipe port="spine" step="package"/>
            </p:iteration-source>
            <p:choose>
                <p:when test="/*/@media-type='application/xhtml+xml'">
                    <p:wrap-sequence wrapper="d:fileset"/>
                    <p:add-attribute match="/*" attribute-name="xml:base">
                        <p:with-option name="attribute-value" select="$base"/>
                    </p:add-attribute>
                    <px:fileset-join/>
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
    </p:group>
    <p:sink/>

    <px:fileset-join name="manifest">
        <p:input port="source">
            <p:pipe port="spine" step="package"/>
            <p:pipe port="resources" step="package"/>
        </p:input>
    </px:fileset-join>
    <p:sink/>

    <px:epub3-pub-create-package-doc>
        <p:with-option name="result-uri" select="$result-uri"/>
        <p:with-option name="compatibility-mode" select="$compatibility-mode"/>
        <p:with-option name="detect-properties" select="'false'"/>
        <p:input port="spine-filesets">
            <p:pipe port="result" step="spine"/>
        </p:input>
        <p:input port="publication-resources">
            <p:pipe port="result" step="manifest"/>
        </p:input>
        <p:input port="metadata">
            <p:pipe port="result" step="opf-metadata"/>
        </p:input>
        <p:input port="content-docs">
            <p:pipe port="navigation" step="package"/>
            <p:pipe port="content-docs" step="package"/>
        </p:input>
        <p:input port="mediaoverlays">
            <p:pipe port="mediaoverlay" step="package"/>
        </p:input>
    </px:epub3-pub-create-package-doc>

    <p:identity name="opf-package"/>

    <p:store name="store" indent="true">
        <p:with-option name="href" select="$result-uri"/>
    </p:store>
    <cx:message>
        <p:input port="source">
            <p:pipe port="result" step="store"/>
        </p:input>
        <p:with-option name="message" select="concat('stored ',$result-uri)"/>
    </cx:message>
    <p:sink/>

    <p:group name="result-fileset">
        <p:output port="result"/>
        <p:xslt>
            <p:with-param name="base" select="replace($result-uri,'[^/]+$','')"/>
            <p:input port="source">
                <p:pipe port="result" step="opf-package"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="package.manifest-to-fileset.xsl"/>
            </p:input>
        </p:xslt>
        <px:fileset-add-entry name="result-fileset.with-package">
            <p:with-option name="href" select="$result-uri"/>
            <p:with-option name="media-type" select="'application/oebps-package+xml'"/>
        </px:fileset-add-entry>
        <px:fileset-create name="result-fileset.with-epub-base">
            <p:with-option name="base" select="$epub-dir"/>
        </px:fileset-create>
        <px:fileset-join>
            <p:input port="source">
                <p:pipe port="result" step="result-fileset.with-epub-base"/>
                <p:pipe port="result" step="result-fileset.with-package"/>
            </p:input>
        </px:fileset-join>
    </p:group>

</p:declare-step>
