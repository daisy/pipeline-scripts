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
    xmlns:pkg="http://openebook.org/namespaces/oeb-package/1.0/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-inline-prefixes="#all">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">NIMAS Fileset Validator</h1>
        <p px:role="desc">Performs the following: 
            Validates DTBook + MathML documents, 
            Validates the package document, 
            Enforces metadata requirements,
            Verifies that there is a PDF present,
            Verifies that all images linked to from the XML content file exist on disk.</p>
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
        <!-- TODO: change to HTML format step -->
        <p:pipe step="validate-package-doc" port="result"/>
    </p:output>
    
    <p:output port="package-doc-validation-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">package-relaxng-report</h1>
            <p px:role="desc">Raw validation output for the package document.</p>
        </p:documentation>
        <p:pipe step="validate-package-doc" port="report"/>
    </p:output>
    
    <!--<p:output port="dtbook-validation-report" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">dtbook-relaxng-report</h1>
            <p px:role="desc">Raw validation output for the DTBook file(s).</p>
        </p:documentation>
        <!-\- TODO change to wrapped report for dtbook(s) -\->
        <p:pipe step="validate-all-dtbooks" port="relaxng-report"/>
    </p:output>
    -->
    <p:option name="output-dir" required="false" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Directory where your validation reports are stored. If left blank,
                nothing is saved to disk.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="mathml-version" required="false" px:type="string" select="'3.0'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">mathml-version</h2>
            <p px:role="desc">Version of MathML in the DTBook file(s). Defaults to 3.0.</p>
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
    
    <p:import href="nimas-fileset-validator.validate-package-doc.xpl">
        <p:documentation>Package doc validation step.</p:documentation>
    </p:import>
    
    <!--<p:import href="nimas-fileset-validator.store.xpl">
        <p:documentation>Stores reports to disk.</p:documentation>
    </p:import>
    -->
    
    <!-- ***************************************************** -->
    <!-- VALIDATION STEPS -->
    <!-- ***************************************************** -->
    <px:nimas-fileset-validator.validate-package-doc name="validate-package-doc">
        <p:input port="source">
            <p:pipe port="source" step="nimas-fileset-validator"/>
        </p:input>
        <!-- TODO set the math option intelligently based on whether any of the DTBook files contain math -->
        <p:with-option name="math" select="'false'"/>
    </px:nimas-fileset-validator.validate-package-doc>
    
    <!--<p:for-each>
        <p:iteration-source select="//pkg:item[@media-type = 'application/x-dtbook+xml']">
            <p:pipe port="source" step="nimas-fileset-validator"/>
        </p:iteration-source>
        
        <p:variable name="dtbook-uri" select="resolve-uri(@href, $base-uri)"/>
        
        <p:load name="load-dtbook">
            <p:with-option name="href" select="$dtbook-uri"/>
        </p:load>
        
        <px:dtbook-validator name="validate-dtbook">
            <p:input port="source">
                <p:pipe port="result" step="load-dtbook"/>
            </p:input>
            <p:with-option name="check-images" select="'true'"/>
            <p:with-option name="mathml-version" select="$mathml-version"/>
            <p:with-option name="output-dir" select="'file:/Users/marisa/Desktop/dpout/'"/>
        </px:dtbook-validator>
        
    </p:for-each>
    
    -->  
    <p:sink/>
</p:declare-step>
