<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="dtbook-to-zedai" type="px:dtbook-to-zedai" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="#all">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DTBook to ZedAI</h1>
        <p px:role="desc">Transforms DTBook XML into ZedAI XML.</p>
        <a px:role="homepage" href="http://code.google.com/p/daisy-pipeline/wiki/DTBookToZedAI">
            http://code.google.com/p/daisy-pipeline/wiki/DTBookToZedAI
        </a>
        <div px:role="author maintainer">
            <p px:role="name">Marisa DeMeglio</p>
            <a px:role="contact" href="mailto:marisa.demeglio@gmail.com">marisa.demeglio@gmail.com</a>
            <p px:role="organization">DAISY Consortium</p>
        </div>
    </p:documentation>
    
    <p:input port="source" primary="true" sequence="true" px:media-type="application/x-dtbook+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">DTBook file(s)</h2>
            <p px:role="desc">One or more DTBook files to be transformed. In the case of multiple files, a merge will be performed.</p>
        </p:documentation>
    </p:input>

    <p:option name="output-dir" required="true" px:output="output" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Output directory</h2>
            <p px:role="desc">The directory to store the generated files in.</p>
        </p:documentation>
    </p:option>
    <p:option name="zedai-filename" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">ZedAI filename</h2>
            <p px:role="desc">Filename for the generated ZedAI file</p>
        </p:documentation>
    </p:option>
    <p:option name="mods-filename" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">MODS filename</h2>
            <p px:role="desc">Filename for the generated MODS file</p>
        </p:documentation>
    </p:option>
    <p:option name="css-filename" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">CSS filename</h2>
            <p px:role="desc">Filename for the generated CSS file</p>
        </p:documentation>
    </p:option>
    <p:option name="lang" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Language code</h2>
            <p px:role="desc">Language code of the input document.</p>
        </p:documentation>
    </p:option>
    
    <p:import href="dtbook-to-zedai.load.xpl"/>
    <p:import href="dtbook-to-zedai.convert.xpl"/>
    <p:import href="dtbook-to-zedai.store.xpl"/>
    
    <px:dtbook-to-zedai-load name="load"/>

    <px:dtbook-to-zedai-convert name="convert">
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="load"/>
        </p:input>
        <p:with-option name="opt-output-dir" select="$output-dir"/>
        <p:with-option name="opt-zedai-filename" select="$zedai-filename"/>
        <p:with-option name="opt-mods-filename" select="$mods-filename"/>
        <p:with-option name="opt-css-filename" select="$css-filename"/>
        <p:with-option name="opt-lang" select="$lang"/>
    </px:dtbook-to-zedai-convert>

    <px:dtbook-to-zedai-store name="store">
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="convert"/>
        </p:input>
    </px:dtbook-to-zedai-store>

</p:declare-step>
