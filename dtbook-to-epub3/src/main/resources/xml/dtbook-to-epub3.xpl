<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-to-epub3" type="px:dtbook-to-epub3"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    xmlns:z="http://www.daisy.org/ns/z3986/authoring/"
    xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" exclude-inline-prefixes="#all">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DTBook to EPUB3</h1>
        <p px:role="desc">Converts multiple dtbooks to epub3 format</p>
    </p:documentation>
    <p:input port="source" primary="true" sequence="true" px:media-type="application/x-dtbook+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">DTBook file(s)</h2>
            <p px:role="desc">One or more DTBook files to be transformed. In the case of multiple files, a merge will be performed.</p>
        </p:documentation>
    </p:input>

    <p:option name="language" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Language code</h2>
            <p px:role="desc">Language code of the input document.</p>
        </p:documentation>
    </p:option>

    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Output directory</h2>
            <p px:role="desc">Directory where both temp-files and the resulting EPUB3 publication is stored.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="assert-valid" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Assert validity</h2>
            <p px:role="desc">Whether to stop processing and raise an error on validation issues.</p>
        </p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/dtbook-load.xpl"/>
    <p:import
        href="http://www.daisy.org/pipeline/modules/dtbook-to-zedai/dtbook-to-zedai.convert.xpl"/>
    <p:import
        href="http://www.daisy.org/pipeline/modules/zedai-to-epub3/xproc/zedai-to-epub3.convert.xpl"/>
    <p:import
        href="http://www.daisy.org/pipeline/modules/zedai-to-epub3/xproc/zedai-to-epub3.store.xpl"/>

    <!--<p:variable name="encoded-title" select="encode-for-uri(replace(//dtbook:meta[@name='dc:Title']/@content,'[/\\?%*:|&quot;&lt;&gt;]',''))"/>-->
    <!--<p:variable name="encoded-title" select="'book'"/>-->
    <p:variable name="encoded-title"
        select="replace(replace(base-uri(/),'^.*/([^/]+)$','$1'),'\.[^\.]*$','')"/>

    <p:xslt name="output-dir-uri">
        <p:with-param name="href" select="concat($output-dir,'/')"/>
        <p:input port="source">
            <p:inline>
                <d:file/>
            </p:inline>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:pf="http://www.daisy.org/ns/pipeline/functions" version="2.0">
                    <xsl:import
                        href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
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
        <p:variable name="epub-file-uri" select="concat($output-dir-uri,$encoded-title,'.epub')"/>

        <px:dtbook-load name="load">
            <p:input port="source">
                <p:pipe port="source" step="dtbook-to-epub3"/>
            </p:input>
        </px:dtbook-load>

        <px:dtbook-to-zedai-convert name="convert.dtbook-to-zedai">
            <p:input port="in-memory.in">
                <p:pipe port="in-memory.out" step="load"/>
            </p:input>
            <p:with-option name="opt-output-dir" select="concat($output-dir-uri,'zedai/')"/>
            <p:with-option name="opt-zedai-filename" select="concat($encoded-title,'.xml')"/>
            <p:with-option name="opt-lang" select="$language"/>
            <p:with-option name="opt-assert-valid" select="$assert-valid"/>
        </px:dtbook-to-zedai-convert>

        <!--TODO better handle core media type filtering-->
        <p:delete
            match="d:file[not(@media-type=('application/z3998-auth+xml',
            'image/gif','image/jpeg','image/png','image/svg+xml',
            'application/pls+xml',
            'audio/mpeg','audio/mp4',
            'text/css','text/javascript'))]"/>
        

        <px:zedai-to-epub3-convert name="convert.zedai-to-epub3">
            <p:input port="in-memory.in">
                <p:pipe port="in-memory.out" step="convert.dtbook-to-zedai"/>
            </p:input>
            <p:with-option name="output-dir" select="$output-dir-uri"/>
        </px:zedai-to-epub3-convert>

        <px:zedai-to-epub3-store name="store">
            <p:input port="in-memory.in">
                <p:pipe port="in-memory.out" step="convert.zedai-to-epub3"/>
            </p:input>
            <p:with-option name="epub-file" select="$epub-file-uri"/>
        </px:zedai-to-epub3-store>

    </p:group>

</p:declare-step>
