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
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:m="http://www.w3.org/1998/Math/MathML"
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
    
    <p:output port="validation-status">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">validation-status</h1>
            <p px:role="desc">Validation status (http://code.google.com/p/daisy-pipeline/wiki/ValidationStatusXML).</p>
        </p:documentation>
        <p:pipe step="format-validation-status" port="result"/>
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
    
    <p:import href="nimas-fileset-validator.fileset-filter.xpl"/>
    
    <p:variable name="base-uri" select="base-uri()"/>
    <p:variable name="package-doc-filename" select="tokenize($base-uri, '/')[last()]"/>

    <cx:message message="Nimas fileset validator: validating files."/>
    <p:sink/>

    <!-- ***************************************************** -->
    <!-- VALIDATION STEPS -->
    <!-- ***************************************************** -->
    
    <!-- check for missing dtbook files -->
    <pxi:nimas-fileset-validator.fileset-filter media-type="application/x-dtbook+xml" name="filter-fileset">
        <p:input port="source">
            <p:pipe port="source" step="nimas-fileset-validator"/>
        </p:input>
    </pxi:nimas-fileset-validator.fileset-filter>
    <px:check-files-exist name="check-dtbooks-exist"/>
    
    <!-- TODO: create report for missing DTBooks -->
    
    <p:for-each name="validate-dtbooks">
        <p:output port="result" sequence="true">
            <p:pipe port="result" step="validate-dtbook-group"/>
        </p:output>
        <p:output port="has-mathml" sequence="true">
            <p:pipe port="result" step="look-for-mathml"/>
        </p:output>

        <p:iteration-source select="//d:file">
            <p:pipe port="result" step="check-dtbooks-exist"/>
        </p:iteration-source>

        <p:variable name="dtbook-href" select="*/@href"/>
        <p:variable name="dtbook-filename" select="tokenize($dtbook-href, '/')[last()]"/>
        
        <!-- TODO: will this be unique? 
            We should actually relativize $dtbook-href wrt the package file rather than just take the filename part of the path. -->
        <p:variable name="report-filename"
            select="concat(replace($dtbook-filename, '/', '_'), '-report.xml')"/>

        <cx:message>
            <p:with-option name="message"
                select="concat('Nimas fileset validator: Loading DTBook document: ', $dtbook-href)"/>
        </cx:message>
        <p:sink/>
        
        <p:load name="load-dtbook">
            <p:with-option name="href" select="$dtbook-href"/>
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
        
        <p:group name="validate-dtbook-group">
            <p:output port="result"/>
            
            <cx:message message="Nimas fileset validator: Validating DTBook document."/>
            <p:sink/>
            
            <px:dtbook-validator name="validate-dtbook">
                <p:input port="source">
                    <p:pipe port="result" step="load-dtbook"/>
                </p:input>
                <p:with-option name="check-images" select="$check-images"/>
                <p:with-option name="mathml-version" select="$mathml-version"/>
            </px:dtbook-validator>
            
            <!-- add the report path -->
            <p:insert position="last-child" match="//d:document-info">
                <p:input port="insertion">
                    <p:inline>
                        <d:report-path>@@</d:report-path>
                    </p:inline>
                </p:input>
                <p:input port="source">
                    <p:pipe port="report" step="validate-dtbook"/>
                </p:input>
            </p:insert>
            <p:string-replace match="d:document-info/d:report-path/text()">
                <p:with-option name="replace"
                    select="concat('&quot;', $report-filename, '&quot;')"/>
            </p:string-replace>
        </p:group>
    </p:for-each>
    
    <!-- wrap the has-mathml port from the previous step -->
    <p:wrap-sequence name="wrap-has-mathml" wrapper="results"
        wrapper-namespace="http://www.daisy.org/ns/pipeline/tmp" wrapper-prefix="tmp">
        <p:input port="source">
            <p:pipe port="has-mathml" step="validate-dtbooks"/>
        </p:input>
    </p:wrap-sequence>
    
    <!-- if there is a tmp:true element in the has-mathml results, then one of the dtbooks had mathml -->
    <p:group name="validate-package-doc">
        <p:output port="result"/>
        <p:choose name="validate-package-doc-choose">
            <p:xpath-context>
                <p:pipe port="result" step="wrap-has-mathml"/>
            </p:xpath-context>
            <p:when test="//tmp:true">
                <p:output port="result">
                    <p:pipe port="report" step="run-package-doc-validation"/>
                </p:output>
                <pxi:nimas-fileset-validator.validate-package-doc name="run-package-doc-validation">
                    <p:input port="source">
                        <p:pipe port="source" step="nimas-fileset-validator"/>
                    </p:input>
                    <p:with-option name="math" select="'true'"/>
                </pxi:nimas-fileset-validator.validate-package-doc>
                <p:sink/>
            </p:when>
            <p:otherwise>
                <p:output port="result">
                    <p:pipe port="report" step="run-package-doc-validation"/>
                </p:output>
                <pxi:nimas-fileset-validator.validate-package-doc name="run-package-doc-validation">
                    <p:input port="source">
                        <p:pipe port="source" step="nimas-fileset-validator"/>
                    </p:input>
                    <p:with-option name="math" select="'false'"/>
                </pxi:nimas-fileset-validator.validate-package-doc>
                <p:sink/>
            </p:otherwise>
        </p:choose>

        <!-- add the report path -->
        <p:insert position="last-child" match="d:document-info">
            <p:input port="insertion">
                <p:inline>
                    <d:report-path>@@</d:report-path>
                </p:inline>
            </p:input>
        </p:insert>
        <p:string-replace match="d:document-info/d:report-path/text()">
            <p:with-option name="replace"
                select="concat('&quot;', $package-doc-filename, '-report.xml&quot;')"/>
        </p:string-replace>
    </p:group>

    <cx:message message="Nimas fileset validator: Formatting report as HTML."/>
    <p:sink/>

    <px:validation-report-to-html name="format-as-html">
        <p:input port="source">
            <p:pipe port="result" step="validate-package-doc"/>
            <p:pipe port="result" step="validate-dtbooks"/>
        </p:input>
        <p:with-option name="toc" select="'true'"/>
    </px:validation-report-to-html>    
    
    <px:validation-status name="format-validation-status">
        <p:input port="source">
            <p:pipe port="result" step="validate-package-doc"/>
            <p:pipe port="result" step="validate-dtbooks"/>
        </p:input>
    </px:validation-status>
    
    <!-- ***************************************************** -->
    <!-- STORE REPORTS -->
    <!-- ***************************************************** -->

    <p:choose>
        <!-- save reports if we specified an output dir -->
        <p:when test="string-length($output-dir) > 0">
            <cx:message>
                <p:with-option name="message"
                    select="concat('Nimas fileset validator: Storing reports to disk in output directory: ', $output-dir)"
                />
            </cx:message>
            <p:sink/>

            <p:for-each>
                <p:iteration-source>
                    <p:pipe port="result" step="validate-dtbooks"/>
                    <p:pipe port="result" step="validate-package-doc"/>
                </p:iteration-source>
                <p:variable name="report-filename"
                    select="/d:document-validation-report/d:document-info/d:report-path/text()"/>
                <p:store name="store-report">
                    <p:with-option name="href" select="concat($output-dir,'/', $report-filename)"/>
                </p:store>
            </p:for-each>

            <p:store name="store-html-report">
                <p:input port="source">
                    <p:pipe port="result" step="format-as-html"/>
                </p:input>
                <p:with-option name="href" select="concat($output-dir,'/validation-report.xhtml')"/>
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
