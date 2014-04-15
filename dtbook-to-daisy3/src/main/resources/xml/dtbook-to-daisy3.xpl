<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-to-daisy3" type="px:dtbook-to-daisy3"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
		xmlns:d="http://www.daisy.org/ns/pipeline/data"
		exclude-inline-prefixes="#all">

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h1 px:role="name">DTBook to DAISY 3</h1>
    <p px:role="desc">Converts multiple dtbooks to daisy 3 format</p>
  </p:documentation>

  <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/dtbook-break-detection/library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/ssml-to-audio/ssml-to-audio.xpl" />
  <p:import href="http://www.daisy.org/pipeline/modules/ssml-to-audio/create-audio-fileset.xpl" />
  <p:import href="http://www.daisy.org/pipeline/modules/dtbook-to-ssml/dtbook-to-ssml.xpl" />
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="dtbook-to-daisy3.convert.xpl"/>

  <p:input port="source" primary="true" sequence="true" px:media-type="application/x-dtbook+xml">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">DTBook file(s)</h2>
      <p px:role="desc">One or more DTBook files to be transformed. In
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

  <p:option name="audio" required="false" px:type="boolean" select="'true'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">Enable Text-To-Speech</h2>
      <p px:role="desc">Whether to use a speech synthesizer to produce audio files.</p>
    </p:documentation>
  </p:option>

  <p:option name="aural-css" required="false" px:type="anyURI" select="''">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">Aural CSS sheet</h2>
      <p px:role="desc">Path of an additional Aural CSS stylesheet for the Text-To-Speech.</p>
    </p:documentation>
  </p:option>

  <p:option name="ssml-of-lexicons-uris" required="false" px:type="anyURI" select="''">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">Lexicons SSML pointers</h2>
      <p px:role="desc">URI of an SSML file which contains a list of
      lexicon elements with their URI. The lexicons will be provided
      to the Text-To-Speech processors.</p>
    </p:documentation>
  </p:option>

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
	  <p:document href="http://www.daisy.org/pipeline/modules/file-utils/css-stylesheet-uris.xsl"/>
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
      <cx:message message="warning: CSS stylesheet URI(s) are malformed."/>
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

  <!-- Find the sentences and the words, even if the Text-To-Speech is off. -->
  <p:for-each name="lexing">
    <p:iteration-source>
      <!-- For now, the for-each is actually not needed since there is
           only one DTBook. -->
      <p:pipe port="matched" step="first-dtbook"/>
    </p:iteration-source>
    <p:output port="result">
      <p:pipe port="result" step="break"/>
    </p:output>
    <p:output port="sentence-ids">
      <p:pipe port="sentence-ids" step="break"/>
    </p:output>
    <px:dtbook-break-detect name="break"/>
  </p:for-each>

  <!-- Optional call to the Text-To-Speech processor. -->
  <p:choose name="synthesize">
    <p:when test="$audio = 'false'">
      <p:output port="audio-map"/>
      <p:identity>
	<p:input port="source">
	  <p:inline>
	    <d:audio-clips/>
	  </p:inline>
	</p:input>
      </p:identity>
    </p:when>
    <p:otherwise>
      <p:output port="audio-map">
	<p:pipe port="result" step="to-audio"/>
      </p:output>
      <p:for-each name="for-each.content">
	<p:iteration-source>
	  <p:pipe port="result" step="lexing"/>
	</p:iteration-source>
	<p:output port="ssml.out" primary="true" sequence="true">
	  <p:pipe port="result" step="ssml-gen"/>
	</p:output>
	<p:split-sequence name="sentences">
	  <p:input port="source">
	    <p:pipe port="sentence-ids" step="lexing"/>
	  </p:input>
	  <p:with-option name="test" select="concat('position()=', p:iteration-position())"/>
	</p:split-sequence>
	<px:dtbook-to-ssml name="ssml-gen">
	  <p:input port="content.in">
	    <p:pipe port="current" step="for-each.content"/>
	  </p:input>
	  <p:input port="sentence-ids">
	    <p:pipe port="matched" step="sentences"/>
	  </p:input>
	  <p:input port="fileset.in">
	    <p:pipe port="fileset.out" step="load"/>
	  </p:input>
	  <p:with-option name="css-sheet-uri" select="$aural-css"/>
	  <p:with-option name="ssml-of-lexicons-uris" select="$ssml-of-lexicons-uris"/>
	</px:dtbook-to-ssml>
      </p:for-each>
      <px:ssml-to-audio name="to-audio"/>
    </p:otherwise>
  </p:choose>

  <px:dtbook-to-daisy3-convert name="convert">
    <p:input port="in-memory.in">
      <p:pipe port="result" step="lexing"/>
    </p:input>
    <p:input port="fileset.in">
      <p:pipe port="result" step="fileset.with-css"/>
    </p:input>
    <p:input port="audio-map">
      <p:pipe port="audio-map" step="synthesize"/>
    </p:input>
    <p:with-option name="publisher" select="$publisher"/>
    <p:with-option name="output-fileset-base" select="/*/@href">
      <p:pipe port="result" step="output-dir-uri"/>
    </p:with-option>
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
