<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" version="1.0">

    <p:option name="href" required="true"/>
    <p:option name="output" required="true"/>

    <p:import href="fileset-library.xpl"/>
    <p:import href="html-library.xpl"/>
    <p:import href="ncc.xpl"/>
    <p:import href="flow.xpl"/>
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

    <d2e:ncc name="ncc">
        <p:with-option name="href" select="p:resolve-uri($href)">
            <p:inline>
                <irrelevant/>
            </p:inline>
        </p:with-option>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
    </d2e:ncc>

    <d2e:media-overlay name="media-overlay">
        <p:input port="source">
            <p:pipe port="flow" step="ncc"/>
        </p:input>
        <p:input port="ncc-metadata">
            <p:pipe port="metadata" step="ncc"/>
        </p:input>
        <p:with-option name="daisy-dir" select="$daisy-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
    </d2e:media-overlay>

    <d2e:contents name="contents">
        <p:input port="source">
            <p:pipe port="spine-manifest" step="media-overlay"/>
        </p:input>
        <p:input port="id-mapping">
            <p:pipe port="id-mapping" step="media-overlay"/>
        </p:input>
        <p:with-option name="daisy-dir" select="$daisy-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
    </d2e:contents>

    <d2e:resources name="resources">
        <p:input port="source">
            <p:pipe port="resource-manifest" step="ncc"/>
            <p:pipe port="resource-manifest" step="media-overlay"/>
            <p:pipe port="resource-manifest" step="contents"/>
        </p:input>
        <p:with-option name="daisy-dir" select="$daisy-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
    </d2e:resources>

    <d2e:manifest name="manifest">
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
        <p:input port="source">
            <p:pipe port="manifest" step="contents"/>
            <p:pipe port="manifest" step="media-overlay"/>
            <p:pipe port="manifest" step="resources"/>
        </p:input>
    </d2e:manifest>

    <d2e:metadata name="metadata">
        <p:input port="source">
            <p:pipe port="metadata" step="ncc"/>
            <p:pipe port="metadata" step="media-overlay"/>
            <p:pipe port="metadata" step="contents"/>
        </p:input>
    </d2e:metadata>

    <d2e:spine name="spine">
        <p:input port="source">
            <p:pipe port="result" step="manifest"/>
        </p:input>
    </d2e:spine>

    <d2e:navigation name="navigation">
        <p:input port="source">
            <p:pipe port="ncc" step="ncc"/>
        </p:input>
        <p:input port="id-mapping">
            <p:pipe port="id-mapping" step="media-overlay"/>
        </p:input>
        <p:with-option name="content-dir" select="$content-dir"/>
    </d2e:navigation>

    <d2e:package name="package">
        <p:input port="metadata">
            <p:pipe port="result" step="metadata"/>
        </p:input>
        <p:input port="manifest">
            <p:pipe port="result" step="manifest"/>
        </p:input>
        <p:input port="spine">
            <p:pipe port="result" step="spine"/>
        </p:input>
        <p:with-option name="content-dir" select="$content-dir"/>
    </d2e:package>

    <d2e:container name="container">
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
        <p:with-option name="epub-file"
            select="concat($output-dir,
                                        if (string-length(replace(//dc:title,'[^a-zA-Z0-9_ -]',''))&gt;0)
                                            then          replace(//dc:title,'[^a-zA-Z0-9_ -]','')
                                            else          'output'
                                      ,'.epub')">
            <p:pipe port="result" step="metadata"/>
        </p:with-option>
        <p:input port="manifests">
            <p:pipe port="manifest" step="manifest"/>
            <p:pipe port="manifest" step="media-overlay"/>
            <p:pipe port="manifest" step="contents"/>
            <p:pipe port="manifest" step="resources"/>
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
