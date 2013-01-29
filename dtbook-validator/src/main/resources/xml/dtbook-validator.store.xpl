<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-validator.store" type="px:dtbook-validator-store"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp" 
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:l="http://xproc.org/library" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:m="http://www.w3.org/1998/Math/MathML" exclude-inline-prefixes="#all">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Helper step for DTBook Validator</h1>
        <p px:role="desc">Store the reports from the DTBook validator.</p>
    </p:documentation>
    
    <!-- the html report -->
    <p:input port="source" primary="true"/>
    
    <p:input port="relax-ng-report"/>
    <p:input port="schematron-report"/>
    <p:option name="output-dir" required="true"/>
    
    <p:store name="store-relaxng">
        <p:input port="source">
            <p:pipe port="relax-ng-report" step="dtbook-validator.store"/>
        </p:input>
        <p:with-option name="href"
            select="concat($output-dir,'/relax-ng-report.xml')"/>
    </p:store>
    
    <p:store name="store-schematron">
        <p:input port="source">
            <p:pipe port="schematron-report" step="dtbook-validator.store"/>
        </p:input>
        <p:with-option name="href"
            select="concat($output-dir,'/schematron-report.xml')"/>
    </p:store>
    
    <p:store name="store-xhtml">
        <p:input port="source">
            <p:pipe port="source" step="dtbook-validator.store"/>
        </p:input>
        <p:with-option name="href"
            select="concat($output-dir,'/report.xhtml')"/>
    </p:store>
    
</p:declare-step>
