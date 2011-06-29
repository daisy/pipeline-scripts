<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils" xmlns:mo="http://www.w3.org/ns/SMIL"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:pxp="http://exproc.org/proposed/steps"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:opf="http://www.idpf.org/2007/opf"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" type="px:navigation" name="navigation"
    version="1.0">

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
    </p:documentation>

    <p:input port="ncc" primary="true"/>
    <p:input port="daisy-smil" primary="false" sequence="true"/>
    <p:output port="navigation" primary="false">
        <p:pipe port="result" step="result-with-xml-base"/>
    </p:output>
    <p:output port="store-complete" primary="false">
        <p:pipe port="result" step="store"/>
    </p:output>

    <p:option name="content-dir" required="true"/>
    <p:option name="subcontent-dir" required="true"/>
    
    <p:import href="resolve-links.xpl"/>
    
    <p:variable name="subdir" select="substring-after($subcontent-dir,$content-dir)"/>

    <p:documentation>Transform the NCC into a Navigation Document.</p:documentation>

    <pxi:daisy202-to-epub3-resolve-links>
        <p:input port="daisy-smil">
            <p:pipe port="daisy-smil" step="navigation"/>
        </p:input>
    </pxi:daisy202-to-epub3-resolve-links>
    <p:viewport match="html:a[@href and not(matches(@href,'^[^/]+:'))]">
        <p:add-attribute match="/*" attribute-name="href">
            <p:with-option name="attribute-value"
                select="concat($subdir,replace(tokenize(/*/@href,'#')[1],'^(.*)\.html$','$1.xhtml#'),if (contains(/*/@href,'#')) then tokenize(/*/@href,'#')[last()] else '')"
            />
        </p:add-attribute>
    </p:viewport>

    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc2navigation.xsl"/>
        </p:input>
    </p:xslt>
    <p:delete match="html:ol[not(*)]"/>
    <p:identity name="result"/>

    <p:store name="store" indent="true">
        <p:with-option name="href" select="concat($content-dir,'navigation.xhtml')"/>
    </p:store>
    <p:add-attribute match="/*" attribute-name="xml:base">
        <p:with-option name="attribute-value" select=".">
            <p:pipe port="result" step="store"/>
        </p:with-option>
        <p:input port="source">
            <p:pipe port="result" step="result"/>
        </p:input>
    </p:add-attribute>
    <p:identity name="result-with-xml-base"/>

</p:declare-step>
