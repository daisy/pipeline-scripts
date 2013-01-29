<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-validator" type="px:dtbook-validator"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:l="http://xproc.org/library" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:m="http://www.w3.org/1998/Math/MathML" exclude-inline-prefixes="#all">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DTBook Validator</h1>
        <p px:role="desc">Validates DTBook documents (2005-3, 2005-2). Supports inclusion of MathML
            2 and 3.</p>
    </p:documentation>

    <!-- ***************************************************** -->
    <!-- INPUTS / OUTPUTS / OPTIONS -->
    <!-- ***************************************************** -->
    <p:input port="source" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">source</h1>
            <p px:role="desc">A DTBook-2005-3 document</p>
        </p:documentation>
    </p:input>

    <p:output port="result" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">result</h1>
            <p px:role="desc">A copy of the input document; may include PSVI annotations.</p>
        </p:documentation>
        <p:pipe port="result" step="validate-against-relaxng"/>
     </p:output>

    <p:output port="relaxng-report" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">relaxng-report</h1>
            <p px:role="desc">Raw output from the RelaxNG validation.</p>
        </p:documentation>
        <p:pipe port="result" step="get-relaxng-report"/>
    </p:output>

    <p:output port="schematron-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">schematron-report</h1>
            <p px:role="desc">Raw output from the schematron validation.</p>
        </p:documentation>
        <p:pipe step="validate-against-schematron" port="report"/>
    </p:output>

    <p:output port="html-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">html-report</h1>
            <p px:role="desc">An HTML-formatted version of both the RelaxNG and Schematron
                reports.</p>
        </p:documentation>
        <p:pipe port="result" step="create-html-report"/>
    </p:output>

    <p:option name="output-dir" required="false" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Directory where your validation report is stored. If left blank,
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
        <p:documentation> Collection of utilities for validation and reporting. </p:documentation>
    </p:import>

    <p:import href="dtbook-validator.select-schema.xpl">
        <p:documentation>Helper step: select schema for given document type.</p:documentation>
    </p:import>
    
    <p:import href="dtbook-validator.store.xpl">
        <p:documentation>Helper step: store validation reports.</p:documentation>
    </p:import>

    <p:variable name="base-uri" select="base-uri()">
        <p:pipe port="source" step="dtbook-validator"/>
    </p:variable>

    <p:variable name="dtbook-version" select="dtb:dtbook/@version">
        <p:pipe port="source" step="dtbook-validator"/>
    </p:variable>
    
    <p:variable name="opt-mathml-version"
        select="if (string-length($mathml-version) > 0) 
        then $mathml-version
        else '3.0'"/>

    <p:variable name="document-type" select="if (count(//m:math) > 0) 
        then concat('DTBook ', $dtbook-version, ' with MathML ', $opt-mathml-version) 
        else concat('DTBook ', $dtbook-version)">
        <p:pipe port="source" step="dtbook-validator"/>
    </p:variable>

    <p:variable name="filename" select="tokenize($base-uri, '/')[count(tokenize($base-uri, '/'))]"/>
    
    <!-- ***************************************************** -->
    <!-- VALIDATION STEPS -->
    <!-- ***************************************************** -->
    
    <!-- fetch the appropriate RNG schema -->
    <px:dtbook-validator.select-schema name="select-rng-schema">
        <p:with-option name="dtbook-version" select="$dtbook-version"/>
        <p:with-option name="mathml-version" select="$opt-mathml-version"/>
    </px:dtbook-validator.select-schema>
    <p:sink/>
    
    <!-- validate with RNG -->
    <l:relax-ng-report name="validate-against-relaxng" assert-valid="false">
        <p:input port="schema">
            <p:pipe port="result" step="select-rng-schema"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="source" step="dtbook-validator"/>
        </p:input>
    </l:relax-ng-report>
    
    <!-- see if there was a report generated -->
    <p:count name="count-relaxng-report" limit="1">
        <p:documentation>RelaxNG validation doesn't always produce a report, so this serves as a
            test to see if there was a document produced.</p:documentation>
        <p:input port="source">
            <p:pipe port="report" step="validate-against-relaxng"/>
        </p:input>
    </p:count>
    
    <!-- if there were no errors, relaxng validation comes up empty. we need to have something to pass around, hence this step -->
    <p:choose name="get-relaxng-report">
        <p:xpath-context>
            <p:pipe port="result" step="count-relaxng-report"/>
        </p:xpath-context>
        <!-- if there was no relaxng report, then put an empty errors list document as output -->
        <p:when test="/c:result = '0'">
            <p:output port="result">
                <p:inline>
                    <c:errors/>
                </p:inline>
            </p:output>
            <p:identity/>
            <p:sink/>
        </p:when>
        <p:otherwise>
            <p:output port="result">
                <p:pipe port="report" step="validate-against-relaxng"/>
            </p:output>
            <p:identity/>
            <p:sink/>
        </p:otherwise>
    </p:choose>
    <p:sink/>
    
    <!-- validate with schematron -->
    <p:validate-with-schematron assert-valid="false" name="validate-against-schematron">
        <p:input port="schema">
            <p:document href="./schema/sch/dtbook.mathml.sch"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="source" step="dtbook-validator"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:validate-with-schematron>
    <p:sink/>
    
    <!-- ***************************************************** -->
    <!-- REPORT(S) TO HTML -->
    <!-- ***************************************************** -->
    <px:create-validation-report-wrapper>
        <p:with-option name="document-type" select="$document-type"/>
        <p:with-option name="document-name" select="$filename"/>
        <p:with-option name="document-path" select="$base-uri"/>
        <p:input port="source">
            <!-- a sequence of reports -->
            <!--<p:pipe port="report" step="validate-against-relaxng"/>-->
            <p:pipe port="report" step="validate-against-schematron"/>
        </p:input>
    </px:create-validation-report-wrapper>
    <px:validation-report-to-html name="create-html-report"/>
    <p:sink/>

    <!-- ***************************************************** -->
    <!-- STORE REPORTS -->
    <!-- ***************************************************** -->
    <!--<p:choose>
        <!-\- save reports if we specified an output dir -\->
        <p:when test="not(empty($output-dir))">
            <p:xpath-context>
                <p:pipe port="result" step="count-relaxng-report"/>
            </p:xpath-context>
            
            <px:dtbook-validator-store name="store-reports">
                <p:with-option name="output-dir" select="$output-dir"/>
                <p:input port="source">
                    <p:pipe step="create-html-report" port="result"/>
                </p:input>
                <p:input port="relax-ng-report">
                    <p:pipe step="get-relaxng-report" port="result"/>
                </p:input>
                <p:input port="schematron-report">
                    <p:pipe step="validate-against-schematron" port="report"/>
                </p:input>
            </px:dtbook-validator-store>
        </p:when>
    </p:choose>-->
</p:declare-step>
