<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-to-zedai.store" type="px:dtbook-to-zedai-store" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp" xmlns:z="http://www.daisy.org/ns/z3986/authoring/"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" exclude-inline-prefixes="cx p c cxo px xd pxi z tmp">

    <p:documentation>
        <xd:short>DTBook to ZedAI - store</xd:short>
        <xd:detail>Copy all referenced files to the output directory.</xd:detail>
        <xd:homepage>http://code.google.com/p/daisy-pipeline/wiki/DTBookToZedAI</xd:homepage>
        <xd:author>
            <xd:name>Marisa DeMeglio</xd:name>
            <xd:mailto>marisa.demeglio@gmail.com</xd:mailto>
            <xd:organization>DAISY</xd:organization>
        </xd:author>
    </p:documentation>

    <p:input port="fileset.in" primary="true">
        <p:documentation>
            <xd:short>A fileset referencing all resources to be stored.</xd:short>
            <xd:detail>Contains references to all the ZedAI file and any resources it references (images etc.).</xd:detail>
        </p:documentation>
    </p:input>

    <p:input port="in-memory.in" sequence="true">
        <p:documentation>In-memory documents (ZedAI, CSS, MODS).</p:documentation>
    </p:input>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>Calabash extension steps.</p:documentation>
    </p:import>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl">
        <p:documentation>For manipulating filesets.</p:documentation>
    </p:import>

    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl">
        <p:documentation>For manipulating files.</p:documentation>
    </p:import>

    <p:variable name="fileset-base" select="/*/@xml:base"/>

    <cx:message message="Storing ZedAI fileset."/>
    <p:sink/>

    <p:for-each>
        <p:iteration-source>
            <p:pipe port="in-memory.in" step="dtbook-to-zedai.store"/>
        </p:iteration-source>
        <p:add-attribute attribute-name="href" match="/*">
            <p:input port="source">
                <p:inline>
                    <d:file/>
                </p:inline>
            </p:input>
            <p:with-option name="attribute-value" select="/*/@xml:base"/>
        </p:add-attribute>
    </p:for-each>
    <p:wrap-sequence wrapper="d:fileset"/>
    <px:fileset-join name="fileset.in-memory"/>

    <p:for-each name="iterate-fileset">
        <p:iteration-source select="/*/*">
            <p:pipe port="fileset.in" step="dtbook-to-zedai.store"/>
        </p:iteration-source>
        <p:variable name="on-disk" select="(/*/@xml:base, '')[1]"/>
        <p:variable name="target" select="p:resolve-uri(/*/@href, $fileset-base)"/>
        <p:variable name="media-type" select="/*/@media-type"/>
        <p:choose name="iterate-fileset.file">
            <p:xpath-context>
                <p:pipe port="result" step="fileset.in-memory"/>
            </p:xpath-context>
            <p:when test="//d:file[@href=$target]">
                <p:documentation>File is in memory.</p:documentation>
                <!--<p:output port="result">
                    <p:pipe port="result" step="iterate-fileset.file.in-memory.store"/>
                </p:output>-->
                <p:split-sequence name="iterate-fileset.file.in-memory">
                    <p:with-option name="test" select="concat('/*/@xml:base=&quot;',$target,'&quot;')"/>
                    <p:input port="source">
                        <p:pipe port="in-memory.in" step="dtbook-to-zedai.store"/>
                    </p:input>
                </p:split-sequence>
                <p:delete match="/*/@xml:base"/>
                <p:choose name="iterate-fileset.file.in-memory.store">
                    <p:when test="$media-type='text/css'">
                        <p:documentation>In-memory file is CSS; unwrap it and store as text.</p:documentation>
                        <!--<p:output port="result">
                            <p:pipe port="result" step="iterate-fileset.file.in-memory.store-css"/>
                        </p:output>-->
                        <p:string-replace match="/text()" replace="''"/>
                        <p:store method="text" name="iterate-fileset.file.in-memory.store-css">
                            <p:with-option name="href" select="$target"/>
                        </p:store>
                    </p:when>
                    <p:otherwise>
                        <p:documentation>In-memory file stored as-is.</p:documentation>
                        <!--<p:output port="result">
                            <p:pipe port="result" step="iterate-fileset.file.in-memory.store-other"/>
                        </p:output>-->
                        <p:store name="iterate-fileset.file.in-memory.store-other">
                            <p:with-option name="href" select="$target"/>
                        </p:store>
                    </p:otherwise>
                </p:choose>
            </p:when>
            <p:otherwise>
                <p:documentation>File is already on disk; copy it to the new location.</p:documentation>
                <!--<p:output port="result">
                    <p:pipe port="result" step="iterate-fileset.file.on-disk.store"/>
                </p:output>-->
                <p:sink/>
                <px:copy name="iterate-fileset.file.on-disk.store">
                    <p:with-option name="href" select="$on-disk"/>
                    <p:with-option name="target" select="$target"/>
                </px:copy>
            </p:otherwise>
        </p:choose>
        <!--<p:add-attribute match="/*" attribute-name="href">
            <p:with-option name="attribute-value" select="."/>
            <p:input port="source">
                <p:inline>
                    <d:file/>
                </p:inline>
            </p:input>
        </p:add-attribute>
        <p:add-attribute match="/*" attribute-name="media-type">
            <p:with-option name="attribute-value" select="$media-type"/>
        </p:add-attribute>-->
    </p:for-each>
    <!--<px:fileset-join name="fileset.stored"/>-->

</p:declare-step>
