<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:px="http://pipeline.daisy.org/ns/" version="1.0" type="px:handle-refs"
  exclude-inline-prefixes="px" name="main">

  <p:input port="source"/>
  <p:output port="result"/>
  <p:option name="output" select="'output/'"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <!--FIXME import utils from absolute URIs-->
  <p:import href="../../../../utilities/files/fileutils-library.xpl"/>

  <!-- TODO move this to XPath utils ? -->
  <p:variable name="output-dir"
    select="resolve-uri(
    if ($output='') then 'output/' 
    else if (ends-with($output,'/')) then $output 
    else concat($output,'/'),
    base-uri())">
    <p:inline>
      <irrelevant/>
    </p:inline>
  </p:variable>

  <p:for-each>
    <p:iteration-source select="/c:manifest/c:entry"/>
    <p:variable name="href" select="resolve-uri(*/@href, base-uri())"/>
    <p:variable name="target" select="resolve-uri(*/@href, $output-dir)"/>
    <cxf:mkdir name="mkdir">
      <p:with-option name="href" select="replace($target,'[^/]+$','')"/>
    </cxf:mkdir>
    <cxf:copy>
      <p:with-option name="href" select="$href">
        <!-- hack to define the execution order -->
        <p:pipe port="result" step="mkdir"/>
      </p:with-option>
      <p:with-option name="target" select="$target"/>
    </cxf:copy>
  </p:for-each>
  
  <p:add-attribute attribute-name="xml:base" match="/*">
    <p:input port="source">
      <p:pipe port="source" step="main"/>
    </p:input>
    <p:with-option name="attribute-value" select="$output-dir"/>
  </p:add-attribute>

</p:declare-step>
