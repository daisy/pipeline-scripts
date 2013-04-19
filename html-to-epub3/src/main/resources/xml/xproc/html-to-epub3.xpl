<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    type="px:html-to-epub3" name="html-to-epub3" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">HTML to EPUB3</h1>
        <p px:role="desc">Transforms an (X)HTML document into an EPUB 3 publication.</p>
    </p:documentation>
    
    <p:option name="html" required="true" px:type="anyFileURI" px:media-type="application/xhtml+xml text/html">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">source</h2>
            <p px:role="desc">The HTML file you want to convert.</p>
        </p:documentation>
    </p:option>

    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Output directory for the EPUB.</p>
        </p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/epub3-ocf-utils/xproc/epub3-ocf-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/html-utils/html-library.xpl"/>
    <p:import href="html-to-epub3.convert.xpl"/>
<!--    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>-->
    
    <p:xslt name="output-dir-uri">
        <p:with-param name="href" select="concat($output-dir,'/')"/>
        <p:input port="source">
            <p:inline>
                <d:file/>
            </p:inline>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pf="http://www.daisy.org/ns/pipeline/functions" version="2.0">
                    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
                    <xsl:param name="href" required="yes"/>
                    <xsl:template match="/*">
                        <xsl:copy>
                            <xsl:attribute name="href" select="pf:normalize-uri($href)"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:sink/>
    

    <p:group>
        <p:variable name="output-dir-uri" select="/*/@href">
            <p:pipe port="result" step="output-dir-uri"/>
        </p:variable>
        <p:variable name="epub-file-uri" select="concat($output-dir-uri,replace($html,'^.*/([^/]*)\.[^/\.]*$','$1'),'.epub')"/>

        <!--TODO handle mulitple HTML docs as space-separated list of URLs-->
        <px:html-load name="html">
            <p:with-option name="href" select="$html"/>
        </px:html-load>

        <px:html-to-epub3-convert name="convert">
            <p:log port="fileset.out" href="file:/tmp/out/log-final-fs.xml"/>
            <p:log port="in-memory.out" href="file:/tmp/out/log-final-docs.xml"/>
            <p:with-option name="output-dir" select="$output-dir-uri"/>
        </px:html-to-epub3-convert>

        <px:epub3-store>
            <p:with-option name="href" select="$epub-file-uri"/>
            <p:input port="in-memory.in">
                <p:pipe port="in-memory.out" step="convert"/>
            </p:input>
        </px:epub3-store>

    </p:group>

</p:declare-step>
