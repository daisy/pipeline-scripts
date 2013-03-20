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
        <p px:role="desc">Validates DTBook documents. Supports inclusion of MathML.</p>
        <a px:role="homepage" href="http://code.google.com/p/daisy-pipeline/wiki/DTBookValidator">
            http://code.google.com/p/daisy-pipeline/wiki/DTBookValidator
        </a>
        <div px:role="author maintainer">
            <p px:role="name">Marisa DeMeglio</p>
            <a px:role="contact" href="mailto:marisa.demeglio@gmail.com">marisa.demeglio@gmail.com</a>
            <p px:role="organization">DAISY Consortium</p>
        </div>
    </p:documentation>

    <!-- ***************************************************** -->
    <!-- INPUTS / OUTPUTS / OPTIONS -->
    <!-- ***************************************************** -->
    <p:input port="source" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">source</h1>
            <p px:role="desc">A DTBook document. Supported versions are 2005-1,-2,-3; and 1.1.0.</p>            
        </p:documentation>
    </p:input>

    <p:output port="result" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">result</h1>
            <p px:role="desc">A copy of the input document; may include PSVI annotations.</p>
        </p:documentation>
        <p:pipe port="copy-of-document" step="validate-against-relaxng"/>
     </p:output>

    <p:output port="report" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">report</h1>
            <p px:role="desc">Raw output from all types of validation used (RelaxNG, Schematron, custom).</p>
        </p:documentation>
        <p:pipe port="result" step="wrap-reports"/>
    </p:output>

    <p:output port="html-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">html-report</h1>
            <p px:role="desc">An HTML-formatted version of the validation report.</p>
        </p:documentation>
        <p:pipe port="result" step="create-html-report"/>
    </p:output>
    
    <p:option name="output-dir" required="false" px:output="result" px:type="anyDirURI" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Directory where your validation report is stored. If left blank,
                nothing is saved to disk.</p>
        </p:documentation>
    </p:option>

    <p:option name="mathml-version" required="false" px:type="string" select="'3.0'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">mathml-version</h2>
            <p px:role="desc">Version of MathML in the DTBook file.</p>
        </p:documentation>
    </p:option>

    <p:option name="check-images" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">check-images</h2>
            <p px:role="desc">Check to see that referenced images exist on disk.</p>
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
    
    <p:import href="dtbook-validator.check-images.xpl">
        <p:documentation>Helper step: check that referenced images exist on disk.</p:documentation>
    </p:import>
    
    
    <p:variable name="base-uri" select="base-uri()">
        <p:pipe port="source" step="dtbook-validator"/>
    </p:variable>

    <p:variable name="dtbook-version" select="dtb:dtbook/@version">
        <p:pipe port="source" step="dtbook-validator"/>
    </p:variable>
    
    <p:variable name="document-type" select="if (count(//m:math) > 0) 
        then concat('DTBook ', $dtbook-version, ' with MathML ', $mathml-version) 
        else concat('DTBook ', $dtbook-version)">
        <p:pipe port="source" step="dtbook-validator"/>
    </p:variable>

    <p:variable name="filename" select="tokenize($base-uri, '/')[last()]"/>
    
    <!-- ***************************************************** -->
    <!-- VALIDATION STEPS -->
    <!-- ***************************************************** -->
    
    <!-- fetch the appropriate RNG schema -->
    <px:dtbook-validator.select-schema name="select-rng-schema">
        <p:with-option name="dtbook-version" select="$dtbook-version"/>
        <p:with-option name="mathml-version" select="$mathml-version"/>
    </px:dtbook-validator.select-schema>
    <p:sink/>
    
    <p:group name="validate-against-relaxng">
        <p:output port="result" primary="true"/>
        <p:output port="copy-of-document">
            <p:pipe port="result" step="run-relaxng-validation"/>
        </p:output>
        <!-- validate with RNG -->
        <l:relax-ng-report name="run-relaxng-validation" assert-valid="false">
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
                <p:pipe port="report" step="run-relaxng-validation"/>
            </p:input>
        </p:count>
        
        <!-- if there were no errors, relaxng validation comes up empty. we need to have something to pass around, hence this step -->
        <p:choose name="get-relaxng-report">
            <p:xpath-context>
                <p:pipe port="result" step="count-relaxng-report"/>
            </p:xpath-context>
            <!-- if there was no relaxng report, then put an empty errors list document as output -->
            <p:when test="/c:result = '0'">
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <c:errors/>
                        </p:inline>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="report" step="run-relaxng-validation"/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
    </p:group>
    
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
    
    <!-- check images -->
    <p:choose name="check-images-exist">
        <p:when test="$check-images = 'true'">
            <p:output port="result"/>
            <px:dtbook-validator.check-images>
                <p:input port="source">
                    <p:pipe port="source" step="dtbook-validator"/>
                </p:input>
            </px:dtbook-validator.check-images>
        </p:when>
        <p:otherwise>
            <p:output port="result"/>
            <p:identity>
                <p:input port="source">
                    <!-- generate an empty document -->
                    <p:inline>
                        <d:errors/>
                    </p:inline>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    <p:sink/>
    
    <!-- ***************************************************** -->
    <!-- REPORT(S) TO HTML -->
    <!-- ***************************************************** -->
    <px:combine-validation-reports name="wrap-reports">
        <p:with-option name="document-type" select="$document-type"/>
        <p:with-option name="document-name" select="$filename"/>
        <p:with-option name="document-path" select="$base-uri"/>
        <p:input port="source">
            <!-- a sequence of reports -->
            <p:pipe port="result" step="validate-against-relaxng"/>
            <p:pipe port="report" step="validate-against-schematron"/>
            <p:pipe port="result" step="check-images-exist"/>
        </p:input>
    </px:combine-validation-reports>
    <px:validation-report-to-html name="create-html-report"/>
    <p:sink/>

    <!-- ***************************************************** -->
    <!-- STORE REPORTS -->
    <!-- ***************************************************** -->
    <p:choose>
        <!-- save reports if we specified an output dir -->
        <p:when test="string-length($output-dir) > 0">
            <p:store name="store-xml-report">
                <p:input port="source">
                    <p:pipe port="result" step="wrap-reports"/>
                </p:input>
                <p:with-option name="href"
                    select="concat($output-dir,'/dtbook-validation-report.xml')"/>
            </p:store>
            
            <p:store name="store-xhtml-report">
                <p:input port="source">
                    <p:pipe port="result" step="create-html-report"/>
                </p:input>
                <p:with-option name="href"
                    select="concat($output-dir,'/dtbook-validation-report.xhtml')"/>
            </p:store>
        </p:when>
        <p:otherwise>
            <p:sink>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:sink>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
