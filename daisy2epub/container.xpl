<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" xmlns:xd="http://pipeline.daisy.org/ns/sample/doc"
    type="d2e:container" name="container" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Package the EPUB 3 fileset in a ZIP (OCF).</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:input port="manifests">Manifest of all Media Overlays, Content Documents (including the
            Navigation Document), and auxiliary resources.</xd:input>
        <xd:input port="store-complete">Pipe from all other 'p:store'-operations which is used to
            prevent any further operations on those files until they are completely
            stored.</xd:input>
        <xd:output port="result">A ZIP manifest containing the URI to the resulting EPUB 3 file, as
            well as all the entries in the ZIP-file.</xd:output>
        <xd:option name="content-dir">URI to the directory where all the EPUB 3 content should be
            stored.</xd:option>
        <xd:option name="epub-dir">URI to the directory where the OCF is being created.</xd:option>
        <xd:option name="epub-file">URI to the output file.</xd:option>
        <xd:import href="../utilities/files/fileset-library.xpl">For manipulating
            filesets.</xd:import>
        <xd:import href="../utilities/zip/zip-library.xpl">For making ZIP-files.</xd:import>
    </p:documentation>

    <p:input port="manifests" primary="false" sequence="true"/>
    <p:input port="store-complete" primary="false" sequence="true"/>
    <p:output port="result" primary="false">
        <p:pipe port="result" step="epub-zip"/>
    </p:output>

    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>
    <p:option name="epub-file" required="true"/>

    <p:import href="../utilities/files/fileset-library.xpl"/>
    <p:import href="../utilities/zip/zip-library.xpl"/>

    <p:documentation>Create container descriptor.</p:documentation>
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

    <p:documentation>Store container descriptor.</p:documentation>
    <p:store name="store-container.xml" indent="true" encoding="utf-8" omit-xml-declaration="false">
        <p:with-option name="href" select="concat($epub-dir,'META-INF/container.xml')"/>
    </p:store>

    <p:documentation>Create 'mimetype'-file.</p:documentation>
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

    <p:documentation>Add 'mimetype', 'META-INF/container.xml' and 'Content/package.opf' to the
        manifest.</p:documentation>
    <p:group>
        <p:output port="result"/>
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
    </p:group>

    <p:documentation>Transform the fileset manifest into a ZIP-manifest.</p:documentation>
    <p:group name="zip.manifest">
        <p:output port="result"/>
        <px:to-zip-manifest/>
        <p:add-attribute match="c:entry[@name='mimetype']" attribute-name="compression-method"
            attribute-value="stored"/>
    </p:group>

    <p:documentation>ZIP it.</p:documentation>
    <cx:zip name="epub-zip">
        <p:input port="source">
            <p:empty/>
        </p:input>
        <p:input port="manifest">
            <p:pipe port="result" step="zip.manifest"/>
        </p:input>
        <!--
            href must be a file path, not a URI. See Calabash issue 140:
            http://code.google.com/p/xmlcalabash/issues/detail?id=140
            
            replace(...) should be replaced with px:uri-to-path or similar function (not yet implemented)
        -->
        <p:with-option name="href" select="replace($epub-file,'file:','')"/>
    </cx:zip>
    <p:sink/>

</p:declare-step>
