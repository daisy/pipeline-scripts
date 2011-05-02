<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:px="http://pipeline.daisy.org/ns/"
    xmlns:pxp="http://exproc.org/proposed/steps" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:opf="http://www.idpf.org/2007/opf" xmlns:xd="http://pipeline.daisy.org/ns/sample/doc"
    type="d2e:navigation" name="navigation" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Transform the DAISY 2.02 NCC into a EPUB 3 Navigation Document.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:input port="ncc">The NCC as wellformed XHTML.</xd:input>
        <xd:input port="id-mapping">The mapping of id-attributes and fragment identifiers of the
            resulting documents to the original documents.</xd:input>
        <xd:output port="store-complete">Pipe connection for 'p:store'-dependencies.</xd:output>
        <xd:option name="content-dir">URI to the directory where all the EPUB 3 content should be
            stored.</xd:option>
        <xd:import href="../utilities/files/fileset-library.xpl">For manipulating
            filesets.</xd:import>
    </p:documentation>

    <p:input port="ncc" primary="true"/>
    <p:input port="id-mapping" primary="false"/>
    <p:output port="store-complete" primary="false">
        <p:pipe port="result" step="navigation.store"/>
    </p:output>

    <p:option name="content-dir" required="true"/>

    <p:import href="../utilities/files/fileset-library.xpl"/>

    <p:documentation>
        <xd:short>Resolve SMIL-hrefs to XHTML-hrefs.</xd:short>
        <xd:detail>
            <p>In DAISY 2.02, the NCC and text content documents refers to SMIL-files in their &lt;a
                href="smil-file.smil#smil-fragment"/&gt;-links, and those SMIL-files in turn refer
                to a text content document in their &lt;a
                href="text-file.xhtml#text-fragment"/&gt;-links. This is redundant information, so
                in EPUB 3, the Media Overlays refers to Content Documents (including the Navigation
                Document), but not the other way around. In EPUB 3 there is at most one Media
                Overlay for each Content Document and exactly one Content Document for each Media
                Overlay. The Media Overlay corresponding to a certain text element can be determined
                by looking it up in the Package Document in EPUB 3.</p>
            <p>This means that to transform a DAISY 2.02 text content document (including the NCC)
                into an EPUB 3 Content Document, we'll have to strip away all the unnecessary links.
                So we identify all the links that refers to themselves indirectly through a
                SMIL-file, and remove those links. However, the remaining links are kept, which can
                point to either another text element in the book, or an external URI.</p>
        </xd:detail>
    </p:documentation>
    <p:viewport match="//html:a">
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
                <p:pipe port="id-mapping" step="navigation"/>
            </p:with-option>
        </p:add-attribute>
    </p:viewport>
    
    <p:documentation>Transform the NCC into a Navigation Document.</p:documentation>
    <p:xslt name="navigation.xhtml">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc2navigation.xsl"/>
        </p:input>
    </p:xslt>
    <p:validate-with-schematron>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="schema">
            <p:document href="../schemas/epub30/epub-nav-30.sch"/>
        </p:input>
    </p:validate-with-schematron>
    <p:store name="navigation.store">
        <p:with-option name="href" select="concat($content-dir,'navigation.xhtml')"/>
    </p:store>

</p:declare-step>
