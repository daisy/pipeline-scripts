<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:store-file" name="store-file"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-inline-prefixes="louis px p"
    version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:input port="directory" sequence="false"/>
    <p:output port="result" sequence="false" primary="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    
    <px:tempfile delete-on-exit="false" name="tempfile">
        <p:with-option name="href" select="/d:fileset/@xml:base">
            <p:pipe step="store-file" port="directory"/>
        </p:with-option>
    </px:tempfile>
    <p:store method="text">
        <p:input port="source">
            <p:pipe step="store-file" port="source"/>
        </p:input>
        <p:with-option name="href" select="/c:result">
            <p:pipe step="tempfile" port="result"/>
        </p:with-option>
    </p:store>
    <px:fileset-add-entry>
        <p:input port="source">
            <p:pipe step="store-file" port="directory"/>
        </p:input>
        <p:with-option name="href" select="replace(/c:result, '^.*/', '')">
            <p:pipe step="tempfile" port="result"/>
        </p:with-option>
    </px:fileset-add-entry>
    
    
</p:declare-step>
