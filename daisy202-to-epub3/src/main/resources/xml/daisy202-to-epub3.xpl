<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:html="http://www.w3.org/1999/xhtml" type="px:daisy202-to-epub3" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DAISY 2.02 to EPUB3</h1>
        <p px:role="desc">Transforms a DAISY 2.02 publication into an EPUB3 publication.</p>
        <dl px:role="author maintainer">
            <dt>Name:</dt>
            <dd px:role="name">Jostein Austvik Jacobsen</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:josteinaj@gmail.com">josteinaj@gmail.com</a></dd>
            <dt>Organization:</dt>
            <dd px:role="organization">NLB</dd>
        </dl>
        <p><a px:role="homepage" href="http://code.google.com/p/daisy-pipeline/wiki/DAISY202ToEPUB3Doc">Online Documentation</a></p>
    </p:documentation>

    <p:option name="href" required="true" px:type="anyFileURI" px:media-type="application/xhtml+xml text/html">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">href</h2>
            <p px:role="desc">Input NCC.</p>
            <pre><code class="example">file:/home/user/daisy202/ncc.html</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="output" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">output</h2>
            <p px:role="desc">Output directory for the EPUB.</p>
            <pre><code class="example">file:/home/user/epub3/</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="mediaoverlay" required="false" select="'true'" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">mediaoverlay</h2>
            <p px:role="desc">Whether or not to include media overlays and associated audio files (true or false).</p>
        </p:documentation>
    </p:option>
    <p:option name="compatibility-mode" required="false" select="'true'" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">compatibility-mode</h2>
            <p px:role="desc">Whether or not to include NCX-file, OPF guide element and ASCII filenames (true or false).</p>
        </p:documentation>
    </p:option>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-ocf-utils/xproc/epub3-ocf-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/daisy2-utils/xproc/daisy2-library.xpl"/>
    <p:import href="convert/convert.xpl"/>

    <p:variable name="output-dir" select="if (ends-with($output,'/')) then $output else concat($output,'/')"/>

    <!-- validate options -->
    <p:in-scope-names name="vars"/>
    <p:identity>
        <p:input port="source">
            <p:inline>
                <dummy-doc-for-p-template/>
            </p:inline>
        </p:input>
    </p:identity>
    <p:choose>
        <p:when test="not(matches($href,'\w+:/'))">
            <p:template>
                <p:input port="template">
                    <p:inline exclude-inline-prefixes="#all">
                        <message>href: "{$href}" is not a valid URI. You probably either forgot to prefix the path with file:/, or if you're using Windows, remember to replace all directory separators (\) with forward slashes (/).</message>
                    </p:inline>
                </p:input>
                <p:input port="parameters">
                    <p:pipe step="vars" port="result"/>
                </p:input>
            </p:template>
            <p:error code="PDE01"/>
        </p:when>
        <p:when test="not(matches($output,'\w+:/'))">
            <p:template>
                <p:input port="template">
                    <p:inline exclude-inline-prefixes="#all">
                        <message>output: "{$output}" is not a valid URI. You probably either forgot to prefix the path with file:/, or if you're using Windows, remember to replace all directory separators (\) with forward slashes (/).</message>
                    </p:inline>
                </p:input>
                <p:input port="parameters">
                    <p:pipe step="vars" port="result"/>
                </p:input>
            </p:template>
            <p:error code="PDE02"/>
        </p:when>
        <p:when test="not($mediaoverlay='true' or $mediaoverlay='false')">
            <p:template>
                <p:input port="template">
                    <p:inline exclude-inline-prefixes="#all">
                        <message>mediaoverlay: "{$mediaoverlay}" is not a valid value. When given, mediaoverlay must be either "true" (default) or "false".</message>
                    </p:inline>
                </p:input>
                <p:input port="parameters">
                    <p:pipe step="vars" port="result"/>
                </p:input>
            </p:template>
            <p:error code="PDE03"/>
        </p:when>
        <p:when test="not($compatibility-mode='true' or $compatibility-mode='false')">
            <p:template>
                <p:input port="template">
                    <p:inline exclude-inline-prefixes="#all">
                        <message>compatibility-mode: "{$compatibility-mode}" is not a valid value. When given, compatibility-mode must be either "true" (default) or "false".</message>
                    </p:inline>
                </p:input>
                <p:input port="parameters">
                    <p:pipe step="vars" port="result"/>
                </p:input>
            </p:template>
            <p:error code="PDE04"/>
        </p:when>
        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    <p:sink/>

    <!-- load -->
    <px:daisy2-load name="load">
        <p:with-option name="ncc" select="$href"/>
    </px:daisy2-load>

    <!-- convert -->
    <px:daisy202-to-epub3-convert name="convert">
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="load"/>
        </p:input>
        <p:with-option name="output-dir" select="$output"/>
    </px:daisy202-to-epub3-convert>
    
    <!-- decide filename -->
    <px:fileset-load media-types="application/oebps-package+xml">
        <p:input port="in-memory">
            <p:pipe port="in-memory.out" step="convert"/>
        </p:input>
    </px:fileset-load>
    <p:split-sequence test="position()=1"/>
    <p:add-attribute match="/*" attribute-name="result-uri">
        <p:with-option name="attribute-value" select="concat($output-dir,encode-for-uri(replace(concat(//dc:identifier,' - ',//dc:title,'.epub'),'[/\\?%*:|&quot;&lt;&gt;]','')))"/>
    </p:add-attribute>
    <p:delete match="/*/*"/>
    <p:identity name="result-uri"/>
    <p:sink/>
    
    <!-- store -->
    <px:epub3-store>
        <p:with-option name="href" select="/*/@result-uri">
            <p:pipe port="result" step="result-uri"/>
        </p:with-option>
        <p:input port="fileset.in">
            <p:pipe port="fileset.out" step="convert"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="convert"/>
        </p:input>
    </px:epub3-store>

</p:declare-step>
