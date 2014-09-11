<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-to-daisy3" type="px:dtbook-to-daisy3"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
		xmlns:d="http://www.daisy.org/ns/pipeline/data"
		exclude-inline-prefixes="#all">

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h1 px:role="name">DTBook to DAISY 3</h1>
    <p px:role="desc">Converts multiple dtbooks to daisy 3 format</p>
  </p:documentation>

  <p:input port="source" primary="true" sequence="true" px:media-type="application/x-dtbook+xml">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">DTBook file(s)</h2>
      <p px:role="desc">One or more 2005-3 DTBook files to be transformed. In
      the case of multiple files, the first one will be taken.</p>
    </p:documentation>
  </p:input>

  <p:option name="publisher" required="false" px:type="string" select="''">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">Publisher</h2>
      <p px:role="desc">The agency responsible for making the Digital
      Talking Book available. If left blank, it will be retrieved from
      the DTBook meta-data.</p>
    </p:documentation>
  </p:option>

  <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">Output directory</h2>
      <p px:role="desc">Directory where the resulting DAISY 3 publication is stored.</p>
    </p:documentation>
  </p:option>

  <p:option name="tts-config" required="false" px:type="anyURI" select="''">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name"> Text-To-Speech configuration file</h2>
      <p px:role="desc">Configuration file for the Text-To-Speech.</p>
    </p:documentation>
  </p:option>

  <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/css-speech/library.xpl"/>
  <p:import href="dtbook-to-daisy3.convert.xpl"/>

  <p:split-sequence name="first-dtbook" test="position()=1" initial-only="true"/>
  <p:sink/>
  <p:xslt name="output-dir-uri">
    <p:with-param name="href" select="concat($output-dir,'/')"/>
    <p:input port="source">
      <p:inline>
	<d:file/>
      </p:inline>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
	<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pf="http://www.daisy.org/ns/pipeline/functions" version="2.0">
	  <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>
	  <xsl:param name="href" required="yes"/>
	  <xsl:template match="/*">
	    <xsl:copy>
	      <xsl:attribute name="href" select="pf:normalize-uri($href)"/>
	    </xsl:copy>
	  </xsl:template>
	</xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  <p:sink/>

  <px:dtbook-load name="load">
    <p:input port="source">
      <p:pipe port="source" step="dtbook-to-daisy3"/>
    </p:input>
  </px:dtbook-load>

  <!-- Add the CSS stylesheets to the fileset -->
  <px:fileset-create name="empty-fileset">
    <p:with-option name="base" select="base-uri(/*)">
      <p:pipe port="fileset.out" step="load"/>
    </p:with-option>
  </px:fileset-create>
  <p:try>
    <p:group>
      <p:output port="result"/>
      <p:variable name="fileset-base" select="base-uri(/*)">
	<p:pipe port="fileset.out" step="load"/>
      </p:variable>
      <p:xslt name="get-css">
	<p:with-param name="xhtml-link" select="'true'"/>
	<p:input port="source">
	  <p:pipe port="matched" step="first-dtbook"/>
	</p:input>
	<p:input port="stylesheet">
	  <p:document href="http://www.daisy.org/pipeline/modules/css-utils/xml-to-css-uris.xsl"/>
	</p:input>
      </p:xslt>
      <p:viewport match="//*[@href]">
	<p:add-attribute attribute-name="original-href" match="/*">
	  <p:with-option name="attribute-value" select="resolve-uri(/*/@href, $fileset-base)"/>
	</p:add-attribute>
      </p:viewport>
    </p:group>
    <p:catch>
      <p:output port="result"/>
      <px:message message="CSS stylesheet URI(s) are malformed." severity="WARNING"/>
      <p:identity>
	<p:input port="source">
	  <p:empty/>
	</p:input>
      </p:identity>
    </p:catch>
  </p:try>
  <p:for-each name="css-entries">
    <p:output port="result"/>
    <p:iteration-source select="//*[@original-href]"/>
    <px:fileset-add-entry media-type="text/css">
      <p:input port="source">
	<p:pipe port="result" step="empty-fileset"/>
      </p:input>
      <p:with-option name="original-href" select="/*/@original-href"/>
      <p:with-option name="href" select="/*/@original-href"/>
    </px:fileset-add-entry>
  </p:for-each>
  <px:fileset-join name="fileset.with-css">
    <p:input port="source">
      <p:pipe port="result" step="css-entries"/>
      <p:pipe port="fileset.out" step="load"/>
    </p:input>
  </px:fileset-join>

  <p:choose name="loaded-tts-config">
    <p:when test="$tts-config != ''">
      <p:output port="result" primary="true"/>
      <p:load>
	<p:with-option name="href" select="$tts-config"/>
      </p:load>
    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true">
	<p:inline>
	  <d:config/>
	</p:inline>
      </p:output>
      <p:sink/>
    </p:otherwise>
  </p:choose>

  <p:choose name="css-inlining">
    <p:xpath-context>
      <p:empty/>
    </p:xpath-context>
    <p:when test="$tts-config != ''">
      <p:output port="result" primary="true"/>
      <px:inline-css-speech>
	<p:input port="source">
	  <p:pipe port="matched" step="first-dtbook"/>
	</p:input>
	<p:input port="fileset.in">
	  <p:pipe port="fileset.out" step="load"/>
	</p:input>
	<p:input port="config">
	  <p:pipe port="result" step="loaded-tts-config"/>
	</p:input>
	<p:with-option name="content-type" select="'application/x-dtbook+xml'"/>
      </px:inline-css-speech>
    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true"/>
      <p:identity>
	<p:input port="source">
	  <p:pipe port="matched" step="first-dtbook"/>
	</p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>

  <px:dtbook-to-daisy3-convert name="convert">
    <p:input port="in-memory.in">
      <p:pipe port="result" step="css-inlining"/>
    </p:input>
    <p:input port="fileset.in">
      <p:pipe port="result" step="fileset.with-css"/>
    </p:input>
    <p:input port="config">
      <p:pipe port="result" step="loaded-tts-config"/>
    </p:input>
    <p:with-option name="publisher" select="$publisher"/>
    <p:with-option name="output-fileset-base" select="/*/@href">
      <p:pipe port="result" step="output-dir-uri"/>
    </p:with-option>
    <p:with-option name="audio" select="$tts-config != ''"/>
  </px:dtbook-to-daisy3-convert>

  <px:fileset-store>
    <p:input port="fileset.in">
      <p:pipe port="fileset.out" step="convert"/>
    </p:input>
    <p:input port="in-memory.in">
      <p:pipe port="in-memory.out" step="convert"/>
    </p:input>
  </px:fileset-store>
</p:declare-step>