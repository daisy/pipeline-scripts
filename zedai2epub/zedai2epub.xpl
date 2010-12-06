<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:px="http://pipeline.daisy.org/ns/"
  version="1.0">
  
  <p:output port="result"/>
  
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
  
  <p:load name="load">
    <p:with-option name="href" select="$href"/>
  </p:load>
  
<!--=========================================================================-->
  
  <!-- Get the list of satelite files -->
  <px:get-refs/>

<!--=========================================================================-->
  
  <!-- Move the satellite files -->
  <!-- FIXME we need a procesor specific step for remote downloads -->
  <px:handle-refs>
    <p:with-option name="output" select="$output"/>
  </px:handle-refs>
  <!-- TODO output result manifest -->
  
<!--=========================================================================-->
  
  <!-- Normalize the source document -->
  <p:identity>
    <p:input port="source">
      <p:pipe port="result" step="load"/>
    </p:input>
  </p:identity>
  <p:add-xml-base/>
  
<!--=========================================================================-->
  
  <!-- Identify NCX items -->
  <p:xslt name="ncx-items-marker">
    <p:input port="stylesheet">
      <p:document href="ncx-items-marker.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  
<!--=========================================================================-->
  
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
  
<!--=========================================================================-->
  
  <!-- Replace document links to local paths -->
  <p:xslt name="links-to-chunks">
    <p:input port="stylesheet">
      <p:document href="links-to-chunks.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  
<!--=========================================================================-->
  
  <!-- Create NCX -->
  
<!--=========================================================================-->
  
  <!-- Create OPF -->
  
<!--=========================================================================-->
  
  <!-- Create chunks -->
  
  
</p:declare-step>