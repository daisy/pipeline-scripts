<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d2e="http://pipeline.daisy.org/ns/daisy2epub/"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:px="http://pipeline.daisy.org/ns/"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:opf="http://www.idpf.org/2007/opf"
    type="d2e:navigation" name="navigation" version="1.0">

    <p:input port="source" primary="true"/>
    <p:input port="id-mapping" primary="false"/>
    <p:output port="store-complete" primary="false">
        <p:pipe port="result" step="navigation.store"/>
    </p:output>

    <p:option name="content-dir" required="true"/>

    <p:import href="fileset-library.xpl"/>

    <p:documentation><![CDATA[
            input: from result@ncc
            primary output: "manifest"
            output: "store-complete"
            output: "resource-manifest"
            output: "metadata"
    ]]></p:documentation>
    
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
    <p:xslt name="navigation.xhtml">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc2navigation.xsl"/>
        </p:input>
    </p:xslt>
    <p:store name="navigation.store">
        <p:with-option name="href" select="concat($content-dir,'navigation.xhtml')"/>
    </p:store>

</p:declare-step>
