<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:z="http://www.daisy.org/ns/z3986/authoring/" xmlns:px="http://pipeline.daisy.org/ns/"
  version="1.0" name="main" type="px:get-refs" exclude-inline-prefixes="z px">

  <p:input port="source"/>
  <p:output port="result"/>

  <p:documentation>
    <p>Gets the satellite files referenced from a ZedAI document</p>
    <p>From the core elements:</p>
    <ul>
      <li>//object/@src (possibly combined with //object/@srctype</li>
      <li>//separator/@src</li>
      <li>//description/@xlink:href</li>
      <li>//ref/@ref (often contains local links)</li>
      <li>//ref/@xlink:href</li>
    </ul>
    <p>If the SVG feature is present:</p>
    <ul>
      <li>//object/@src with @srctype="image/svg+xml</li>
    </ul>
    <p>Internal-only links:</p>
    <ul>
      <li>//abbr/@ref pointing to a //definition</li>
      <li>//annoref/@ref pointing to a //annotation</li>
      <li>//annotation/@ref pointing to a //*[@xml:id]</li>
      <li>//caption/@ref pointing to the component(s) to which the caption applies.</li>
      <li>//citation/@ref pointing to the passage (epigraph, quote, etc.) that constitutes the
        quotation</li>
      <li>//d/@ref pointing to a character in a dramatis personae</li>
      <li>//description/@ref</li>
      <li>//hd/@ref pointing to the construct that it acts as a heading for.</li>
      <li>//note/@ref if the note hasn't a referent noteref</li>
      <li>//noteref/@ref pointing to its associated note</li>
      <li>//term/@ref pointing to a definition</li>
    </ul>
    <p>Non-retrieved links:</p>
    <ul>
      <li>//citation/@xlink:href</li>
    </ul>
  </p:documentation>

  <p:declare-step type="px:make-file-entry">
    <p:option name="uri" required="true"/>
    <p:option name="base-uri"/>
    <p:output port="result"/>
    <p:string-replace match="/file/text()">
      <p:input port="source">
        <p:inline>
          <file>@@</file>
        </p:inline>
      </p:input>
      <p:with-option name="replace" select="concat('&quot;',$uri,'&quot;')"/>
    </p:string-replace>
    <p:add-attribute attribute-name="xml:base" match="/*">
      <p:with-option name="attribute-value" select="$base-uri"/>
    </p:add-attribute>
  </p:declare-step>

  <p:for-each name="links">
    <p:iteration-source select="//z:object"/>
    <p:output port="result"/>
    <px:make-file-entry>
      <p:with-option name="uri" select="/z:object/@src"/>
      <p:with-option name="base-uri" select="base-uri(/z:object)"/>
    </px:make-file-entry>
  </p:for-each>

  <p:wrap-sequence wrapper="files">
    <p:input port="source">
      <p:pipe step="links" port="result"/>
    </p:input>
  </p:wrap-sequence>
  
  <p:add-attribute attribute-name="xml:base" match="/files">
    <p:with-option name="attribute-value" select="base-uri()">
      <p:pipe port="source" step="main"/>
    </p:with-option>
  </p:add-attribute>
  <p:add-xml-base/>

</p:declare-step>
