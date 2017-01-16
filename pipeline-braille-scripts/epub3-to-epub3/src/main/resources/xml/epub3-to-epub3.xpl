<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-to-epub3" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:rendition="http://www.idpf.org/2013/rendition"
                exclude-inline-prefixes="#all"
                name="main">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Braille in EPUB 3</h1>
        <p px:role="desc">Transforms an EPUB 3 publication into an EPUB 3 publication with a braille rendition.</p>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Bert Frees</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:bertfrees@gmail.com">bertfrees@gmail.com</a></dd>
        </dl>
    </p:documentation>
    
    <p:option name="source" required="true" px:type="anyFileURI" px:media-type="application/epub+zip">
        <p:documentation>
            <h2 px:role="name">Input EPUB 3</h2>
        </p:documentation>
    </p:option>
    
    <p:option name="braille-translator" required="false" px:data-type="transform-query" select="'(translator:liblouis)'">
        <p:documentation>
            <h2 px:role="name">Braille translator query</h2>
        </p:documentation>
    </p:option>
    
    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">Output EPUB 3</h2>
        </p:documentation>
    </p:option>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/zip-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    
    <p:variable name="stylesheet" select="resolve-uri('../css/default.css')">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>
    
    <p:variable name="source.base" select="concat($source,'!/')"/>
    
    <px:fileset-create name="target.base.fileset">
        <p:with-option name="base" select="concat($output-dir,'/',replace($source,'^.*/(([^/]+)\.epub|([^/]+))$','$2$3.epub'),'!/')"/>
    </px:fileset-create><p:group>
    
    <p:variable name="target.base" select="base-uri(/*)"/>
    <p:variable name="target" select="substring-before($target.base,'!/')"/>
    
    <px:unzip name="source-zipfile">
        <p:with-option name="href" select="$source"/>
    </px:unzip>
    <p:for-each>
        <p:iteration-source select="//c:file[not(@name='META-INF/container.xml')]"/>
        <p:variable name="href" select="/*/@name"/>
        <px:fileset-add-entry>
            <p:input port="source">
                <p:pipe step="target.base.fileset" port="result"/>
            </p:input>
            <p:with-option name="href" select="$href"/>
            <p:with-option name="original-href" select="resolve-uri($href,$source.base)"/>
        </px:fileset-add-entry>
    </p:for-each>
    <px:fileset-join name="source.fileset"/>
    <px:fileset-load name="source.in-memory">
        <p:input port="in-memory">
            <p:empty/>
        </p:input>
    </px:fileset-load>
    <p:sink/>
    
    <px:unzip file="META-INF/container.xml" content-type="application/xml" name="original-container">
        <p:with-option name="href" select="$source"/>
    </px:unzip>
    
    <!--
        default rendition package document
    -->
    
    <px:unzip content-type="application/oebps-package+xml">
        <p:with-option name="href" select="$source"/>
        <p:with-option name="file" select="//ocf:rootfile[1]/@full-path"/>
    </px:unzip>
    <p:add-attribute match="/*" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="resolve-uri(//ocf:rootfile[1]/@full-path,$target.base)">
            <p:pipe step="original-container" port="result"/>
        </p:with-option>
    </p:add-attribute>
    <p:delete match="/*/@xml:base" name="default-rendition.package-document"/>
    
    <!--
        braille rendition file set
    -->
    
    <p:xslt name="braille-rendition.fileset">
        <p:input port="source">
            <p:pipe step="target.base.fileset" port="result"/>
            <p:pipe step="default-rendition.package-document" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="braille-rendition.fileset.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!--
        braille rendition package document
    -->
    
    <p:xslt name="braille-rendition.package-document">
        <p:input port="source">
            <p:pipe step="default-rendition.package-document" port="result"/>
            <p:pipe step="braille-rendition.fileset" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="braille-rendition.package-document.xsl"/>
        </p:input>
        <p:with-param name="braille-rendition.package-document.base"
                      select="resolve-uri('EPUB/package-braille.opf',$target.base)"/>
    </p:xslt>
    
    <!--
        metadata.xml
    -->
    
    <p:identity>
        <p:input port="source">
            <p:inline xmlns="http://www.idpf.org/2007/opf">
<metadata xmlns:dcterms="http://purl.org/dc/terms/"/></p:inline>
        </p:input>
    </p:identity>
    <p:add-attribute match="/opf:metadata" attribute-name="unique-identifier">
        <p:with-option name="attribute-value" select="/opf:package/@unique-identifier">
            <p:pipe step="braille-rendition.package-document" port="result"/>
        </p:with-option>
    </p:add-attribute>
    <p:insert match="/opf:metadata" position="last-child">
        <p:input port="insertion" select="for $unique-identifier in /opf:package/@unique-identifier
                                          return /opf:package/opf:metadata/dc:identifier[@id=$unique-identifier]">
            <p:pipe step="braille-rendition.package-document" port="result"/>
        </p:input>
    </p:insert>
    <p:insert match="/opf:metadata" position="last-child">
        <p:input port="insertion" select="/opf:package/opf:metadata/opf:meta[@property='dcterms:modified']">
            <p:pipe step="braille-rendition.package-document" port="result"/>
        </p:input>
    </p:insert>
    <p:add-attribute match="/*" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="resolve-uri('META-INF/metadata.xml',$target.base)"/>
    </p:add-attribute>
    <p:delete match="/*/@xml:base"/>
    <p:identity name="metadata"/>
    
    <!--
        braille rendition xhtml documents
    -->
    <px:fileset-filter media-types="application/xhtml+xml" name="braille-rendition.html.fileset">
        <p:input port="source">
            <p:pipe step="braille-rendition.fileset" port="result"/>
        </p:input>
    </px:fileset-filter>
    <p:label-elements match="d:file" attribute="original-href">
        <p:with-option name="label" select="concat('resolve-uri(@original-href,&quot;',$source.base,'&quot;)')"/>
    </p:label-elements>
    <px:fileset-load>
        <p:input port="in-memory">
            <p:empty/>
        </p:input>
    </px:fileset-load>
    <p:for-each name="braille-rendition.html">
        <p:output port="result" primary="true">
            <p:pipe step="result" port="result"/>
        </p:output>
        <p:output port="resource-map" sequence="true">
            <p:pipe step="resource-map" port="result"/>
        </p:output>
        <p:variable name="lang" select="(/*/opf:metadata/dc:language[not(@refines)])[1]/text()">
            <p:pipe port="result" step="default-rendition.package-document"/>
        </p:variable>
        <px:message message="Generating $1" severity="INFO">
            <p:with-option name="param1" select="substring-after(base-uri(/*),'!/')"/>
        </px:message>
        <css:inline>
            <p:input port="context">
                <p:pipe step="source.in-memory" port="result"/>
            </p:input>
            <p:with-option name="default-stylesheet" select="$stylesheet"/>
        </css:inline>
        <p:delete match="/html:html/html:head/html:style[@type='text/css']|
                         /html:html/html:head/html:link[@type='text/css' and @rel='stylesheet']"/>
        <px:transform name="transform">
            <p:with-option name="query" select="concat('(input:html)(input:css)(output:html)(output:css)(output:braille)',
                                                       $braille-translator,
                                                       '(locale:',$lang,')')"/>
        </px:transform>
        <p:xslt>
            <p:input port="source">
                <p:pipe step="transform" port="result"/>
                <p:pipe step="braille-rendition.fileset" port="result"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="update-cross-references.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:delete match="@style" name="result"/>
        <p:group>
            <p:variable name="braille-rendition.html.base" select="base-uri(/*)">
                <p:pipe step="braille-rendition.html" port="current"/>
            </p:variable>
            <p:variable name="default-rendition.html.base"
                        select="//d:file[resolve-uri(@href,base-uri(.))=$braille-rendition.html.base]
                                /resolve-uri(@original-href,base-uri(.))">
                <p:pipe step="braille-rendition.fileset" port="result"/>
            </p:variable>
            <p:xslt template-name="main">
                <p:input port="stylesheet">
                    <p:document href="resource-map.xsl"/>
                </p:input>
                <p:input port="source">
                    <p:pipe step="default-rendition.package-document" port="result"/>
                    <p:pipe step="braille-rendition.package-document" port="result"/>
                </p:input>
                <p:with-param name="default-rendition.html.base" select="$default-rendition.html.base"/>
                <p:with-param name="braille-rendition.html.base" select="$braille-rendition.html.base"/>
                <p:with-param name="rendition-mapping.base" select="resolve-uri('EPUB/renditionMapping.html',$target.base)"/>
            </p:xslt>
        </p:group>
        <p:identity name="resource-map"/>
    </p:for-each>
    
    <!--
        rendition mapping document
    -->
    
    <p:insert match="//html:nav" position="last-child">
        <p:input port="source">
            <p:inline xmlns="http://www.w3.org/1999/xhtml">
<html>
   <head>
      <meta charset="utf-8"/>
   </head>
   <body>
      <nav epub:type="resource-map"/>
   </body>
</html></p:inline>
        </p:input>
        <p:input port="insertion" select="/html:nav[@epub:type='resource-map']/*">
            <p:pipe step="braille-rendition.html" port="resource-map"/>
        </p:input>
    </p:insert>
    <p:add-attribute match="/*" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="resolve-uri('EPUB/renditionMapping.html',$target.base)"/>
    </p:add-attribute>
    <p:delete match="/*/@xml:base" name="rendition-mapping"/>
    
    <!--
        braille rendition smil files
    -->
    
    <px:fileset-filter media-types="application/smil+xml" name="braille-rendition.smil.fileset">
        <p:input port="source">
            <p:pipe step="braille-rendition.fileset" port="result"/>
        </p:input>
    </px:fileset-filter>
    <p:label-elements match="d:file" attribute="original-href">
        <p:with-option name="label" select="concat('resolve-uri(@original-href,&quot;',$source.base,'&quot;)')"/>
    </p:label-elements>
    <px:fileset-load>
        <p:input port="in-memory">
            <p:empty/>
        </p:input>
    </px:fileset-load>
    <p:for-each>
        <p:add-xml-base name="_1"/>
        <p:xslt>
            <p:input port="source">
                <p:pipe step="_1" port="result"/>
                <p:pipe step="braille-rendition.fileset" port="result"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="update-cross-references.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:delete match="/*/@xml:base"/>
    </p:for-each>
    <p:identity name="braille-rendition.smil"/>
    
    <!--
        braille rendition package document with new dc:language
    -->
    
    <p:xslt>
        <p:input port="source">
            <p:pipe step="braille-rendition.package-document" port="result"/>
            <p:pipe step="braille-rendition.html" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="braille-rendition.package-document-with-dc-language.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <p:delete match="/*/@xml:base" name="braille-rendition.package-document-with-dc-language"/>
    
    <!--
        container.xml
    -->
    
    <p:insert position="last-child" match="/ocf:container/ocf:rootfiles">
        <p:input port="source">
            <p:pipe step="original-container" port="result"/>
        </p:input>
        <p:input port="insertion">
            <p:inline xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
                <rootfile full-path="EPUB/package-braille.opf" media-type="application/oebps-package+xml"
                          rendition:accessMode="tactile" rendition:label="Pre-translated to braille"/>
            </p:inline>
        </p:input>
    </p:insert>
    <p:add-attribute match="/ocf:container/ocf:rootfiles/ocf:rootfile[last()]" attribute-name="rendition:language">
        <p:with-option name="attribute-value" select="/opf:package/opf:metadata/dc:language[1]/string(.)">
            <p:pipe step="braille-rendition.package-document-with-dc-language" port="result"/>
        </p:with-option>
    </p:add-attribute>
    <p:insert position="last-child" match="/ocf:container">
        <p:input port="insertion">
            <p:inline xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
                <link href="EPUB/renditionMapping.html" rel="mapping" media-type="application/xhtml+xml"/>
            </p:inline>
        </p:input>
    </p:insert>
    <p:add-attribute match="/*" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="resolve-uri('META-INF/container.xml',$target.base)"/>
    </p:add-attribute>
    <p:delete match="/*/@xml:base" name="container"/>
    
    <!-- ===== -->
    <!-- Store -->
    <!-- ===== -->
    
    <px:fileset-join>
        <p:input port="source">
            <p:pipe step="braille-rendition.html.fileset" port="result"/>
            <p:pipe step="braille-rendition.smil.fileset" port="result"/>
            <p:pipe step="source.fileset" port="result"/>
        </p:input>
    </px:fileset-join>
    <px:fileset-add-entry href="META-INF/container.xml"/>
    <px:fileset-add-entry href="META-INF/metadata.xml"/>
    <px:fileset-add-entry href="EPUB/package-braille.opf"/>
    <px:fileset-add-entry href="EPUB/renditionMapping.html"/>
    <p:add-attribute match="d:file[@href='EPUB/renditionMapping.html']" attribute-name="indent" attribute-value="true"/>
    <px:fileset-store>
        <p:input port="in-memory.in">
            <p:pipe step="source.in-memory" port="result"/>
            <p:pipe step="container" port="result"/>
            <p:pipe step="metadata" port="result"/>
            <p:pipe step="braille-rendition.package-document-with-dc-language" port="result"/>
            <p:pipe step="braille-rendition.html" port="result"/>
            <p:pipe step="braille-rendition.smil" port="result"/>
            <p:pipe step="rendition-mapping" port="result"/>
        </p:input>
    </px:fileset-store>
    </p:group>
    
</p:declare-step>
