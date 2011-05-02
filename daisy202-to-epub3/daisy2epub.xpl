<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" xmlns:xd="http://pipeline.daisy.org/ns/sample/doc"
    version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Transforms a DAISY 2.02-book into an EPUB 3-book.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:version>1.0</xd:version>
        <xd:see>http://code.google.com/p/daisy-pipeline/</xd:see>
        <xd:option name="href">Path to input NCC.</xd:option>
        <xd:option name="output">Path to output directory for the EPUB.</xd:option>
        <xd:import href="ncc.xpl">For loading the NCC.</xd:import>
        <xd:import href="media-overlay.xpl">For processing SMIL timesheets.</xd:import>
        <xd:import href="contents.xpl">For processing content documents.</xd:import>
        <xd:import href="resources.xpl">For processing auxiliary resources.</xd:import>
        <xd:import href="metadata.xpl">For compiling metadata.</xd:import>
        <xd:import href="manifest.xpl">For compiling the manifest.</xd:import>
        <xd:import href="spine.xpl">For compiling the spine.</xd:import>
        <xd:import href="navigation.xpl">For making the navigation document.</xd:import>
        <xd:import href="package.xpl">For making the package document.</xd:import>
        <xd:import href="container.xpl">For packaging the publication as a ZIP (OCF).</xd:import>
    </p:documentation>
    
    <p:option name="href" required="true"/>
    <p:option name="output" required="true"/>

    <p:import href="ncc.xpl"/>
    <p:import href="navigation.xpl"/>
    <p:import href="media-overlay.xpl"/>
    <p:import href="contents.xpl"/>
    <p:import href="resources.xpl"/>
    <p:import href="metadata.xpl"/>
    <p:import href="manifest.xpl"/>
    <p:import href="spine.xpl"/>
    <p:import href="package.xpl"/>
    <p:import href="container.xpl"/>

    <p:variable name="daisy-dir" select="replace(p:resolve-uri($href),'[^/]+$','')">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>
    <p:variable name="output-dir"
        select="if (ends-with(p:resolve-uri($output),'/'))
                    then p:resolve-uri($output)
                    else concat(p:resolve-uri($output),'/')">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>
    <p:variable name="epub-dir" select="concat($output-dir,'epub/')"/>
    <p:variable name="content-dir" select="concat($epub-dir,'Content/')"/>

    <p:documentation>Load the DAISY 2.02 NCC.</p:documentation>
    <d2e:ncc name="ncc">
        <p:with-option name="href" select="p:resolve-uri($href)">
            <p:inline>
                <irrelevant/>
            </p:inline>
        </p:with-option>
    </d2e:ncc>

    <p:documentation>Load the DAISY 2.02 SMILs and store them as EPUB 3 SMILs.</p:documentation>
    <d2e:media-overlay name="media-overlay">
        <p:log port="spine-manifest" href="/home/jostein/Skrivebord/log.xml"/>
        <p:log port="id-mapping" href="/home/jostein/Skrivebord/log2.xml"/>
        <p:input port="flow">
            <p:pipe port="flow" step="ncc"/>
        </p:input>
        <p:input port="ncc-metadata">
            <p:pipe port="metadata" step="ncc"/>
        </p:input>
        <p:with-option name="daisy-dir" select="$daisy-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
    </d2e:media-overlay>
    
    
    <p:documentation>Load the DAISY 2.02 text content documents and store them as EPUB 3 Content
        Documents.</p:documentation>
    <d2e:contents name="contents">
        <p:input port="spine">
            <p:pipe port="spine-manifest" step="media-overlay"/>
        </p:input>
        <p:input port="id-mapping">
            <p:pipe port="id-mapping" step="media-overlay"/>
        </p:input>
        <p:with-option name="daisy-dir" select="$daisy-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
    </d2e:contents>

    <p:documentation>Copy all referenced auxilliary resources (audio, stylesheets, images,
        etc.)</p:documentation>
    <d2e:resources name="resources">
        <p:input port="resource-manifests">
            <p:pipe port="resource-manifest" step="ncc"/>
            <p:pipe port="resource-manifest" step="media-overlay"/>
            <p:pipe port="resource-manifest" step="contents"/>
        </p:input>
        <p:with-option name="daisy-dir" select="$daisy-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
    </d2e:resources>

    <p:documentation>Compile OPF metadata.</p:documentation>
    <d2e:metadata name="metadata">
        <p:input port="metadata">
            <p:pipe port="metadata" step="ncc"/>
            <p:pipe port="metadata" step="media-overlay"/>
            <p:pipe port="metadata" step="contents"/>
        </p:input>
    </d2e:metadata>

    <p:documentation>Compile OPF manifest.</p:documentation>
    <d2e:manifest name="manifest">
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
        <p:input port="source-manifest">
            <p:pipe port="manifest" step="contents"/>
            <p:pipe port="manifest" step="media-overlay"/>
            <p:pipe port="manifest" step="resources"/>
        </p:input>
    </d2e:manifest>

    <p:documentation>Compile OPF spine.</p:documentation>
    <d2e:spine name="spine">
        <p:input port="opf-manifest">
            <p:pipe port="opf-manifest" step="manifest"/>
        </p:input>
    </d2e:spine>

    <p:documentation>Make and store the EPUB 3 Navigation Document based on the DAISY 2.02
        NCC.</p:documentation>
    <d2e:navigation name="navigation">
        <p:input port="ncc">
            <p:pipe port="ncc" step="ncc"/>
        </p:input>
        <p:input port="id-mapping">
            <p:pipe port="id-mapping" step="media-overlay"/>
        </p:input>
        <p:with-option name="content-dir" select="$content-dir"/>
    </d2e:navigation>

    <p:documentation>Make and store the OPF.</p:documentation>
    <d2e:package name="package">
        <p:input port="opf-metadata">
            <p:pipe port="opf-metadata" step="metadata"/>
        </p:input>
        <p:input port="opf-manifest">
            <p:pipe port="opf-manifest" step="manifest"/>
        </p:input>
        <p:input port="opf-spine">
            <p:pipe port="opf-spine" step="spine"/>
        </p:input>
        <p:with-option name="content-dir" select="$content-dir"/>
    </d2e:package>

    <p:documentation>Package the EPUB 3 fileset as a ZIP-file (OCF).</p:documentation>
    <d2e:container name="container">
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
        <p:with-option name="epub-file"
            select="concat($output-dir,
                                        if (string-length(replace(//dc:title,'[^a-zA-Z0-9_ -]',''))&gt;0)
                                            then          replace(//dc:title,'[^a-zA-Z0-9_ -]','')
                                            else          'output'
                                      ,'.epub')">
            <p:pipe port="opf-metadata" step="metadata"/>
        </p:with-option>
        <p:input port="manifests">
            <p:pipe port="result-manifest" step="manifest"/>
        </p:input>
        <p:input port="store-complete">
            <p:pipe port="store-complete" step="navigation"/>
            <p:pipe port="store-complete" step="media-overlay"/>
            <p:pipe port="store-complete" step="contents"/>
            <p:pipe port="store-complete" step="resources"/>
            <p:pipe port="store-complete" step="package"/>
        </p:input>
    </d2e:container>

</p:declare-step>
