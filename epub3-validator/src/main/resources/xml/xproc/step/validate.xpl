<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:html="http://www.w3.org/1999/xhtml" type="px:epub3-validator.validate"
    version="1.0" xmlns:d="http://www.daisy.org/ns/pipeline/data">

    <p:option name="epub" required="true" px:type="anyFileURI" px:media-type="application/epub+zip application/oebps-package+xml"/>
    <p:option name="mode" required="false" px:type="string" select="'epub'"/>
    <p:option name="version" required="false" px:type="string" select="'3'"/>

    <p:input port="report.in" sequence="true" primary="false">
        <p:empty/>
    </p:input>

    <p:output port="report.out" sequence="true" primary="false">
        <p:pipe port="report.in" step="main"/>
        <p:pipe port="result" step="xml-report"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epubcheck-adapter/library.xpl"/>

    <px:epubcheck>
        <p:with-option name="epub" select="$epub"/>
        <p:with-option name="mode" select="if ($mode='') then (if (matches(lower-case($epub),'\.(opf|xml)$')) then 'expanded' else 'epub') else $mode"/>
        <p:with-option name="version" select="if ($version='') then '3' else $version"/>
    </px:epubcheck>

    <p:xslt name="xml-report.not-wrapped">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../../xslt/epubcheck-report-to-pipeline-report.xsl"/>
        </p:input>
    </p:xslt>
    <p:for-each>
        <p:iteration-source select="//d:warn">
            <p:pipe port="result" step="xml-report.not-wrapped"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>
    <p:wrap-sequence wrapper="d:warnings" name="warnings"/>
    <p:for-each>
        <p:iteration-source select="//d:error">
            <p:pipe port="result" step="xml-report.not-wrapped"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>
    <p:wrap-sequence wrapper="d:errors" name="errors"/>
    <p:for-each name="exception">
        <p:iteration-source select="//d:exception">
            <p:pipe port="result" step="xml-report.not-wrapped"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>
    <p:wrap-sequence wrapper="d:exceptions" name="exceptions"/>
    <p:for-each name="hint">
        <p:iteration-source select="//d:hint">
            <p:pipe port="result" step="xml-report.not-wrapped"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>
    <p:wrap-sequence wrapper="d:hints" name="hints"/>
    <p:delete match="//d:report/*">
        <p:input port="source">
            <p:pipe port="result" step="xml-report.not-wrapped"/>
        </p:input>
    </p:delete>
    <p:insert match="//d:report" position="first-child">
        <p:input port="insertion">
            <p:pipe port="result" step="exceptions"/>
            <p:pipe port="result" step="errors"/>
            <p:pipe port="result" step="warnings"/>
            <p:pipe port="result" step="hints"/>
        </p:input>
    </p:insert>
    <p:delete match="//d:report/*[not(*)]"/>
    <p:identity name="xml-report"/>

</p:declare-step>
