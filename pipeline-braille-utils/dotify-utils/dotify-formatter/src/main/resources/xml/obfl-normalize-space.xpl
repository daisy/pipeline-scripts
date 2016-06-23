<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:obfl-normalize-space"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    
    <px:message message="[progress pxi:obfl-normalize-space 100 obfl-normalize-space.xsl]"/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="obfl-normalize-space.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
