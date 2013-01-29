<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-validator" type="px:dtbook-validator"
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
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    exclude-inline-prefixes="#all">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">NIMAS Fileset Validator</h1>
        <p px:role="desc">Validates NIMAS filesets.</p>
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
            <p px:role="desc">A validation report.</p>
        </p:documentation>
        <p:pipe port="result" step="validate-against-relaxng"/>
    </p:output>

    <p:output port="dtbook-relaxng-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">dtbook-relaxng-report</h1>
            <p px:role="desc">Raw output from the RelaxNG validation of the DTBook file.</p>
        </p:documentation>
        <p:pipe step="validate-dtbook" port="relaxng-report"/>
    </p:output>

    <p:output port="dtbook-schematron-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">schematron-report</h1>
            <p px:role="desc">Raw output from the schematron validation of the DTBook file.</p>
        </p:documentation>
        <p:pipe step="validate-dtbook" port="schematron-report"/>
    </p:output>
    
    <p:output port="package-doc-relaxng-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">package-doc-relaxng-report</h1>
            <p px:role="desc">Raw output from the RelaxNG validation of the package document.</p>
        </p:documentation>
        <p:pipe step="validate-package-doc" port="relaxng-report"/>
    </p:output>
    
    <p:output port="package-doc-schematron-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">package-doc-relaxng-report</h1>
            <p px:role="desc">Raw output from the RelaxNG validation of the package document.</p>
        </p:documentation>
        <p:pipe step="validate-package-doc" port="schematron-report"/>
    </p:output>
    
    <p:output port="html-report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">html-report</h1>
            <p px:role="desc">An HTML-formatted validation summary.</p>
        </p:documentation>
        <p:pipe port="result" step="create-html-report"/>
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
        <p:documentation> Collection of utilities for validation and reporting. </p:documentation>
    </p:import>

    <p:variable name="base-uri" select="base-uri()">
        <p:pipe port="source" step="dtbook-validator"/>
    </p:variable>
    
    <p:variable name="opt-mathml-version"
        select="if (string-length($mathml-version) > 0) 
        then $mathml-version
        else '3.0'"/>

    <p:variable name="has-mathml" select="if (count(//m:math) > 0) then true() else false()">
        <p:pipe port="source" step="dtbook-validator"/>
    </p:variable>

    
    <!-- ***************************************************** -->
    <!-- VALIDATION STEPS -->
    <!-- ***************************************************** -->
    
    
    <!-- ***************************************************** -->
    <!-- REPORTING -->
    <!-- ***************************************************** -->
    
    <p:group name="create-html-report">
        <p:output port="result"/>
        <p:insert position="last-child" match="//xhtml:body" name="assemble-html-report">
            <p:input port="source">
                <p:inline>
                    <html xmlns="http://www.w3.org/1999/xhtml">
                        <head>
                            <title>Validation Results</title>
                            <style type="text/css"> 
                                body { 
                                    font-family: helvetica; 
                                } 
                                pre { 
                                    white-space: pre-wrap; /* css-3 */ 
                                    white-space: -moz-pre-wrap; /*Mozilla, since 1999 */ 
                                    white-space: -pre-wrap; /* Opera 4-6 */
                                    white-space: -o-pre-wrap; /* Opera 7 */ 
                                    word-wrap: break-word; /*Internet Explorer 5.5+ */ 
                                } 
                                li.error div { 
                                    display: table; 
                                    border: gray thin solid; 
                                    padding: 5px; 
                                } 
                                li.error div h3 { 
                                    display: table-cell; 
                                    padding-right: 10px; 
                                    font-size: smaller; 
                                } 
                                li.error div pre { 
                                    display: table-cell; 
                                } 
                                li { 
                                    padding-bottom: 15px; 
                                } 
                            </style>
                        </head>
                        <body>
                            <h1>Validation Results</h1>
                            <p>Input document:</p>
                            <pre id="filename">@@</pre>
                            <p>Validating as DTBook <span id="dtbook-version">@@</span>
                                <span id="with-mathml"> with MathML <span id="mathml-version">@@</span></span></p>
                        </body>
                    </html>
                </p:inline>
            </p:input>
            <p:input port="insertion">
                <p:pipe port="result" step="htmlify-relaxng-report"/>
                <p:pipe port="result" step="htmlify-schematron-report"/>
            </p:input>
        </p:insert>

        <p:string-replace match="//*[@id='filename']/text()"
            name="insert-file-name-into-html-report">
            <p:with-option name="replace" select="concat('&quot;', $base-uri, '&quot;')"/>
        </p:string-replace>

        <p:string-replace match="//*[@id='dtbook-version']/text()"
            name="insert-dtbook-version-into-html-report">
            <p:with-option name="replace" select="concat('&quot;', $dtbook-version, '&quot;')"/>
        </p:string-replace>
        
        <p:choose>
            <p:when test="$has-mathml = true()">
                <p:string-replace match="//*[@id='mathml-version']/text()"
                    name="insert-mathml-version-into-html-report">
                    <p:with-option name="replace" 
                        select="concat('&quot;', $opt-mathml-version, '&quot;')"/>
                </p:string-replace>
            </p:when>
            <p:otherwise>
                <p:delete match="//*[@id='with-mathml']"/>
            </p:otherwise>
        </p:choose>
    </p:group>




    <!-- ***************************************************** -->
    <!-- STORING -->
    <!-- ***************************************************** -->
    <p:choose name="store-reports">
        <p:documentation>Save the reports to disk</p:documentation>
        <p:when test="not(empty($output-dir))">
            <p:store name="store-html">
                <p:input port="source">
                    <p:pipe port="result" step="create-html-report"/>
                </p:input>
                <p:with-option name="href" select="concat($output-dir,'/report.xhtml')"/>
            </p:store>

            <p:choose>
                <p:xpath-context>
                    <p:pipe port="result" step="count-relaxng-report"/>
                </p:xpath-context>
                <p:when test="/c:result = '0'">
                    <p:sink>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:sink>
                </p:when>
                <p:otherwise>
                    <p:store name="store-relaxng">
                        <p:input port="source">
                            <p:pipe port="report" step="validate-against-relaxng"/>
                        </p:input>
                        <p:with-option name="href"
                            select="concat($output-dir,'/relax-ng-report.xml')"/>
                    </p:store>
                </p:otherwise>
            </p:choose>

            <p:store name="store-schematron">
                <p:input port="source">
                    <p:pipe port="report" step="validate-against-schematron"/>
                </p:input>
                <p:with-option name="href" select="concat($output-dir,'/schematron-report.xml')"/>
            </p:store>
        </p:when>
    </p:choose>

</p:declare-step>
