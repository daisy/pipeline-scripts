<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:dc="http://purl.org/dc/elements/1.1/"
    px:input-filesets="epub3"
    px:output-filesets="daisy202"
    type="px:epub3-to-daisy202" name="main" version="1.0" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:pxp="http://exproc.org/proposed/steps" xpath-version="2.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">EPUB 3 to DAISY 2.02</h1>
        <p px:role="desc">Transforms an EPUB 3 publication into DAISY 2.02.</p>
        <a px:role="homepage" href="http://daisy.github.io/pipeline/modules/epub3-to-daisy202">
            Online documentation
        </a>
    </p:documentation>

    <p:option name="epub" required="true" px:type="anyFileURI" px:media-type="application/epub+zip application/oebps-package+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">EPUB 3 Publication</h2>
            <p px:role="desc" xml:space="preserve">The EPUB 3 you want to convert to DAISY 2.02.

You may alternatively use the EPUB package document (the OPF-file) if your input is a unzipped/"exploded" version of an EPUB.</p>
        </p:documentation>
    </p:option>

    <p:option name="validation" required="false" px:type="string" select="'off'">
        <p:pipeinfo>
            <px:data-type>
                <choice xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0">
                    <value>off</value>
                    <a:documentation xml:lang="en">No validation</a:documentation>
                    <value>report</value>
                    <a:documentation xml:lang="en">Report validation issues</a:documentation>
                    <value>abort</value>
                    <a:documentation xml:lang="en">Abort on validation issues</a:documentation>
                </choice>
            </px:data-type>
        </p:pipeinfo>
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Validation</h2>
            <p px:role="desc">Whether to abort on validation issues.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="temp-dir" required="true" px:output="temp" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Temporary directory</h2>
        </p:documentation>
    </p:option>

    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">DAISY 2.02</h2>
        </p:documentation>
    </p:option>

    <p:output port="validation-report" sequence="true" px:media-type="application/vnd.pipeline.report+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">Input validation report</h1>
        </p:documentation>
        <p:pipe step="validate" port="report"/>
    </p:output>

    <p:output port="validation-status" px:media-type="application/vnd.pipeline.status+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">Input validation status</h1>
            <p px:role="desc" xml:space="preserve">An XML document describing, briefly, whether the input validation was successful.

[More details on the file format](http://daisy.github.io/pipeline/ValidationStatusXML).</p>
        </p:documentation>
        <p:pipe step="validate" port="status"/>
    </p:output>
    
    <p:import href="step/epub3-to-daisy202.load.xpl"/>
    <p:import href="step/epub3-to-daisy202.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-validator/library.xpl"/>

    <p:variable name="epub-href" select="resolve-uri($epub,base-uri(/*))">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>

    <px:epub3-to-daisy202.load name="load">
        <p:with-option name="epub" select="$epub-href"/>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </px:epub3-to-daisy202.load>
    
    <!--
        FIXME: Scripts should not throw errors. They should set the status output to "FAIL".
    -->
    <px:fileset-load media-types="application/oebps-package+xml">
        <p:input port="fileset">
            <p:pipe step="load" port="fileset.out"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe step="load" port="in-memory.out"/>
        </p:input>
    </px:fileset-load>
    <px:assert test-count-min="1" test-count-max="1" error-code="PED01" message="The EPUB must contain exactly one OPF document"/>
    <px:assert error-code="PED02" message="There must be at least one dc:identifier meta element in the OPF document">
        <p:with-option name="test" select="exists(/opf:package/opf:metadata/dc:identifier)"/>
    </px:assert>

    <p:choose name="validate">
        <p:when test="$validation='off'">
            <p:output port="fileset.out">
                <p:pipe step="load" port="fileset.out"/>
            </p:output>
            <p:output port="in-memory.out" sequence="true">
                <p:pipe step="load" port="in-memory.out"/>
            </p:output>
            <p:output port="report" sequence="true">
                <p:empty/>
            </p:output>
            <p:output port="status">
                <p:inline>
                    <d:validation-status result="ok"/>
                </p:inline>
            </p:output>
            <p:sink>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:sink>
        </p:when>
        <p:otherwise>
            <p:output port="fileset.out">
                <p:pipe step="load" port="fileset.out"/>
            </p:output>
            <p:output port="in-memory.out" sequence="true">
                <p:pipe step="load" port="in-memory.out"/>
            </p:output>
            <p:output port="report" sequence="true">
                <p:pipe step="status-and-report" port="report"/>
            </p:output>
            <p:output port="status">
                <p:pipe step="status-and-report" port="status"/>
            </p:output>
            <px:epub3-validator name="epub3-validator">
                <p:with-option name="epub" select="/d:fileset/d:file[@media-type='application/oebps-package+xml']
                                                   /resolve-uri((@original-href,@href)[1], base-uri(.))">
                    <p:pipe step="load" port="fileset.out"/>
                </p:with-option>
            </px:epub3-validator>
            <p:identity>
                <p:input port="source">
                    <p:pipe step="epub3-validator" port="validation-status"/>
                </p:input>
            </p:identity>
            <p:choose name="status-and-report">
                <p:when test="/d:validation-status[@result='ok']">
                    <p:output port="status" primary="true"/>
                    <p:output port="report" sequence="true">
                        <p:empty/>
                    </p:output>
                    <p:identity/>
                </p:when>
                <p:when test="$validation='report'">
                    <p:output port="status" primary="true">
                        <!--
                            Return OK here even though validation failed. This is because
                            "VALIDATION_FAIL" is going to be generalized to "FAIL"
                            (https://github.com/daisy/pipeline-framework/issues/121).
                        -->
                        <p:inline>
                            <d:validation-status result="ok"/>
                        </p:inline>
                    </p:output>
                    <p:output port="report">
                        <p:pipe step="epub3-validator" port="html-report"/>
                    </p:output>
                    <p:sink>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:sink>
                </p:when>
                <p:otherwise>
                    <p:output port="status" primary="true"/>
                    <p:output port="report" sequence="true">
                        <p:empty/>
                    </p:output>
                    <!--
                        FIXME: Scripts should not throw errors. They should set the status output to "FAIL".
                    -->
                    <px:error code="PED03" message="EPUB 3 input is invalid. Aborting."/>
                </p:otherwise>
            </p:choose>
        </p:otherwise>
    </p:choose>

    <px:epub3-to-daisy202-convert name="convert.daisy202">
        <p:input port="fileset.in">
            <p:pipe port="fileset.out" step="validate"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="validate"/>
        </p:input>
    </px:epub3-to-daisy202-convert>

    <px:fileset-move name="move">
        <p:with-option name="new-base" select="concat($output-dir,replace(/*/@content,'[^a-zA-Z0-9]','_'),'/')">
            <p:pipe port="result" step="identifier"/>
        </p:with-option>
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
    
    <p:group name="identifier">
        <p:output port="result"/>
        <px:fileset-load href="*/ncc.html">
            <p:input port="fileset">
                <p:pipe port="fileset.out" step="convert.daisy202"/>
            </p:input>
            <p:input port="in-memory">
                <p:pipe port="in-memory.out" step="convert.daisy202"/>
            </p:input>
        </px:fileset-load>
        <!--
            these assertions should normally never fail
        -->
        <px:assert test-count-min="1" test-count-max="1" error-code="PED01" message="There must be exactly one ncc.html in the resulting DAISY 2.02 fileset"/>
        <p:filter select="/*/*/*[@name='dc:identifier']"/>
        <px:assert test-count-min="1" error-code="PED02" message="There must be at least one dc:identifier meta element in the resulting ncc.html"/>
        <p:split-sequence test="position()=1"/>
    </p:group>
    <p:sink/>

</p:declare-step>
