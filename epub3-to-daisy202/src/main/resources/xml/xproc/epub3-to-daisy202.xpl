<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data"
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

    <p:import href="step/epub3-to-daisy202.load.xpl"/>
    <p:import href="step/epub3-to-daisy202.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>

    <p:variable name="epub-href" select="resolve-uri($epub,base-uri(/*))">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>

    <px:epub3-to-daisy202.load name="load">
        <p:with-option name="epub" select="$epub-href"/>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </px:epub3-to-daisy202.load>

    <px:epub3-to-daisy202-convert name="convert.daisy202">
        <p:input port="fileset.in">
            <p:pipe port="fileset.out" step="load"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="load"/>
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
        <px:assert test-count-min="1" test-count-max="1" error-code="PED01" message="There must be exactly one ncc.html in the resulting DAISY 2.02 fileset"/>
        <p:filter select="/*/*/*[@name='dc:identifier']"/>
        <px:assert test-count-min="1" test-count-max="1" error-code="PED02" message="There must be exactly one dc:identifier meta element in the resulting ncc.html"/>
    </p:group>
    <p:sink/>

</p:declare-step>
