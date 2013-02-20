<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="nimas-fileset-validator.create-reports-index"
    type="pxi:nimas-fileset-validator.create-reports-index" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:l="http://xproc.org/library" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:pkg="http://openebook.org/namespaces/oeb-package/1.0/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:m="http://www.w3.org/1998/Math/MathML"
    exclude-inline-prefixes="#all">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Create reports index</h1>
        <p px:role="desc">NIMAS Fileset Validator helper step.</p>
    </p:documentation>

    <!-- ***************************************************** -->
    <!-- INPUTS / OUTPUTS / OPTIONS -->
    <!-- ***************************************************** -->
    <p:input port="source" primary="true" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">source</h1>
            <p px:role="desc">A sequence of validation reports, formatted as <a
                    href="http://code.google.com/p/daisy-pipeline/wiki/ValidationReportXML"
                    >Validation Report XML</a>.</p>
        </p:documentation>
    </p:input>

    <p:output port="result" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">result</h1>
            <p px:role="desc">An HTML-formatted index of all validation reports, plus one extra
                entry for the HTML summary report.</p>
        </p:documentation>
    </p:output>

    <cx:message message="Nimas fileset validator: Creating reports index."/>
    <p:sink/>
    
    <p:group name="reports-index-init">
        <p:output port="result"/>
        <p:identity>
            <p:input port="source">
                <p:inline>
                    <html xmlns="http://www.w3.org/1999/xhtml">
                        <head>
                            <title>Validation Report Index</title>
                            <style> body { font-family: helvetica; } tr { line-height: 150%; } td {
                                padding-left: 30px; border: thin solid black; } table { border: thin
                                solid black; border-collapse:collapse; } #datetime { font-style:
                                italic; } </style>
                        </head>
                        <body>
                            <h1>Validation Reports Index</h1>
                            
                            <p id="html-summary"><a href="validation-report.xhtml">Link to an HTML-formatted
                                summary of validation errors</a>.</p>

                            <table id="toc">
                                <thead>
                                    <tr>
                                        <th>File type</th>
                                        <th>Report path</th>
                                        <th>File path</th>
                                    </tr>
                                </thead>
                                <tbody/>
                            </table>
                        </body>
                    </html>
                </p:inline>
            </p:input>
        </p:identity>
    </p:group>

    <p:for-each name="generate-trs">
        <p:output port="result"/>

        <p:iteration-source>
            <p:pipe port="source" step="nimas-fileset-validator.create-reports-index"/>
        </p:iteration-source>

        <!-- @extra holds the report filename -->
        <p:variable name="reportpath" select="*/@extra"/>
        <p:variable name="filetype" select="*/d:document-info/d:document-type"/>
        <p:variable name="filepath" select="*/d:document-info/d:document-path"/>

        <p:identity>
            <p:input port="source">
                <p:inline>
                    <tr xmlns="http://www.w3.org/1999/xhtml">
                        <td class="filetype">@@</td>
                        <td class="reportpath">
                            <a href="@@">@@</a>
                        </td>
                        <td class="filepath">
                            <a href="@@">@@</a>
                        </td>
                    </tr>
                </p:inline>
            </p:input>
        </p:identity>

        <p:string-replace match="xhtml:td[@class='filetype']/text()">
            <p:with-option name="replace" select="concat('&quot;', $filetype, '&quot;')"/>
        </p:string-replace>

        <p:string-replace match="xhtml:td[@class='reportpath']/xhtml:a/@href">
            <p:with-option name="replace" select="concat('&quot;', $reportpath, '&quot;')"/>
        </p:string-replace>

        <p:string-replace match="xhtml:td[@class='reportpath']/xhtml:a/text()">
            <p:with-option name="replace" select="concat('&quot;', $reportpath, '&quot;')"/>
        </p:string-replace>

        <p:string-replace match="xhtml:td[@class='filepath']/xhtml:a/@href">
            <p:with-option name="replace" select="concat('&quot;', $filepath, '&quot;')"/>
        </p:string-replace>

        <p:string-replace match="xhtml:td[@class='filepath']/xhtml:a/text()">
            <p:with-option name="replace" select="concat('&quot;', $filepath, '&quot;')"/>
        </p:string-replace>

    </p:for-each>

    <p:insert position="last-child" match="xhtml:table[@id='toc']/xhtml:tbody">
        <p:input port="insertion">
            <p:pipe port="result" step="generate-trs"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="result" step="reports-index-init"/>
        </p:input>
    </p:insert>

</p:declare-step>
