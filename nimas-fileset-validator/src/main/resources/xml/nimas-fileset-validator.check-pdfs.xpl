<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="nimas-fileset-validator.check-pdfs" type="pxi:nimas-fileset-validator.check-pdfs"
    xmlns:p="http://www.w3.org/ns/xproc" 
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"    
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:m="http://www.w3.org/1998/Math/MathML" 
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:pkg="http://openebook.org/namespaces/oeb-package/1.0/"
    exclude-inline-prefixes="#all">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Helper step for Nimas Fileset Validator</h1>
        <p px:role="desc">Checks to see if the PDFs referenced from the package document exists on disk.</p>
    </p:documentation>
    
    <!-- ***************************************************** -->
    <!-- INPUT, OUTPUT and OPTIONS -->
    <!-- ***************************************************** -->
    
    <p:input port="source" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">source</h1>
            <p px:role="desc">A package document</p>
        </p:documentation>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">result</h1>
            <p px:role="desc">Report of missing PDFs, or an empty sequence if nothing is missing.</p>
        </p:documentation>
    </p:output>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>Calabash extension steps.</p:documentation>
    </p:import>
    
    <p:import
        href="http://www.daisy.org/pipeline/modules/validation-utils/validation-utils-library.xpl">
        <p:documentation>Collection of utilities for validation and reporting. </p:documentation>
    </p:import>
    
    <p:variable name="package-doc-uri" select="base-uri()"/>
    
    <cx:message message="Nimas fileset validator: Checking that PDFs exist on disk."/>
    
    <p:for-each>
        <p:iteration-source select="//pkg:item[@media-type = 'application/pdf']"/>
        <p:variable name="refid" select="*/@id"/>
        <p:variable name="pdfpath" select="*/resolve-uri(@href, $package-doc-uri)"/>
        <p:add-attribute match="d:file">
            <p:input port="source">
                <p:inline>
                    <d:file/>
                </p:inline>
            </p:input>
            <p:with-option name="attribute-name" select="'path'"/>
            <p:with-option name="attribute-value" select="$pdfpath"/>
        </p:add-attribute>
        <p:add-attribute match="d:file">
            <p:with-option name="attribute-name" select="'ref'"/>
            <p:with-option name="attribute-value" select="concat($package-doc-uri, '#', $refid)"/>
        </p:add-attribute>
        
    </p:for-each>
            
    <p:wrap-sequence wrapper="files" wrapper-prefix="d" wrapper-namespace="http://www.daisy.org/ns/pipeline/data"/>
            
    <px:check-files-exist name="check-pdfs-exist"/>     
</p:declare-step>
