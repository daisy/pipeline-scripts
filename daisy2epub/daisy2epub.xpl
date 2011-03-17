<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" version="1.0">

    <p:option name="href" required="true"/>
    <p:option name="output" select="''"/>

    <p:import href="fileset-library.xpl"/>
    <p:import href="daisy2epub-library.xpl"/>
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
    <p:variable name="epub-file"
        select="p:resolve-uri(
                if ($output='') then concat(
                    if (matches($href,'[^/]+\..+$'))
                    then replace(tokenize($href,'/')[last()],'\..+$','')
                    else tokenize($href,'/')[last()],'.epub')
                else if (ends-with($output,'.epub')) then $output 
                else concat($output,'.epub'))">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>
    <p:variable name="epub-dir" select="p:resolve-uri('epub/',$epub-file)"/>
    <p:variable name="content-dir" select="concat($epub-dir,'Content/')"/>


    <d2e:load-html name="ncc">
        <p:documentation><![CDATA[
            read ncc.html
            primary output: result
        ]]></p:documentation>
        <p:with-option name="href" select="p:resolve-uri($href)">
            <p:inline>
                <irrelevant/>
            </p:inline>
        </p:with-option>
    </d2e:load-html>
    <p:sink/>

    <d2e:flow name="flow">
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:input port="source">
            <p:pipe port="result" step="ncc"/>
        </p:input>
    </d2e:flow>
    <p:sink/>

    <d2e:navigation name="navigation">
        <p:input port="source">
            <p:pipe port="result" step="ncc"/>
        </p:input>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
    </d2e:navigation>

    <d2e:media-overlay name="media-overlay">
        <p:input port="source">
            <p:pipe port="manifest" step="flow"/>
        </p:input>
        <p:with-option name="daisy-dir" select="$daisy-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
    </d2e:media-overlay>

    <d2e:contents name="contents">
        <p:input port="source">
            <p:pipe port="spine-manifest" step="media-overlay"/>
        </p:input>
        <p:with-option name="daisy-dir" select="$daisy-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
    </d2e:contents>

    <d2e:resources name="resources">
        <p:input port="source">
            <p:pipe port="resource-manifest" step="navigation"/>
            <p:pipe port="resource-manifest" step="media-overlay"/>
            <p:pipe port="resource-manifest" step="contents"/>
        </p:input>
        <p:with-option name="daisy-dir" select="$daisy-dir"/>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
    </d2e:resources>

    <d2e:manifest name="manifest">
        <p:input port="source">
            <p:pipe port="manifest" step="navigation"/>
            <p:pipe port="manifest" step="media-overlay"/>
            <p:pipe port="manifest" step="contents"/>
            <p:pipe port="manifest" step="resources"/>
        </p:input>
    </d2e:manifest>

    <d2e:metadata name="metadata">
        <p:input port="source">
            <p:pipe port="metadata" step="navigation"/>
            <p:pipe port="metadata" step="media-overlay"/>
            <p:pipe port="metadata" step="contents"/>
        </p:input>
    </d2e:metadata>
    <p:sink/>

    <d2e:spine name="spine">
        <p:input port="source">
            <p:pipe port="manifest" step="contents"/>
        </p:input>
    </d2e:spine>
    <p:sink/>

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

    <d2e:container>
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:with-option name="epub-dir" select="$epub-dir"/>
        <p:input port="manifests">
            <p:pipe port="manifest" step="navigation"/>
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

</p:pipeline>
