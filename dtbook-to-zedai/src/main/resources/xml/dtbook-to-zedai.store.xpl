<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-to-zedai.store" type="px:dtbook-to-zedai-store" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp" xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" exclude-inline-prefixes="#all">

    <p:documentation>
            Copy all referenced files to the output directory.
    </p:documentation>

    <p:input port="fileset.in" primary="true">
        <p:documentation>
            A fileset containing references to the ZedAI file and any resources it references (images, etc.).
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
            <p:with-option name="attribute-value" select="p:resolve-uri(/*/@xml:base)"/>
        </p:add-attribute>
    </p:for-each>
    <p:wrap-sequence wrapper="d:fileset"/>
    <px:fileset-join name="fileset.in-memory"/>
    
    <p:for-each>
        <p:iteration-source select="/*/*">
            <p:pipe port="fileset.in" step="dtbook-to-zedai.store"/>
        </p:iteration-source>
        <p:variable name="on-disk" select="(/*/@original-href, 'nothing')[1]"/>
        <p:variable name="target" select="p:resolve-uri(/*/@href, $fileset-base)"/>
        <p:variable name="media-type" select="/*/@media-type"/>
        <p:choose>
            <p:xpath-context>
                <p:pipe port="result" step="fileset.in-memory"/>
            </p:xpath-context>
            <p:when test="$target = //d:file/@href">
                <p:documentation>File is in memory.</p:documentation>
                <p:split-sequence>
                    <p:with-option name="test" select="concat('/*/@xml:base=&quot;',$target,'&quot;')"/>
                    <p:input port="source">
                        <p:pipe port="in-memory.in" step="dtbook-to-zedai.store"/>
                    </p:input>
                </p:split-sequence>
                <p:delete match="/*/@xml:base"/>
                <p:choose>
                    <p:when test="$media-type='text/css'">
                        <p:documentation>In-memory file is CSS; unwrap it and store as text.</p:documentation>
                        <p:string-replace match="/text()" replace="''"/>
                        <p:store method="text">
                            <p:with-option name="href" select="$target"/>
                        </p:store>
                    </p:when>
                    <p:otherwise>
                        <p:documentation>In-memory file stored as-is.</p:documentation>
                        <p:store>
                            <p:with-option name="href" select="$target"/>
                        </p:store>
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
                <p:sink/>
            </p:when>
            <p:otherwise>
                <p:documentation>File is already on disk; copy it to the new location.</p:documentation>
                <p:sink/>
                <px:copy>
                    <p:with-option name="href" select="$on-disk"/>
                    <p:with-option name="target" select="$target"/>
                </px:copy>
            </p:otherwise>
        </p:choose>
    </p:for-each>

</p:declare-step>
