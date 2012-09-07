<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="validate-dtbook" type="px:validate-dtbook" 
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
        <p:documentation>
            A DTBook-2005-3 document
        </p:documentation>
    </p:input>
    
    <p:output port="result" primary="true">
        <p:documentation>
            A copy of the input document; may include PSVI annotations.
        </p:documentation>
        <p:pipe port="result" step="validate-against-relaxng"/>
    </p:output>
    
    <p:output port="relaxng-report" sequence="true">
        <p:documentation>
            Raw output from the relax ng validation.
        </p:documentation>
        <p:pipe port="report" step="validate-against-relaxng"/>
    </p:output>
    
    <p:output port="schematron-report">
        <p:documentation>
            Raw output from the schematron validation.
        </p:documentation>
        <p:pipe step="validate-against-schematron" port="report"/>
    </p:output>
    
    <p:output port="html-report">
        <p:documentation>
            An HTML-formatted version of both the Relax NG and Schematron reports.
        </p:documentation>
        <p:pipe port="result" step="create-html-report"/>
    </p:output>
    
    <p:option name="advanced" required="false" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Advanced mode</h2>
            <p px:role="desc">Check the document using Schematron, in addition to Relax NG. Default value is <code>true</code>.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="output-dir" required="false" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Output directory</h2>
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
    
    <p:variable name="advanced-mode" select="if ($advanced = 'false') then false() else true()"/>
    
    <l:relax-ng-report name="validate-against-relaxng" assert-valid="false">
        <p:input port="schema">
            <p:document href="./schema/dtbook-2005-3.rng"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="source" step="validate-dtbook"/>
        </p:input>
    </l:relax-ng-report>

    <p:choose name="validate-against-schematron">
        <p:when test="$advanced-mode">
            <p:output port="report">
                <p:pipe port="report" step="run-schematron"/>
            </p:output>
            <p:output port="result" primary="true">
                <p:pipe port="result" step="run-schematron"/>
            </p:output>
            <p:validate-with-schematron assert-valid="false" name="run-schematron">
                <p:input port="schema">
                    <p:document href="./schema/dtbook.sch"/>
                </p:input>
                <p:input port="source">
                    <p:pipe port="source" step="validate-dtbook"/>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
            </p:validate-with-schematron>  
        </p:when>
        <p:otherwise>
            <p:documentation>Just put empty documents on the result and report ports; it makes life easier in subsequent steps.</p:documentation>
            <p:output port="result" primary="true">
                <p:pipe port="result" step="id1"/>
            </p:output>
            <p:output port="report">
                <p:pipe port="result" step="id1"/>
            </p:output>
            <p:identity name="id1">
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    <p:sink/>
    
    <p:count name="count" limit="1">
        <p:documentation>Relax NG validation doesn't always produce a report, so this serves as a 
            test to see if there was a document produced.</p:documentation>
        <p:input port="source">
            <p:pipe step="validate-against-relaxng" port="report"/>
        </p:input>
    </p:count>
    <p:sink/>
    
    <p:choose name="htmlify-relaxng-report">
        <p:xpath-context>
            <p:pipe port="result" step="count"/>
        </p:xpath-context>
        
        <p:when test="/c:result = '0'">
            <p:documentation>If there was no report, just output an empty document.</p:documentation>
            <p:output port="result"/>
            <p:identity>
                <p:input port="source">
                    <p:empty/>
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
    
    
    <p:wrap-sequence name="combine-reports" wrapper="body" wrapper-namespace="http://www.w3.org/1999/xhtml">
        <p:documentation>join the reports</p:documentation>
        <p:input port="source">
            <p:pipe port="result" step="htmlify-relaxng-report"/>
            <p:pipe port="result" step="htmlify-schematron-report"/>
        </p:input>
    </p:wrap-sequence>
    
    <p:insert position="last-child" name="create-html-report">
        <p:input port="source">
            <p:inline>
                <html xmlns="http://www.w3.org/1999/xhtml">
                    <header>
                        <title>Validation Report</title>
                    </header>
                    <h1>Validation Report</h1>
                </html>
            </p:inline>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="result" step="combine-reports"/>
        </p:input>
    </p:insert>
    
    <p:choose name="store-reports">
        <p:documentation>Save the reports to disk</p:documentation>
        <p:when test="not(empty($output-dir))">
            <p:store name="store-html">
                <p:input port="source">
                    <p:pipe port="result" step="create-html-report"/>
                </p:input>
                <p:with-option name="href" select="concat($output-dir,'report.xhtml')"/>
            </p:store>

            
            <p:choose>
                <p:xpath-context>
                    <p:pipe port="result" step="count"/>
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
