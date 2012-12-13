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
    exclude-inline-prefixes="#all">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DTBook Validator</h1>
        <p px:role="desc">Validates DTBook-2005-3 documents.</p>
    </p:documentation>

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
        <p:pipe port="report" step="validate-against-relaxng"/>
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
            <p px:role="desc">An HTML-formatted version of both the RelaxNG and Schematron reports.</p>
        </p:documentation>
        <p:pipe port="result" step="insert-file-name-into-html-report"/>
    </p:output>
    
    <p:option name="output-dir" required="false" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Directory where your validation report is stored. If left blank, nothing is saved to disk.</p>
        </p:documentation>
    </p:option>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>Calabash extension steps.</p:documentation>
    </p:import>
    
    <p:import href="http://www.daisy.org/pipeline/modules/validation-utils/validation-utils-library.xpl">
        <p:documentation>
            Collection of utilities for validation and reporting.
        </p:documentation>
    </p:import>
    
    <p:variable name="base-uri" select="base-uri()">
        <p:pipe port="source" step="dtbook-validator"/>
    </p:variable>
    
    <l:relax-ng-report name="validate-against-relaxng" assert-valid="false">
        <p:input port="schema">
            <p:document href="./schema/dtbook-2005-3.mathml-2.integration.rng"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="source" step="dtbook-validator"/>
        </p:input>
    </l:relax-ng-report>

    <p:validate-with-schematron assert-valid="false" name="validate-against-schematron">
        <p:input port="schema">
            <p:document href="./schema/dtbook.sch"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="source" step="dtbook-validator"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:validate-with-schematron>
    <p:sink/>
    
    <p:xslt name="htmlify-schematron-report">
        <p:input port="source">
            <p:pipe port="report" step="validate-against-schematron"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="schematron-report.xsl"/>
        </p:input>
    </p:xslt>
    
    <p:count name="count-relaxng-report" limit="1">
        <p:documentation>RelaxNG validation doesn't always produce a report, so this serves as a 
            test to see if there was a document produced.</p:documentation>
        <p:input port="source">
            <p:pipe step="validate-against-relaxng" port="report"/>
        </p:input>
    </p:count>
    <p:sink/>
    
    <p:choose name="htmlify-relaxng-report">
        <p:xpath-context>
            <p:pipe port="result" step="count-relaxng-report"/>
        </p:xpath-context>
        
        <p:when test="/c:result = '0'">
            <p:documentation>Format the results of RelaxNG validation as HTML.</p:documentation>
            <p:output port="result"/>
            <p:identity>
                <p:input port="source">
                    <p:inline>
                        <section xmlns="http://www.w3.org/1999/xhtml">
                            <h2>RelaxNG Validation Results</h2>
                            <p>No errors detected.</p>
                        </section>
                    </p:inline>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:documentation>If a report was produced, transform it to HTML.</p:documentation>
            <p:output port="result"/>
            <p:xslt>
                <p:input port="source">
                    <p:pipe port="report" step="validate-against-relaxng"/>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="relaxng-report.xsl"/>
                </p:input>
            </p:xslt>
        </p:otherwise>
    </p:choose>
    
    <p:insert position="last-child" match="//xhtml:body" name="create-html-report">
        <p:input port="source">
            <p:inline>
                <html xmlns="http://www.w3.org/1999/xhtml">
                    <head>
                        <title>Validation Results</title>
                        <style type="text/css">
                            body {
                            font-family: helvetica;
                            }
                            
                            .error pre {
                            white-space: pre-wrap;       /* css-3 */
                            white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */
                            white-space: -pre-wrap;      /* Opera 4-6 */
                            white-space: -o-pre-wrap;    /* Opera 7 */
                            word-wrap: break-word;       /* Internet Explorer 5.5+ */
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
                        <h1>Validation Results for <span id="filename">@@</span></h1>
                    </body>
                </html>
            </p:inline>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="result" step="htmlify-relaxng-report"/>
            <p:pipe port="result" step="htmlify-schematron-report"/>
        </p:input>
    </p:insert>
    
    <p:string-replace match="//xhtml:span[@id='filename']/text()" name="insert-file-name-into-html-report">
        <p:input port="source">
            <p:pipe port="result" step="create-html-report"/>
        </p:input>
        <p:with-option name="replace" select="'TESTING'"/>
    </p:string-replace>
    
    <p:choose name="store-reports">
        <p:documentation>Save the reports to disk</p:documentation>
        <p:when test="not(empty($output-dir))">
            <p:store name="store-html">
                <p:input port="source">
                    <p:pipe port="result" step="insert-file-name-into-html-report"/>
                </p:input>
                <p:with-option name="href" select="concat($output-dir,'report.xhtml')"/>
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
                        <p:with-option name="href" select="concat($output-dir,'relax-ng-report.xml')"/>
                    </p:store>
                </p:otherwise>
                
            </p:choose>
            
            <p:store name="store-schematron">
                <p:input port="source">
                    <p:pipe port="report" step="validate-against-schematron"/>
                </p:input>
                <p:with-option name="href" select="concat($output-dir,'schematron-report.xml')"/>
            </p:store>
        </p:when>
    </p:choose>
    
</p:declare-step>
