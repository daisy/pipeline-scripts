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

    <p:input port="opf-metadata" primary="false"/>
    <p:input port="opf-manifest" primary="false"/>
    <p:input port="opf-spine" primary="false"/>
    <p:output port="store-complete" primary="false">
        <p:pipe port="result" step="store"/>
    </p:output>

    <p:option name="content-dir" required="true"/>

    <p:identity>
        <p:documentation>Construct the outer &lt;opf:package ...&gt;-element.</p:documentation>
        <p:input port="source">
            <p:inline>
                <opf:package version="3.0" profile="http://www.idpf.org/epub/30/profile/package/"/>
            </p:inline>
        </p:input>
    </p:identity>
    <p:insert position="last-child">
        <p:documentation>Inserts the metadata, manifest and spine (in that order) as children of the
            &lt;opf:package ...&gt;-element.</p:documentation>
        <p:input port="insertion">
            <p:pipe port="opf-metadata" step="package"/>
            <p:pipe port="opf-manifest" step="package"/>
            <p:pipe port="opf-spine" step="package"/>
        </p:input>
    </p:insert>
    <p:add-attribute attribute-name="unique-identifier" match="/*" attribute-value="pub-id"/>
    <p:add-attribute attribute-name="xml:lang" match="/*">
        <p:with-option name="attribute-value" select="/opf:package/opf:metadata/dc:language"/>
    </p:add-attribute>
    <p:validate-with-schematron name="validation">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="schema">
            <p:document href="../schemas/epub30/package-30.sch"/>
        </p:input>
    </p:validate-with-schematron>
    <p:store name="store">
        <p:with-option name="href" select="concat($content-dir,'package.opf')"/>
    </p:store>

</p:declare-step>
