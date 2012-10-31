<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="html-to-dtbook" type="px:html-to-dtbook" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:html="http://www.w3.org/1999/xhtml" xpath-version="2.0" exclude-inline-prefixes="#all">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <!-- Script documentation -->
        <h1 px:role="name">HTML to DTBook</h1>
        <p px:role="desc">Converts an HTML document into </p>
    </p:documentation>

    <p:option name="html" required="true" px:type="anyFileURI" px:media-type="application/xhtml+xml text/html">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">source</h2>
            <p px:role="desc">The HTML file you want to convert.</p>
        </p:documentation>
    </p:option>

    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Output directory</h2>
            <p px:role="desc">Directory where your DTBook will be stored.</p>
        </p:documentation>
    </p:option>

    <p:output port="debug" sequence="true">
        <p:pipe port="fileset" step="convert"/>
        <p:pipe port="in-memory" step="convert"/>
    </p:output>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>Calabash extension steps.</p:documentation>
    </p:import>

    <p:import href="http://www.daisy.org/pipeline/modules/html-utils/html-library.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">For loading the HTML fileset.</p>
        </p:documentation>
    </p:import>

    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/dtbook-utils-library.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">For storing the DTBook fileset.</p>
        </p:documentation>
    </p:import>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>

    <p:import href="html-to-dtbook-convert.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">For converting from HTML to DTBook.</p>
        </p:documentation>
    </p:import>

    <px:html-load name="html">
        <p:log port="result" href="file:/home/jostein/Skrivebord/html-to-dtbook.test/log/html.xml"/>
        <p:with-option name="href" select="$html"/>
    </px:html-load>

    <p:group name="convert">
        <p:output port="in-memory" primary="true">
            <p:pipe port="in-memory.out" step="convert.convert"/>
        </p:output>
        <p:output port="fileset">
            <p:pipe port="fileset.out" step="convert.convert"/>
        </p:output>

        <!--<p:variable name="uid" select="concat('',string-join(tokenize(replace(concat('',current-dateTime()),'[-:]',''),'[T\+\.]')[position() &lt;= 3],'-'))"/>-->
        <!--<p:variable name="title" select="'TODO'"/>-->
        <!--<p:variable name="cssURI" select="'[cssURI]'"/>-->

        <p:identity name="convert.in-memory.in"/>

        <p:for-each>
            <p:iteration-source select="//html:link[@href]|//html:*[@src]"/>

            <!-- Find all auxilliary resuorces and create d:files for them -->
            <p:variable name="href" select="(/*/@src,/*/@href)[1]"/>
            <p:add-attribute attribute-name="href" match="/*">
                <p:with-option name="attribute-value" select="replace($href,'^\./','')"/>
                <p:input port="source">
                    <p:inline>
                        <d:file/>
                    </p:inline>
                </p:input>
            </p:add-attribute>

            <!-- Set correct base uri for each d:file -->
            <p:add-attribute attribute-name="xml:base" match="/*">
                <p:with-option name="attribute-value" select="p:resolve-uri($href,$html)"/>
            </p:add-attribute>
            <p:delete match="/*/@xml:base"/>
        </p:for-each>
        <p:wrap-sequence wrapper="d:fileset"/>
        <p:add-attribute attribute-name="xml:base" match="/*">
            <p:with-option name="attribute-value" select="p:resolve-uri('.',$html)"/>
        </p:add-attribute>
        <p:identity name="convert.fileset.in"/>

        <px:html-to-dtbook-convert name="convert.convert">
            <p:with-option name="output-dir" select="$output-dir"/>
            <p:input port="in-memory.in">
                <p:pipe port="result" step="convert.in-memory.in"/>
            </p:input>
            <p:input port="fileset.in">
                <p:pipe port="result" step="convert.fileset.in"/>
            </p:input>
        </px:html-to-dtbook-convert>
    </p:group>

    <px:dtbook-store>
        <p:input port="fileset.in">
            <p:pipe port="fileset" step="convert"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory" step="convert"/>
        </p:input>
    </px:dtbook-store>

</p:declare-step>
