<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="nimas-fileset-validator" type="px:nimas-fileset-validator"
    xmlns:p="http://www.w3.org/ns/xproc" 
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp" 
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:l="http://xproc.org/library" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-inline-prefixes="#all">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">NIMAS Fileset Validator</h1>
        <p px:role="desc">Performs the following: 
            Validates DTBook + MathML documents, 
            Validates the package document, 
            Enforce metadata requirements,
            Verify that there is a PDF present,
            Verify that all images linked to from the XML content file exist on disk.</p>
    </p:documentation>

    <!-- ***************************************************** -->
    <!-- INPUTS / OUTPUTS / OPTIONS -->
    <!-- ***************************************************** -->
    <p:input port="source" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">source</h1>
            <p px:role="desc">A package document (.opf).</p>
        </p:documentation>
    </p:input>

    <p:output port="result" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">result</h1>
            <p px:role="desc">An HTML-formatted validation report.</p>
        </p:documentation>
        <p:pipe port="result" step="validate-against-relaxng"/>
    </p:output>

    <p:output port="dtbook-relaxng-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">dtbook-relaxng-report</h1>
            <p px:role="desc">Raw output from the RelaxNG validation of the DTBook file(s).</p>
        </p:documentation>
        <p:pipe step="validate-dtbook" port="relaxng-report"/>
    </p:output>

    <p:output port="dtbook-schematron-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">schematron-report</h1>
            <p px:role="desc">Raw output from the schematron validation of the DTBook file(s).</p>
        </p:documentation>
        <p:pipe step="validate-dtbook" port="schematron-report"/>
    </p:output>
    
    <p:output port="opf-relaxng-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">opf-relaxng-report</h1>
            <p px:role="desc">Raw output from the RelaxNG validation of the package document.</p>
        </p:documentation>
        <p:pipe step="validate-opf" port="relaxng-report"/>
    </p:output>
    
    <p:output port="opf-schematron-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">opf-schematron-report</h1>
            <p px:role="desc">Raw output from the RelaxNG validation of the package document.</p>
        </p:documentation>
        <p:pipe step="validate-opf" port="schematron-report"/>
    </p:output>
    
    <p:option name="output-dir" required="false" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Directory where your validation reports are stored. If left blank,
                nothing is saved to disk.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="mathml-version" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">mathml-version</h2>
            <p px:role="desc">Version of MathML in the DTBook file. Defaults to 3.0.</p>
        </p:documentation>
    </p:option>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>Calabash extension steps.</p:documentation>
    </p:import>

    <p:import
        href="http://www.daisy.org/pipeline/modules/validation-utils/validation-utils-library.xpl">
        <p:documentation>Collection of utilities for validation and reporting. </p:documentation>
    </p:import>
    
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-validator/dtbook-validator.xpl">
        <p:documentation>DTBook + MathML validator</p:documentation>
    </p:import>
    
    <p:import href="nimas-fileset-validator.validate-opf.xml">
        <p:documentation>OPF validation step.</p:documentation>
    </p:import>
    
    <p:import href="nimas-fileset-validator.store-opf.xml">
        <p:documentation>Stores reports to disk.</p:documentation>
    </p:import>
    
    <p:variable name="base-uri" select="base-uri()">
        <p:pipe port="source" step="dtbook-validator"/>
    </p:variable>
    
    <!-- ***************************************************** -->
    <!-- VALIDATION STEPS -->
    <!-- ***************************************************** -->
    
    <px:nimas-fileset-validator.validate-opf name="validate-opf">
        <p:input port="source">
            <p:pipe port="source" step="nimas-fileset-validator"/>
        </p:input>
    </px:nimas-fileset-validator.validate-opf>
    <p:sink/>
    
    <!-- find all DTBook documents referenced by the package file -->
    <p:for-each>
        <px:validate-dtbook>
            
        </px:validate-dtbook>    
    </p:for-each>
    
    <!-- Check that a PDF file exists -->
    
    
</p:declare-step>
