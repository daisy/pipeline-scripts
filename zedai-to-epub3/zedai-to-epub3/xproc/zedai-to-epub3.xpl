<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
    type="px:zedai-to-epub3" name="zedai-to-epub3" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>zedai-to-epub3</xd:short>
        <xd:detail>Transforms a ZedAI (DAISY 4 XML) document into an EPUB 3 publication.</xd:detail>
    </p:documentation>

    <p:input port="source" primary="true" px:name="source" px:media-type="application/z3998-auth+xml">
        <p:documentation>
            <xd:short>source</xd:short>
            <xd:detail>Path to input ZedAI.</xd:detail>
        </p:documentation>
    </p:input>

    <p:option name="output-dir" required="true" px:dir="output" px:type="anyDirURI">
        <p:documentation>
            <xd:short>output-dir</xd:short>
            <xd:detail>Path to output directory for the EPUB.</xd:detail>
        </p:documentation>
    </p:option>

    <p:import href="zedai-to-epub3.load.xpl"/>
    <p:import href="zedai-to-epub3.convert.xpl"/>
    <p:import href="zedai-to-epub3.store.xpl"/>

    <p:import href="http://www.daisy.org/pipeline/modules/epub3-nav-utils/epub3-nav-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-ocf-utils/xproc/epub3-ocf-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/xproc/epub3-pub-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <p:variable name="input-uri" select="base-uri(/)"/>
    
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
                            <xsl:attribute name="href" select="pf:file-uri-ify($href)"/>
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
        <p:variable name="epub-file-uri" select="concat($output-dir-uri,replace($input-uri,'^.*/([^/]*)\.[^/\.]*$','$1'),'.epub')"/>

        <px:zedai-to-epub3-load name="load">
            <p:input port="source">
                <p:pipe port="source" step="zedai-to-epub3"/>
            </p:input>
        </px:zedai-to-epub3-load>

        <px:zedai-to-epub3-convert name="convert">
            <p:input port="in-memory.in">
                <p:pipe port="in-memory.out" step="load"/>
            </p:input>
            <p:with-option name="output-dir" select="$output-dir-uri"/>
        </px:zedai-to-epub3-convert>

        <px:zedai-to-epub3-store name="store">
            <p:input port="in-memory.in">
                <p:pipe port="in-memory.out" step="convert"/>
            </p:input>
            <p:with-option name="epub-file" select="$epub-file-uri"/>
        </px:zedai-to-epub3-store>

    </p:group>

</p:declare-step>
