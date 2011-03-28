<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" type="d2e:container" name="container" version="1.0">

    <p:input port="manifests" primary="false" sequence="true"/>
    <p:input port="store-complete" primary="false" sequence="true"/>
    <p:output port="result">
        <p:pipe port="result" step="container"/>
    </p:output>

    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>

    <p:import href="html-library.xpl"/>
    <p:import href="fileset-library.xpl"/>
    <p:import href="zip-library.xpl"/>

    <p:documentation><![CDATA[
            input: manifest@navigation
            input: manifest@media-overlay
            input: manifest@documents
            input: manifest@resources
            input: store-complete@package
            input: store-complete@navigation
            input: store-complete@media-overlay
            input: store-complete@documents
            input: store-complete@resources
    ]]></p:documentation>

    <!-- Create container descriptor -->
    <p:add-attribute match="c:container/c:rootfiles/c:rootfile"
        xmlns:c="urn:oasis:names:tc:opendocument:xmlns:container" attribute-name="full-path">
        <p:input port="source">
            <p:inline exclude-inline-prefixes="c">
                <container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
                    <rootfiles>
                        <rootfile media-type="application/oebps-package+xml"/>
                    </rootfiles>
                </container>
            </p:inline>
        </p:input>
        <p:with-option name="attribute-value"
            select="concat(substring-after($content-dir,$epub-dir),'package.opf')"/>
    </p:add-attribute>
    <!-- Store container descriptor -->
    <p:store name="store-container.xml" indent="true" encoding="utf-8" omit-xml-declaration="false">
        <p:with-option name="href" select="concat($epub-dir,'META-INF/container.xml')"/>
    </p:store>

    <!-- Create mimetype -->
    <p:string-replace match="doc/text()" replace="'application/epub+zip'">
        <p:input port="source">
            <p:inline>
                <doc>@@</doc>
            </p:inline>
        </p:input>
    </p:string-replace>
    <p:string-replace match="/text()" replace="''"/>
    <p:store method="text" name="store-mimetype">
        <p:with-option name="href" select="concat($epub-dir,'mimetype')"/>
    </p:store>

    <p:group name="fileset.core">
        <p:output port="result"/>
        <px:create-manifest>
            <p:with-option name="base" select="$epub-dir"/>
        </px:create-manifest>
        <px:add-manifest-entry href="mimetype"/>
        <px:add-manifest-entry href="META-INF/container.xml"/>
        <px:add-manifest-entry media-type="application/oebps-package+xml">
            <p:with-option name="href"
                select="concat(substring-after($content-dir,$epub-dir),'package.opf')"/>
        </px:add-manifest-entry>
    </p:group>
    <px:join-manifests>
        <p:input port="source">
            <p:pipe port="result" step="fileset.core"/>
            <p:pipe port="manifests" step="container"/>
        </p:input>
    </px:join-manifests>
    <px:to-zip-manifest/>
    <p:add-attribute name="zip.manifest" match="c:entry[@name='mimetype']"
        attribute-name="compression-method" attribute-value="stored"/>
    <cx:zip>
        <p:input port="source">
            <p:empty/>
        </p:input>
        <p:input port="manifest">
            <p:pipe port="result" step="zip.manifest"/>
        </p:input>
        <p:with-option name="href" select="$epub-file"/>
    </cx:zip>
    <p:sink/>

</p:declare-step>
