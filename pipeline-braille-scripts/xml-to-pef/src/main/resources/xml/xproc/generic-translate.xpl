<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="#all"
    type="px:generic-translate" version="1.0">
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/generic-libhyphen-hyphenate.xsl"/>
        </p:input>
        <p:with-param port="parameters" name="fail-on-missing-table" select="'false'"/>
    </p:xslt>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/generic-liblouis-translate.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:pipeline>
