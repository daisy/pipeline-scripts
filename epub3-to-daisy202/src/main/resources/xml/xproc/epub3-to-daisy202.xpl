<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    type="px:epub3-to-daisy202" name="main" version="1.0" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:pxp="http://exproc.org/proposed/steps" xpath-version="2.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">EPUB3 to DAISY 2.02</h1>
        <p px:role="desc">Transforms an EPUB3 publication into DAISY 2.02.</p>
    </p:documentation>

    <p:output port="html-report" px:media-type="application/vnd.pipeline.report+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">HTML Report</h1>
            <p px:role="desc">An HTML-formatted version of the validation report.</p>
        </p:documentation>
        <p:pipe port="result" step="html"/>
    </p:output>

    <p:output port="validation-status" px:media-type="application/vnd.pipeline.status+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">Validation status</h1>
            <p px:role="desc">Validation status (http://code.google.com/p/daisy-pipeline/wiki/ValidationStatusXML).</p>
        </p:documentation>
        <p:pipe port="result" step="status"/>
    </p:output>

    <p:option name="epub" required="true" px:type="anyFileURI" px:media-type="application/epub+zip">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">EPUB3 Publication</h2>
            <p px:role="desc">EPUB3 Publication.</p>
        </p:documentation>
    </p:option>

    <p:option name="temp-dir" required="true" px:output="temp" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Temporary directory</h2>
            <p px:role="desc">Temporary directory for use by the script.</p>
        </p:documentation>
    </p:option>

    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">DAISY 2.02</h2>
            <p px:role="desc">Output directory for the DAISY 2.02.</p>
        </p:documentation>
    </p:option>

    <p:option name="assert-valid" required="false" select="'true'" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Stop processing on validation error</h2>
            <p px:role="desc">Whether or not to stop the conversion when a validation error occurs. Setting this to false may be useful for debugging or if the validation error is a minor one. The
                output is not guaranteed to be valid if this option is set to false.</p>
        </p:documentation>
    </p:option>

    <p:import href="step/epub3-to-daisy202.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/validation-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/zip-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>

    <p:variable name="epub-href" select="resolve-uri($epub,base-uri(/*))">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>

    <!-- TODO: add input validation using epubcheck (if p:step-available('px:epubcheck')) -->

    <px:unzip-fileset name="unzip">
        <p:with-option name="href" select="$epub-href"/>
        <p:with-option name="unzipped-basedir" select="concat($temp-dir,'epub/')"/>
    </px:unzip-fileset>
    
    <!-- This is a workaround for a bug that should be fixed in Pipeline v1.8
                 see: https://github.com/daisy-consortium/pipeline-modules-common/pull/49 -->
    <p:delete match="/*/*[ends-with(@href,'/')]" name="load.in-memory.fileset-fix"/>
    
    <p:for-each>
        <p:iteration-source>
            <p:pipe port="in-memory.out" step="unzip"/>
        </p:iteration-source>
        <p:choose>
            <p:when test="ends-with(base-uri(/*),'/')">
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <p:identity name="load.in-memory"/>
    
    <px:fileset-store name="load.stored">
        <p:input port="fileset.in">
            <p:pipe port="result" step="load.in-memory.fileset-fix"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe port="result" step="load.in-memory"/>
        </p:input>
    </px:fileset-store>
    
    <px:epub3-to-daisy202-convert name="convert.daisy202">
        <p:input port="fileset.in">
            <p:pipe port="fileset.out" step="load.stored"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe port="result" step="load.in-memory"/>
        </p:input>
    </px:epub3-to-daisy202-convert>
    
    <px:fileset-move name="move">
        <p:with-option name="new-base" select="concat($output-dir,replace(base-uri(/*),'^.*/([^/]+)/[^/]*$','$1/'))"/>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="convert.daisy202"/>
        </p:input>
    </px:fileset-move>
    
    <px:fileset-store name="fileset-store">
        <p:input port="fileset.in">
            <p:pipe port="fileset.out" step="move"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="move"/>
        </p:input>
    </px:fileset-store>

</p:declare-step>
