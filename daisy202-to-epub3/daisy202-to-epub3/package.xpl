<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:xd="http://www.daisy.org/ns/pipeline/doc" type="pxi:daisy202-to-epub3-package"
    name="package" exclude-inline-prefixes="#all" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Compile and store the OPF.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:input port="opf-metadata">Metadata in OPF-format.</xd:input>
        <xd:input port="opf-manifest">Manifest in OPF-format.</xd:input>
        <xd:input port="opf-spine">Spine in OPF-format.</xd:input>
        <xd:output port="store-complete">Pipe connection for 'p:store'-dependencies.</xd:output>
        <xd:option name="publication-dir">URI to the directory where all the EPUB 3 content should be stored.</xd:option>
    </p:documentation>

    <!--<p:input port="flow" primary="false"/>-->
    <p:input port="spine" primary="false" sequence="true"/>
    <p:input port="ncc" primary="false"/>
    <p:input port="navigation" primary="false"/>
    <p:input port="content-docs" sequence="true"/>
    <p:input port="mediaoverlay" sequence="true"/>
    <p:input port="resources" primary="false"/>

    <p:output port="opf-package" sequence="true" primary="true">
        <p:pipe port="result" step="opf-package"/>
    </p:output>
    <p:output port="fileset" primary="false">
        <p:pipe port="result" step="result-fileset"/>
    </p:output>
    <p:output port="store-complete" primary="false">
        <p:pipe port="result" step="store"/>
    </p:output>

    <p:option name="pub-id" required="true"/>
    <p:option name="compatibility-mode" required="true"/>
    <p:option name="publication-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/xproc/epub3-pub-library.xpl"/>

    <p:variable name="result-uri" select="concat($publication-dir,'package.opf')"/>

    <p:documentation>Compile OPF metadata.</p:documentation>
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
        <p:variable name="base" select="/*/@xml:base">
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
        <p:with-option name="result-uri" select="$result-uri"/>
        <p:with-option name="compatibility-mode" select="$compatibility-mode"/>
        <p:with-option name="detect-properties" select="'false'"/>
    </px:epub3-pub-create-package-doc>

    <p:identity name="opf-package"/>

    <p:store name="store" indent="true">
        <p:with-option name="href" select="$result-uri"/>
    </p:store>

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
