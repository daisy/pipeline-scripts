<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
    type="px:package" name="package" exclude-inline-prefixes="#all" version="1.0">

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
        <xd:option name="content-dir">URI to the directory where all the EPUB 3 content should be
            stored.</xd:option>
    </p:documentation>

    <p:input port="ncc" primary="false"/>
    <p:input port="manifest" primary="false" sequence="true"/>
    
    <p:output port="store-complete" primary="false">
        <p:pipe port="result" step="store"/>
    </p:output>

    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>

    <p:documentation>Compile OPF metadata.</p:documentation>
    <p:group name="opf-metadata">
        <p:output port="result" primary="true"/>

        <p:xslt>
            <p:input port="source">
                <p:pipe port="ncc" step="package"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="ncc2metadata.xsl"/>
            </p:input>
        </p:xslt>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="metadata2opf-metadata.xsl"/>
            </p:input>
        </p:xslt>
    </p:group>
    <p:sink/>

    <p:documentation>Compile OPF manifest.</p:documentation>
    <p:group name="opf-manifest">
        <p:output port="result" primary="true"/>
        <p:output port="fileset">
            <p:pipe port="result" step="opf-manifest.fileset"/>
        </p:output>

        <px:fileset-join name="input-manifest">
            <p:input port="source">
                <p:pipe port="manifest" step="package"/>
            </p:input>
        </px:fileset-join>
        <p:sink/>

        <px:fileset-create>
            <p:with-option name="base" select="$epub-dir"/>
        </px:fileset-create>
        <px:fileset-add-entry name="opf-manifest.navigation-manifest">
            <p:with-option name="href"
                select="concat(substring-after($content-dir,$epub-dir),'navigation.xhtml')"/>
            <p:with-option name="media-type" select="'application/xhtml+xml'"/>
        </px:fileset-add-entry>
        <p:sink/>

        <px:fileset-join name="opf-manifest.fileset">
            <p:input port="source">
                <p:pipe port="manifest" step="package"/>
                <p:pipe port="result" step="opf-manifest.navigation-manifest"/>
            </p:input>
        </px:fileset-join>
        <p:xslt name="opf-manifest.result">
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="manifest2opf-manifest.xsl"/>
            </p:input>
        </p:xslt>
    </p:group>

    <p:documentation>Compile OPF spine.</p:documentation>
    <p:xslt name="opf-spine">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="manifest2opf-spine.xsl"/>
        </p:input>
    </p:xslt>
    <p:sink/>

    <p:identity>
        <p:documentation>Construct the outer &lt;opf:package ...&gt;-element.</p:documentation>
        <p:input port="source">
            <p:inline>
                <package xmlns="http://www.idpf.org/2007/opf" version="3.0" profile="http://www.idpf.org/epub/30/profile/package/"/>
            </p:inline>
        </p:input>
    </p:identity>
    <p:insert position="last-child">
        <p:documentation>Inserts the metadata, manifest and spine (in that order) as children of the
            &lt;opf:package ...&gt;-element.</p:documentation>
        <p:input port="insertion">
            <p:pipe port="result" step="opf-metadata"/>
            <p:pipe port="result" step="opf-manifest"/>
            <p:pipe port="result" step="opf-spine"/>
        </p:input>
    </p:insert>
    <p:add-attribute attribute-name="unique-identifier" match="/*" attribute-value="pub-id"/>
    <p:add-attribute attribute-name="xml:lang" match="/*">
        <p:with-option name="attribute-value" select="/opf:package/opf:metadata/dc:language"/>
    </p:add-attribute>
    
    <p:store name="store">
        <p:with-option name="href" select="concat($content-dir,'package.opf')"/>
    </p:store>

</p:declare-step>
