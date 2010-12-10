<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:px="http://pipeline.daisy.org/ns/" version="1.0" type="px:handle-refs"
  exclude-inline-prefixes="px">

  <p:input port="source"/>
  <p:option name="output" select="'output/'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="fileutils-library.xpl"/>

  <!-- TODO use a path util function to enforce the trailing slash -->
  <p:variable name="output-ok"
    select="if ($output='') then 'output/' 
    else if (ends-with($output,'/')) then $output 
    else concat($output,'/')"/>

  <p:for-each>
    <p:iteration-source select="/files/file"/>
    <p:variable name="href" select="resolve-uri(/file, base-uri(/file))"/>
    <p:variable name="target" select="resolve-uri(/file, $output-ok)"/>
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

</p:declare-step>
