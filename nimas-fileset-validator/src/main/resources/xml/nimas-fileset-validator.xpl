<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="nimas-fileset-validator" type="px:nimas-fileset-validator"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:l="http://xproc.org/library" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:pkg="http://openebook.org/namespaces/oeb-package/1.0/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    exclude-inline-prefixes="#all">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">NIMAS Fileset Validator</h1>
        <p px:role="desc">Validate a NIMAS Fileset. Supports inclusion of MathML.</p>
        <a px:role="homepage"
            href="http://code.google.com/p/daisy-pipeline/wiki/NimasFilesetValidator">
            http://code.google.com/p/daisy-pipeline/wiki/NimasFilesetValidator </a>
        <div px:role="author maintainer">
            <p px:role="name">Marisa DeMeglio</p>
            <a px:role="contact" href="mailto:marisa.demeglio@gmail.com"
                >marisa.demeglio@gmail.com</a>
            <p px:role="organization">DAISY Consortium</p>
        </div>
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
            <p px:role="desc">An HTML-formatted validation report comprising all documents'
                reports.</p>
        </p:documentation>
        <p:pipe step="format-as-html" port="result"/>
    </p:output>

    <p:output port="package-doc-validation-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">package-doc-validation-report</h1>
            <p px:role="desc">Raw validation output for the package document.</p>
        </p:documentation>
        <p:pipe step="validate-package-doc" port="result"/>
    </p:output>

    <p:output port="dtbook-validation-report" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">dtbook-validation-report</h1>
            <p px:role="desc">Raw validation output for the DTBook file(s).</p>
        </p:documentation>
        <p:pipe step="validate-dtbooks" port="result"/>
    </p:output>

    <p:option name="output-dir" required="false" px:output="result" px:type="anyDirURI" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Directory where the validation reports are stored. If left blank,
                nothing is saved to disk.</p>
        </p:documentation>
    </p:option>

    <p:option name="mathml-version" required="false" px:type="string" select="'3.0'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">mathml-version</h2>
            <p px:role="desc">Version of MathML in the DTBook file(s). Defaults to 3.0.</p>
        </p:documentation>
    </p:option>

    <p:option name="check-images" required="false" px:type="string" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">check-images</h2>
            <p px:role="desc">Check to see that images referenced by DTBook file(s) exist on
                disk.</p>
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

    <!-- ***************************************************** -->
    <!-- VALIDATION STEPS -->
    <!-- ***************************************************** -->

    <p:for-each name="validate-dtbooks">
        <p:output port="result" sequence="true">
            <p:pipe port="report" step="validate-dtbook"/>
        </p:output>
        <p:output port="has-mathml" sequence="true">
            <p:pipe port="result" step="look-for-mathml"/>
        </p:output>

        <p:iteration-source select="//pkg:item[@media-type = 'application/x-dtbook+xml']">
            <p:pipe port="source" step="nimas-fileset-validator"/>
        </p:iteration-source>
        
        <p:variable name="dtbook-href" select="*/@href"/>
        <p:variable name="dtbook-uri" select="*/resolve-uri($dtbook-href, base-uri())"/>
        <p:variable name="report-location" select="concat($output-dir, '/', replace($dtbook-href, '/', '_'), '-report.xml')"/>
        
        <p:load name="load-dtbook">
            <p:with-option name="href" select="$dtbook-uri"/>
        </p:load>

        <!-- see if there's MathML -->
        <p:group name="look-for-mathml">
            <p:output port="result"/>
            <p:choose>
                <p:when test="//m:math">
                    <p:identity>
                        <p:input port="source">
                            <p:inline>
                                <tmp:true/>
                            </p:inline>
                        </p:input>
                    </p:identity>
                </p:when>
                <p:otherwise>
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                </p:otherwise>
            </p:choose>
        </p:group>
        
        <px:dtbook-validator name="validate-dtbook">
            <p:input port="source">
                <p:pipe port="result" step="load-dtbook"/>
            </p:input>
            <p:with-option name="check-images" select="$check-images"/>
            <p:with-option name="mathml-version" select="$mathml-version"/>
        </px:dtbook-validator>
        <p:sink/>
        <!-- store the dtbook report at this point, because we can easily access the original OPF path for unique report naming -->
        <p:choose>
            <p:when test="string-length($output-dir) > 0">
                <p:store>
                    <p:input port="source">
                        <p:pipe port="report" step="validate-dtbook"/>
                    </p:input>
                    <p:with-option name="href"
                        select="$report-location"/>
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
    
    </p:for-each>
    
    <p:wrap-sequence name="wrap-has-mathml" wrapper="results"
        wrapper-namespace="http://www.daisy.org/ns/pipeline/tmp" wrapper-prefix="tmp">
        <p:input port="source">
            <p:pipe port="has-mathml" step="validate-dtbooks"/>
        </p:input>
    </p:wrap-sequence>
    
    <p:choose name="validate-package-doc">
        <p:xpath-context>
            <p:pipe port="result" step="wrap-has-mathml"/>
        </p:xpath-context>
        <p:when test="//tmp:true">
            <p:output port="result">
                <p:pipe port="report" step="run-package-doc-validation"/>
            </p:output>
            <px:nimas-fileset-validator.validate-package-doc name="run-package-doc-validation">
                <p:input port="source">
                    <p:pipe port="source" step="nimas-fileset-validator"/>
                </p:input>
                <p:with-option name="math" select="'true'"/>
            </px:nimas-fileset-validator.validate-package-doc>
            <p:sink/>
        </p:when>
        <p:otherwise>
            <p:output port="result">
                <p:pipe port="report" step="run-package-doc-validation"/>
            </p:output>
            <px:nimas-fileset-validator.validate-package-doc name="run-package-doc-validation">
                <p:input port="source">
                    <p:pipe port="source" step="nimas-fileset-validator"/>
                </p:input>
                <p:with-option name="math" select="'false'"/>
            </px:nimas-fileset-validator.validate-package-doc>
            <p:sink/>
        </p:otherwise>
    </p:choose>

    <px:validation-report-to-html name="format-as-html">
        <p:input port="source">
            <p:pipe port="result" step="validate-package-doc"/>
            <p:pipe port="result" step="validate-dtbooks"/>
        </p:input>
        <p:with-option name="toc" select="'true'"/>
    </px:validation-report-to-html>
    
    <!-- ***************************************************** -->
    <!-- STORE REMAINING REPORTS -->
    <!-- ***************************************************** -->
    <p:choose>
        <!-- save reports if we specified an output dir -->
        <p:when test="string-length($output-dir) > 0">
            <p:store name="store-html-report">
                <p:input port="source">
                    <p:pipe port="result" step="format-as-html"/>
                </p:input>
                <p:with-option name="href"
                    select="concat($output-dir,'/validation-report.xhtml')"/>
            </p:store>
            
            <p:store name="store-package-doc-report">
                <p:input port="source">
                    <p:pipe port="result" step="validate-package-doc"/>
                </p:input>
                <p:with-option name="href"
                    select="concat($output-dir,'/package-doc-validation-report.xml')"/>
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
