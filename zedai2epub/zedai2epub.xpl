<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://pipeline.daisy.org/ns/" version="1.0">

    <!--  <p:output port="result"/>-->

    <p:option name="href" required="true"/>
    <p:option name="output" select="'output'"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="get-zedai-refs.xpl"/>
    <p:import href="handle-zedai-refs.xpl"/>


    <!--=========================================================================-->

    <!-- Get the input document from the href option-->

    <!-- TODO: extract to utils-->
    <!--<p:add-attribute match="/c:request" attribute-name="href">
    <p:input port="source">
      <p:inline>
        <c:request method="get"  detailed="false"/>
      </p:inline>
    </p:input>
    <p:with-option name="attribute-value" select="$href"/>
  </p:add-attribute>
  
  <p:http-request/>
  
  <p:unescape-markup encoding="base64" charset="utf8"/>-->

    <p:group name="initialization">
        <p:output port="result"/>
        <p:load name="load">
            <p:with-option name="href" select="$href"/>
        </p:load>
        <p:add-xml-base/>
    </p:group>

    <!--=========================================================================-->

    <!--<p:group name="files-collection">

        <!-\- Get the list of satelite files -\->
        <px:get-refs/>

        <!-\- Move the satellite files -\->
        <!-\- FIXME we need a procesor specific step for remote downloads -\->
        <!-\- TODO output result manifest -\->
        <px:handle-refs>
            <p:with-option name="output" select="$output"/>
        </px:handle-refs>
        
    </p:group>-->


    <!--=========================================================================-->

    <!-- Normalize the source document -->
    <p:identity name="normalization">
        <p:input port="source">
            <p:pipe port="result" step="initialization"/>
        </p:input>
    </p:identity>

    <!--=========================================================================-->

    <p:group name="chunks-preparation">
        <p:output port="result"/>

        <!-- Identify Chunks -->
        <p:xslt name="chunk-marker">
            <p:input port="stylesheet">
                <p:document href="chunk-marker.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <!-- Generate paths of chunks -->
        <p:xslt name="chunk-path-creator">
            <p:input port="stylesheet">
                <p:document href="chunk-path-creator.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <!-- Replace document links to local paths -->
        <p:xslt name="links-to-chunks">
            <p:input port="stylesheet">
                <p:document href="links-to-chunks.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

    </p:group>

    <!--=========================================================================-->

    <p:group name="ncx-creation">
        <p:output port="zedai-ncx" primary="false">
            <p:pipe port="result" step="ncx-items-marker"/>
        </p:output>

        <!-- Identify NCX items -->
        <p:xslt name="ncx-items-marker">
            <p:input port="source">
                <p:pipe port="result" step="chunks-preparation"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="ncx-items-marker.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <!-- Create NCX -->
        <p:xslt name="ncx-builder">
            <p:input port="stylesheet">
                <p:document href="ncx-builder.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <!-- Store the result NCX -->
        <p:store media-type="application/x-dtbncx+xml" doctype-public="-//NISO//DTD ncx 2005-1//EN"
            doctype-system="http://www.daisy.org/z3986/2005/ncx-2005-1.dtd" indent="true"
            encoding="utf-8" omit-xml-declaration="false">
            <p:with-option name="href" select="concat($output,'/toc.ncx')"/>
        </p:store>

    </p:group>

    <!--=========================================================================-->

    <p:group name="opf-creation">

        <!-- Create OPF -->
        <p:xslt name="opf-builder">
            <p:input port="source">
                <p:pipe port="zedai-ncx" step="ncx-creation"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="opf-builder.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <!-- Store the result OPF -->
        <p:store media-type="application/oebps-package+xml" indent="true" encoding="utf-8"
            omit-xml-declaration="false">
            <p:with-option name="href" select="concat($output,'/package.opf')"/>
        </p:store>

    </p:group>

    <!--=========================================================================-->

    <!-- Transform into HTML -->


</p:declare-step>
