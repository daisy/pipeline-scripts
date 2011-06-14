<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
    type="px:contents" name="contents" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Load the DAISY 2.02 text content documents and store them as EPUB 3 Content
            Documents.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:input port="spine">List of DAISY 2.02 text content documents in playback
            order.</xd:input>
        <xd:input port="id-mapping">Map of id-attributes and fragment identifiers from the original
            and resulting filesets.</xd:input>
        <xd:output port="manifest">List of stored files.</xd:output>
        <xd:output port="store-complete">Pipe connection for 'p:store'-dependencies.</xd:output>
        <xd:output port="resource-manifest">Auxiliary resources referenced from the resulting
            Content Documents.</xd:output>
        <xd:output port="metadata">Metadata from the Content Documents.</xd:output>
        <xd:option name="daisy-dir">URI to the directory containing the NCC.</xd:option>
        <xd:option name="content-dir">URI to the directory where all the EPUB 3 content should be
            stored.</xd:option>
        <xd:option name="epub-dir">URI to the directory where the OCF is being created.</xd:option>
        <xd:import href="../utilities/file-utils/fileset-library.xpl">For manipulating
            filesets.</xd:import>
        <xd:import href="../utilities/html-utils/html-library.xpl">For loading HTML.</xd:import>
    </p:documentation>

    <p:input port="spine" primary="false"/>
    <p:input port="id-mapping" primary="false"/>
    <p:output port="manifest" primary="false">
        <p:pipe port="result" step="manifest"/>
    </p:output>
    <p:output port="store-complete" primary="false" sequence="true">
        <p:pipe port="store" step="iterate"/>
    </p:output>
    <p:output port="resource-manifest" primary="false">
        <p:pipe port="result" step="resources"/>
    </p:output>
    <p:output port="metadata" primary="false">
        <p:pipe port="result" step="metadata"/>
    </p:output>

    <p:option name="daisy-dir" required="true"/>
    <p:option name="content-dir" required="true"/>
    <p:option name="epub-dir" required="true"/>

    <p:import href="../utilities/file-utils/fileset-library.xpl"/>
    <p:import href="../utilities/html-utils/html-library.xpl"/>

    <p:documentation>
        <xd:short>Iterating through each text content document in the DAISY 2.02 fileset, converting
            to EPUB 3 Content Documents, extracting auxiliary resources and metadata, and storing
            the resulting files.</xd:short>
        <xd:output port="manifest">Sequence of manifests representing each stored Content
            Document.</xd:output>
        <xd:output port="store">Sequence of results from storing the Content Documents, allowing
            other steps to depend on the files being stored.</xd:output>
        <xd:output port="resources">Sequence of manifests derived from each Content Document
            containing references to all the auxiliary resources.</xd:output>
        <xd:output port="metadata">Sequence of metadata sets intended for "global" consuption,
            derived from each Content Document.</xd:output>
    </p:documentation>
    <p:for-each name="iterate">
        <p:output port="manifest">
            <p:pipe port="result" step="iterate.manifest"/>
        </p:output>
        <p:output port="store" primary="false">
            <p:pipe port="result" step="iterate.store"/>
        </p:output>
        <p:output port="resources" primary="false">
            <p:pipe port="result" step="iterate.resources"/>
        </p:output>
        <p:output port="metadata" primary="false">
            <p:pipe port="result" step="iterate.metadata"/>
        </p:output>

        <p:iteration-source select="//c:entry">
            <p:pipe port="spine" step="contents"/>
        </p:iteration-source>
        <p:variable name="href" select="/*/@href"/>
        <p:variable name="new-href" select="replace($href,'\.([^\.]+)$','.xhtml')"/>

        <px:html-load>
            <p:with-option name="href" select="concat($daisy-dir,$href)"/>
        </px:html-load>
        <p:viewport match="//html:a">
            <p:documentation xd:exclude="true">De-references SMIL-hrefs into their equivalent
                XHTML-hrefs; see navigation.xpl-documentation for details.</p:documentation>
            <p:variable name="smil-href" select="tokenize(/*/@href,'#')[1]"/>
            <p:variable name="smil-id"
                select="if (contains(/*/@href,'#')) then tokenize(/*/@href,'#')[last()] else ''"/>
            <p:add-attribute match="/*" attribute-name="href">
                <p:with-option name="attribute-value"
                    select="concat(
                            //c:entry[@smil-href=$smil-href]/@content-href,
                            if ($smil-id)
                            then concat('#', //c:entry[@smil-href=$smil-href[1]]/c:id[@smil-id=$smil-id]/@content-id )
                            else ''
                            )">
                    <p:pipe port="id-mapping" step="contents"/>
                </p:with-option>
            </p:add-attribute>
        </p:viewport>
        <p:xslt name="iterate.xhtml">
            <p:with-param name="href" select="$new-href"/>
            <p:input port="stylesheet">
                <p:document href="xhtml2content.xsl"/>
            </p:input>
        </p:xslt>
        <p:delete match="/*/@xml:base"/>
        <!--p:validate-with-schematron>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="schema">
                <p:document href="../schemas/epub30/epub-xhtml-30.sch"/>
            </p:input>
        </p:validate-with-schematron-->
        <p:store name="iterate.store">
            <p:with-option name="href" select="p:resolve-uri(concat($content-dir,$new-href))"/>
        </p:store>
        <p:add-attribute name="iterate.content" attribute-name="xml:base" match="/*">
            <p:input port="source">
                <p:pipe port="result" step="iterate.xhtml"/>
            </p:input>
            <p:with-option name="attribute-value" select=".">
                <p:pipe port="result" step="iterate.store"/>
            </p:with-option>
        </p:add-attribute>
        <p:sink/>

        <p:xslt name="iterate.resources">
            <p:with-param name="base" select="$epub-dir"/>
            <p:input port="source">
                <p:pipe port="result" step="iterate.content"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="content2resources.xsl"/>
            </p:input>
        </p:xslt>
        <p:sink/>

        <p:xslt name="iterate.metadata">
            <p:input port="source">
                <p:pipe port="result" step="iterate.content"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="content2metadata.xsl"/>
            </p:input>
        </p:xslt>
        <p:sink/>

        <px:create-manifest>
            <p:with-option name="base" select="$epub-dir"/>
        </px:create-manifest>
        <px:add-manifest-entry name="iterate.manifest">
            <p:with-option name="href"
                select="concat(substring-after($content-dir,$epub-dir),$new-href)"/>
            <p:with-option name="media-type" select="'application/xhtml+xml'"/>
        </px:add-manifest-entry>
        <p:sink/>
    </p:for-each>

    <p:documentation>Make one single manifest containing references to all the stored Content
        Documents.</p:documentation>
    <px:join-manifests name="manifest">
        <p:input port="source">
            <p:pipe port="manifest" step="iterate"/>
        </p:input>
    </px:join-manifests>
    <p:sink/>

    <p:documentation>Make one single manifest containing references to all the auxiliary
        resources.</p:documentation>
    <px:join-manifests name="resources">
        <p:input port="source">
            <p:pipe port="resources" step="iterate"/>
        </p:input>
    </px:join-manifests>
    <p:sink/>

    <p:documentation>Make one single set of metadata extracted from all the Content
        Documents.</p:documentation>
    <p:wrap-sequence wrapper="c:metadata">
        <p:input port="source">
            <p:pipe port="metadata" step="iterate"/>
        </p:input>
    </p:wrap-sequence>
    <p:unwrap name="metadata" match="c:metadata[parent::c:metadata]"/>
    <p:sink/>

</p:declare-step>
